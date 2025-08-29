defmodule Blog.ReceiptPrinterService do
  @moduledoc """
  Service that polls for pending receipt messages and sends them to the printer,
  including support for dithered images.
  """
  use GenServer
  require Logger
  
  alias Blog.ReceiptMessages
  alias ReceiptPrinter.NetworkClient
  alias ReceiptPrinter.ReceiptBuilder
  alias ReceiptPrinter.ImageProcessor
  
  @poll_interval 5_000  # 5 seconds
  @printer_host "127.0.0.1"
  @printer_port 9100
  
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  @impl true
  def init(opts) do
    state = %{
      poll_interval: Keyword.get(opts, :poll_interval, @poll_interval),
      printer_host: Keyword.get(opts, :printer_host, @printer_host),
      printer_port: Keyword.get(opts, :printer_port, @printer_port),
      enabled: Keyword.get(opts, :enabled, true)
    }
    
    if state.enabled do
      schedule_poll(state.poll_interval)
      Logger.info("Receipt Printer Service started - polling every #{state.poll_interval}ms")
    else
      Logger.info("Receipt Printer Service started but disabled")
    end
    
    {:ok, state}
  end
  
  @impl true
  def handle_info(:poll, state) do
    if state.enabled do
      process_pending_messages(state)
      schedule_poll(state.poll_interval)
    end
    
    {:noreply, state}
  end
  
  defp schedule_poll(interval) do
    Process.send_after(self(), :poll, interval)
  end
  
  defp process_pending_messages(state) do
    messages = ReceiptMessages.list_pending_messages()
    
    if length(messages) > 0 do
      Logger.info("Processing #{length(messages)} pending messages")
      
      Enum.each(messages, fn message ->
        try do
          print_message(message, state)
          ReceiptMessages.mark_as_printed(message)
          Logger.info("Successfully printed message #{message.id}")
        rescue
          e ->
            Logger.error("Failed to print message #{message.id}: #{inspect(e)}")
            ReceiptMessages.mark_as_failed(message)
        end
      end)
    end
  end
  
  defp print_message(message, state) do
    printer_opts = [
      host: state.printer_host,
      port: state.printer_port
    ]
    
    # Build the receipt with proper formatting
    builder = ReceiptBuilder.new()
    |> ReceiptBuilder.init()
    |> ReceiptBuilder.align(:center)
    |> ReceiptBuilder.text("========================")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.font_size(:double)
    |> ReceiptBuilder.text("NEW MESSAGE")
    |> ReceiptBuilder.font_size(:normal)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("========================")
    |> ReceiptBuilder.line_feed(2)
    |> ReceiptBuilder.align(:left)
    |> ReceiptBuilder.text("From: #{message.sender_ip || "unknown"}")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("Time: #{format_datetime(message.inserted_at)}")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("--------------------------------")
    |> ReceiptBuilder.line_feed(2)
    
    # Add message content
    builder = builder
    |> ReceiptBuilder.bold(true)
    |> ReceiptBuilder.text("Message:")
    |> ReceiptBuilder.bold(false)
    |> ReceiptBuilder.line_feed()
    
    # Split content into lines and add indentation
    message.content
    |> String.split("\n")
    |> Enum.reduce(builder, fn line, acc ->
      acc
      |> ReceiptBuilder.text("  #{line}")
      |> ReceiptBuilder.line_feed()
    end)
    |> ReceiptBuilder.line_feed()
    
    # Check if there's an image to print
    builder = if message.image_url && message.image_url != "" do
      builder
      |> ReceiptBuilder.text("--------------------------------")
      |> ReceiptBuilder.line_feed()
      |> ReceiptBuilder.align(:center)
      |> ReceiptBuilder.text("[Image Attached]")
      |> ReceiptBuilder.line_feed()
      |> print_image_if_available(message.image_url, printer_opts)
      |> ReceiptBuilder.align(:left)
    else
      builder
    end
    
    # Footer
    builder = builder
    |> ReceiptBuilder.text("--------------------------------")
    |> ReceiptBuilder.line_feed(2)
    |> ReceiptBuilder.align(:center)
    |> ReceiptBuilder.text("Thank you for your message!")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("ID: MSG#{String.pad_leading(to_string(message.id), 6, "0")}")
    |> ReceiptBuilder.line_feed(4)
    |> ReceiptBuilder.cut(:partial)
    
    # Send to printer
    NetworkClient.print_receipt(builder, printer_opts)
  end
  
  defp print_image_if_available(builder, image_url, printer_opts) do
    # For now, if image_url is a path or binary data, process it
    # In a real implementation, you'd download the image from URL
    case process_image_for_printing(image_url) do
      {:ok, bitmap_data} ->
        # Add the raw bitmap data directly to the builder
        # This requires extending ReceiptBuilder to handle raw data
        builder
        |> ReceiptBuilder.raw(bitmap_data)
        |> ReceiptBuilder.line_feed(2)
      {:error, reason} ->
        Logger.warning("Could not process image: #{reason}")
        builder
        |> ReceiptBuilder.text("[Image could not be printed]")
        |> ReceiptBuilder.line_feed()
    end
  end
  
  defp process_image_for_printing(image_url) when is_binary(image_url) do
    # Check if it's a file path or URL
    cond do
      File.exists?(image_url) ->
        ImageProcessor.process_image(image_url, width: 384)
      
      String.starts_with?(image_url, "http") ->
        # Download image first
        case download_image(image_url) do
          {:ok, image_binary} ->
            ImageProcessor.process_image_binary(image_binary, width: 384)
          error ->
            error
        end
      
      true ->
        {:error, "Invalid image source"}
    end
  end
  
  defp download_image(url) do
    case :httpc.request(:get, {String.to_charlist(url), []}, [], []) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        {:ok, :erlang.list_to_binary(body)}
      {:ok, {{_, status, _}, _, _}} ->
        {:error, "HTTP #{status}"}
      {:error, reason} ->
        {:error, inspect(reason)}
    end
  end
  
  defp format_datetime(nil), do: "Unknown"
  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
  end
end