defmodule Blog.ReceiptPrinter.MessageHandler do
  @moduledoc """
  Handles formatting and printing of messages from the LiveView to the receipt printer.
  Converts user messages into properly formatted receipts with ESC/POS commands.
  """
  
  require Logger
  alias ReceiptPrinter.{NetworkClient, ReceiptBuilder}
  
  @printer_host "127.0.0.1"
  @printer_port 9100
  @max_line_width 48
  
  @doc """
  Prints a message from the LiveView form to the receipt printer.
  """
  def print_message(%Blog.ReceiptMessage{} = message) do
    receipt = build_message_receipt(
      message.content, 
      message.sender_ip || "unknown",
      message.sender_name,
      message.image_url
    )
    
    case NetworkClient.print_receipt(receipt, host: @printer_host, port: @printer_port) do
      :ok ->
        Logger.info("Successfully printed message from #{message.sender_ip}")
        Blog.ReceiptMessages.mark_as_printed(message)
        {:ok, "Message printed successfully"}
        
      {:error, reason} = error ->
        Logger.error("Failed to print message: #{inspect(reason)}")
        Blog.ReceiptMessages.mark_as_failed(message)
        error
    end
  end
  
  # Support for map-based messages (for testing)
  def print_message(%{content: content} = attrs) when is_map(attrs) do
    receipt = build_message_receipt(
      content,
      attrs[:sender_ip] || "unknown",
      attrs[:sender_name],
      attrs[:image_url]
    )
    
    case NetworkClient.print_receipt(receipt, host: @printer_host, port: @printer_port) do
      :ok ->
        Logger.info("Successfully printed message")
        {:ok, "Message printed successfully"}
        
      {:error, reason} = error ->
        Logger.error("Failed to print message: #{inspect(reason)}")
        error
    end
  end
  
  @doc """
  Prints a simple text message directly (for testing).
  """
  def print_text(text, sender_ip \\ "Manual") do
    print_message(%{content: text, sender_ip: sender_ip})
  end
  
  @doc """
  Test function to verify printer connection and print a test page.
  """
  def print_test do
    test_receipt = ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("PRINTER TEST")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Connection: OK")
    |> ReceiptBuilder.line("Time: #{format_datetime(DateTime.utc_now())}")
    |> ReceiptBuilder.line("Status: Ready")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("All systems operational")
    |> ReceiptBuilder.cut()
    
    case NetworkClient.print_receipt(test_receipt, host: @printer_host, port: @printer_port) do
      :ok -> 
        IO.puts("✅ Test page printed successfully!")
        :ok
      {:error, reason} ->
        IO.puts("❌ Failed to print test page: #{inspect(reason)}")
        {:error, reason}
    end
  end
  
  @doc """
  Prints the message queue (all pending messages).
  """
  def print_queue do
    if function_exported?(Blog.ReceiptMessages, :list_pending_messages, 0) do
      messages = Blog.ReceiptMessages.list_pending_messages()
      
      Enum.each(messages, fn message ->
        print_message(message)
        Process.sleep(1000)  # Delay between receipts
      end)
      
      {:ok, "Printed #{length(messages)} messages"}
    else
      {:error, "Message queue not available"}
    end
  end
  
  # Private functions
  
  defp build_message_receipt(content, sender_ip, sender_name, image_url) do
    timestamp = DateTime.utc_now()
    
    receipt = ReceiptBuilder.new(width: @max_line_width)
    |> ReceiptBuilder.init_printer()
    
    # Header with decorative border
    receipt = receipt
    |> ReceiptBuilder.center("════════════════════════")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.size("NEW MESSAGE", :double)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("════════════════════════")
    |> ReceiptBuilder.blank_lines(1)
    
    # Metadata
    from_line = if sender_name do
      "From: #{sender_name} (#{format_sender(sender_ip)})"
    else
      "From: #{format_sender(sender_ip)}"
    end
    
    receipt = receipt
    |> ReceiptBuilder.line(from_line)
    |> ReceiptBuilder.line("Time: #{format_datetime(timestamp)}")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.blank_lines(1)
    
    # Message content with proper word wrapping
    receipt = receipt
    |> ReceiptBuilder.bold("Message:")
    |> ReceiptBuilder.line_feed()
    |> add_wrapped_content(content)
    |> ReceiptBuilder.blank_lines(1)
    
    # Image indicator if present
    receipt = if image_url do
      receipt
      |> ReceiptBuilder.separator()
      |> ReceiptBuilder.center("[📷 Image Attached]")
      |> ReceiptBuilder.blank_lines(1)
    else
      receipt
    end

    # Footer
    receipt
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("Thank you for your message!")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("────────────────────────")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.qr_code("msg:#{timestamp |> DateTime.to_unix()}", size: 3)
    |> ReceiptBuilder.center("Message ID: #{format_message_id(timestamp)}")
    |> ReceiptBuilder.cut(:partial, 4)
  end
  
  defp add_wrapped_content(receipt, content) do
    content
    |> wrap_text(@max_line_width - 4)  # Account for margins
    |> Enum.reduce(receipt, fn line, acc ->
      ReceiptBuilder.line(acc, "  #{line}")  # Indent message content
    end)
  end
  
  defp wrap_text(text, max_width) do
    text
    |> String.split("\n")
    |> Enum.flat_map(&wrap_line(&1, max_width))
  end
  
  defp wrap_line("", _max_width), do: [""]
  defp wrap_line(line, max_width) do
    words = String.split(line, " ")
    
    {lines, current} = Enum.reduce(words, {[], ""}, fn word, {lines, current} ->
      test_line = if current == "", do: word, else: "#{current} #{word}"
      
      if String.length(test_line) <= max_width do
        {lines, test_line}
      else
        if current == "" do
          # Word is too long, split it
          {lines ++ [String.slice(word, 0, max_width)], String.slice(word, max_width..-1)}
        else
          {lines ++ [current], word}
        end
      end
    end)
    
    if current == "" do
      if lines == [], do: [""], else: lines
    else
      lines ++ [current]
    end
  end
  
  defp format_sender(ip) when is_binary(ip) do
    case ip do
      "127.0.0.1" -> "Local"
      "::1" -> "Local (IPv6)"
      "unknown" -> "Anonymous"
      _ -> ip
    end
  end
  defp format_sender(_), do: "Unknown"
  
  defp format_datetime(datetime) do
    datetime
    |> DateTime.shift_zone!("Etc/UTC")
    |> Calendar.strftime("%Y-%m-%d %H:%M:%S UTC")
  end
  
  defp format_message_id(datetime) do
    unix = DateTime.to_unix(datetime)
    Base.encode32(<<unix::64>>, padding: false)
    |> String.slice(0, 8)
  end
  
  @doc """
  Demo function showing various message formats
  """
  def demo_messages do
    messages = [
      %{
        content: "Hello! This is a test message from the web interface. Hope you're having a great day!",
        sender_ip: "192.168.1.100"
      },
      %{
        content: "Short message",
        sender_ip: "10.0.0.42"
      },
      %{
        content: """
        This is a longer message with multiple paragraphs.
        
        It includes line breaks and should wrap properly on the receipt printer.
        
        The formatting should be preserved and look nice on the thermal paper.
        """,
        sender_ip: "::1"
      },
      %{
        content: "A message with an image attached! 📸",
        sender_ip: "203.0.113.42",
        sender_name: "Photo Fan",
        image_url: "https://example.com/image.jpg"
      }
    ]
    
    IO.puts("Sending demo messages to printer...")
    
    Enum.each(messages, fn msg ->
      IO.puts("Printing message from #{msg.sender_ip}...")
      print_message(msg)
      Process.sleep(2000)
    end)
    
    IO.puts("Demo complete!")
  end
end