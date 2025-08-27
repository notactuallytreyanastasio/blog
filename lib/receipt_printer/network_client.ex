defmodule ReceiptPrinter.NetworkClient do
  @moduledoc """
  TCP client for sending print jobs to the receipt printer emulator.
  This simulates sending data to a real network receipt printer.
  """
  
  alias ReceiptPrinter.ReceiptBuilder
  alias ReceiptPrinter.EscPos
  
  @default_host "127.0.0.1"
  @default_port 9100
  @connect_timeout 5000
  @send_timeout 5000
  
  @doc """
  Send raw binary data to the printer
  """
  def print_raw(data, opts \\ []) do
    host = Keyword.get(opts, :host, @default_host) |> String.to_charlist()
    port = Keyword.get(opts, :port, @default_port)
    
    case :gen_tcp.connect(host, port, [:binary, active: false], @connect_timeout) do
      {:ok, socket} ->
        result = :gen_tcp.send(socket, data)
        :gen_tcp.close(socket)
        result
        
      {:error, reason} ->
        {:error, "Failed to connect to printer at #{host}:#{port} - #{inspect(reason)}"}
    end
  end
  
  @doc """
  Send a ReceiptBuilder to the printer
  """
  def print_receipt(builder, opts \\ []) when is_struct(builder, ReceiptBuilder) do
    data = ReceiptBuilder.build(builder)
    print_raw(data, opts)
  end
  
  @doc """
  Print plain text lines
  """
  def print_text(input, opts \\ [])
  
  def print_text(lines, opts) when is_list(lines) do
    data = lines
    |> Enum.map(&(EscPos.text(&1) <> EscPos.line_feed()))
    |> Enum.join("")
    |> Kernel.<>(EscPos.cut(:partial))
    
    print_raw(data, opts)
  end
  
  def print_text(text, opts) when is_binary(text) do
    text
    |> String.split("\n")
    |> print_text(opts)
  end
  
  @doc """
  Test if printer is available
  """
  def test_connection(opts \\ []) do
    host = Keyword.get(opts, :host, @default_host) |> String.to_charlist()
    port = Keyword.get(opts, :port, @default_port)
    
    case :gen_tcp.connect(host, port, [:binary, active: false], @connect_timeout) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        {:ok, "Printer is available at #{host}:#{port}"}
        
      {:error, reason} ->
        {:error, "Cannot connect to printer at #{host}:#{port} - #{inspect(reason)}"}
    end
  end
  
  @doc """
  Send multiple receipts in sequence
  """
  def batch_print(receipts, opts \\ []) do
    host = Keyword.get(opts, :host, @default_host) |> String.to_charlist()
    port = Keyword.get(opts, :port, @default_port)
    delay = Keyword.get(opts, :delay, 500)
    
    case :gen_tcp.connect(host, port, [:binary, active: false], @connect_timeout) do
      {:ok, socket} ->
        results = Enum.map(receipts, fn receipt ->
          data = case receipt do
            %ReceiptBuilder{} -> ReceiptBuilder.build(receipt)
            binary when is_binary(binary) -> binary
          end
          
          result = :gen_tcp.send(socket, data)
          Process.sleep(delay)
          result
        end)
        
        :gen_tcp.close(socket)
        {:ok, results}
        
      {:error, reason} ->
        {:error, "Failed to connect for batch print - #{inspect(reason)}"}
    end
  end
end