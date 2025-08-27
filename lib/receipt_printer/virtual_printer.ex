defmodule ReceiptPrinter.VirtualPrinter do
  @moduledoc """
  Virtual printer that acts as a sink for print jobs.
  Can output to console, file, or web interface.
  """
  
  use GenServer
  require Logger
  
  alias ReceiptPrinterEmulator
  
  defstruct [
    :name,
    :emulator,
    :output_mode,
    :output_path,
    :receipts,
    :current_job,
    :listeners
  ]
  
  # Client API
  
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end
  
  def print(printer \\ __MODULE__, data) do
    GenServer.call(printer, {:print, data})
  end
  
  def print_text(printer \\ __MODULE__, text) do
    commands = build_receipt(text)
    print(printer, commands)
  end
  
  def get_receipts(printer \\ __MODULE__) do
    GenServer.call(printer, :get_receipts)
  end
  
  def get_last_receipt(printer \\ __MODULE__) do
    GenServer.call(printer, :get_last_receipt)
  end
  
  def clear_receipts(printer \\ __MODULE__) do
    GenServer.cast(printer, :clear_receipts)
  end
  
  def subscribe(printer \\ __MODULE__) do
    GenServer.call(printer, {:subscribe, self()})
  end
  
  def unsubscribe(printer \\ __MODULE__) do
    GenServer.call(printer, {:unsubscribe, self()})
  end
  
  # Server callbacks
  
  @impl true
  def init(opts) do
    state = %__MODULE__{
      name: Keyword.get(opts, :name, "Virtual Printer"),
      emulator: ReceiptPrinterEmulator.new(width: Keyword.get(opts, :width, 48)),
      output_mode: Keyword.get(opts, :output_mode, :console),
      output_path: Keyword.get(opts, :output_path, "./receipts"),
      receipts: [],
      current_job: nil,
      listeners: []
    }
    
    # Create output directory if file mode
    if state.output_mode == :file do
      File.mkdir_p!(state.output_path)
    end
    
    {:ok, state}
  end
  
  @impl true
  def handle_call({:print, data}, _from, state) do
    # Process the data through the emulator
    emulator = ReceiptPrinterEmulator.process(state.emulator, data)
    
    # Generate receipt output
    receipt = %{
      id: generate_receipt_id(),
      timestamp: DateTime.utc_now(),
      raw_data: data,
      text_output: ReceiptPrinterEmulator.render(emulator, :text),
      html_output: ReceiptPrinterEmulator.render(emulator, :html)
    }
    
    # Output based on mode
    output_receipt(receipt, state)
    
    # Store receipt and reset emulator
    new_state = %{state | 
      receipts: [receipt | state.receipts],
      emulator: ReceiptPrinterEmulator.new(width: state.emulator.width)
    }
    
    # Notify listeners
    notify_listeners(state.listeners, {:new_receipt, receipt})
    
    {:reply, {:ok, receipt.id}, new_state}
  end
  
  @impl true
  def handle_call(:get_receipts, _from, state) do
    {:reply, Enum.reverse(state.receipts), state}
  end
  
  @impl true
  def handle_call(:get_last_receipt, _from, state) do
    {:reply, List.first(state.receipts), state}
  end
  
  @impl true
  def handle_call({:subscribe, pid}, _from, state) do
    {:reply, :ok, %{state | listeners: [pid | state.listeners]}}
  end
  
  @impl true
  def handle_call({:unsubscribe, pid}, _from, state) do
    {:reply, :ok, %{state | listeners: List.delete(state.listeners, pid)}}
  end
  
  @impl true
  def handle_cast(:clear_receipts, state) do
    {:noreply, %{state | receipts: []}}
  end
  
  # Private functions
  
  defp generate_receipt_id() do
    :crypto.strong_rand_bytes(8) |> Base.encode16()
  end
  
  defp output_receipt(receipt, state) do
    case state.output_mode do
      :console ->
        IO.puts("\n" <> String.duplicate("=", 50))
        IO.puts("RECEIPT ##{receipt.id}")
        IO.puts("Time: #{receipt.timestamp}")
        IO.puts(String.duplicate("-", 50))
        IO.puts(receipt.text_output)
        IO.puts(String.duplicate("=", 50) <> "\n")
        
      :file ->
        filename = Path.join(state.output_path, "receipt_#{receipt.id}.txt")
        File.write!(filename, receipt.text_output)
        Logger.info("Receipt saved to #{filename}")
        
      :silent ->
        # No output
        :ok
        
      _ ->
        Logger.warn("Unknown output mode: #{state.output_mode}")
    end
  end
  
  defp notify_listeners(listeners, message) do
    Enum.each(listeners, fn pid ->
      send(pid, message)
    end)
  end
  
  defp build_receipt(lines) when is_list(lines) do
    lines
    |> Enum.map(&(ReceiptPrinter.EscPos.text(&1) <> ReceiptPrinter.EscPos.line_feed()))
    |> ReceiptPrinter.EscPos.build()
  end
  
  defp build_receipt(text) when is_binary(text) do
    text
    |> String.split("\n")
    |> build_receipt()
  end
end