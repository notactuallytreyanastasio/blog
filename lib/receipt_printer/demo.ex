defmodule ReceiptPrinter.Demo do
  @moduledoc """
  Demo module showing how to use the receipt printer emulator.
  This sends print jobs to the external printer binary via TCP.
  """
  
  alias ReceiptPrinter.{NetworkClient, ReceiptBuilder, EscPos}
  
  @doc """
  Run all demo receipts
  """
  def run_all(opts \\ []) do
    IO.puts("\n🖨️  Receipt Printer Demo")
    IO.puts("========================\n")
    
    # Test connection first
    case NetworkClient.test_connection(opts) do
      {:ok, msg} ->
        IO.puts("✅ #{msg}")
        IO.puts("\nSending receipts to printer...\n")
        
        # Send each demo receipt
        demo_simple_receipt(opts)
        Process.sleep(1000)
        
        demo_restaurant_receipt(opts)
        Process.sleep(1000)
        
        demo_retail_receipt(opts)
        Process.sleep(1000)
        
        demo_barcode_receipt(opts)
        Process.sleep(1000)
        
        demo_formatted_receipt(opts)
        
        IO.puts("\n✅ All receipts sent successfully!")
        
      {:error, error} ->
        IO.puts("❌ #{error}")
        IO.puts("\nMake sure the receipt printer emulator is running:")
        IO.puts("  cd receipt-printer-emulator")
        IO.puts("  cargo run --release")
        IO.puts("\nOr with options:")
        IO.puts("  cargo run --release -- --port 9100 --verbose")
    end
  end
  
  @doc """
  Simple receipt demo
  """
  def demo_simple_receipt(opts \\ []) do
    receipt = ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("COFFEE SHOP")
    |> ReceiptBuilder.line("123 Main Street")
    |> ReceiptBuilder.line("Your City, ST 12345")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Date: #{Date.to_string(Date.utc_today())}")
    |> ReceiptBuilder.line("Time: #{format_time(Time.utc_now())}")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.item_line("Espresso", "$3.50")
    |> ReceiptBuilder.item_line("Croissant", "$4.50")
    |> ReceiptBuilder.item_line("Orange Juice", "$5.00")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.total_line("Subtotal:", "$13.00")
    |> ReceiptBuilder.total_line("Tax:", "$1.04")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.total_line("TOTAL:", "$14.04", :bold)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.center("Thank you!")
    |> ReceiptBuilder.center("Have a great day!")
    |> ReceiptBuilder.cut()
    
    case NetworkClient.print_receipt(receipt, opts) do
      :ok -> IO.puts("📝 Sent: Simple receipt")
      {:error, reason} -> IO.puts("❌ Error: #{inspect(reason)}")
    end
  end
  
  @doc """
  Restaurant receipt demo
  """
  def demo_restaurant_receipt(opts \\ []) do
    receipt = ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("BELLA PASTA")
    |> ReceiptBuilder.subheader("Authentic Italian")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("══════════════")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.line("Table: 12    Server: Maria")
    |> ReceiptBuilder.line("Order #487")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.bold("APPETIZERS")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.item_line("Bruschetta", "$8.95", 1)
    |> ReceiptBuilder.item_line("Caesar Salad", "$10.95", 2)
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.bold("MAIN COURSES")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.item_line("Spaghetti Carbonara", "$18.95", 1)
    |> ReceiptBuilder.item_line("Chicken Parmigiana", "$22.95", 1)
    |> ReceiptBuilder.item_line("Margherita Pizza", "$16.95", 1)
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.bold("BEVERAGES")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.item_line("House Wine", "$7.00", 2)
    |> ReceiptBuilder.item_line("Espresso", "$3.50", 2)
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.total_line("Food:", "$77.70")
    |> ReceiptBuilder.total_line("Beverages:", "$21.00")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.total_line("Subtotal:", "$98.70")
    |> ReceiptBuilder.total_line("Tax (8%):", "$7.90")
    |> ReceiptBuilder.total_line("Service (18%):", "$17.77")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.total_line("TOTAL:", "$124.37", :double)
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("Grazie!")
    |> ReceiptBuilder.center("www.bellapasta.com")
    |> ReceiptBuilder.cut()
    
    case NetworkClient.print_receipt(receipt, opts) do
      :ok -> IO.puts("📝 Sent: Restaurant receipt")
      {:error, reason} -> IO.puts("❌ Error: #{inspect(reason)}")
    end
  end
  
  @doc """
  Retail store receipt demo
  """
  def demo_retail_receipt(opts \\ []) do
    receipt = ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("TECH WORLD")
    |> ReceiptBuilder.line("Store #1234")
    |> ReceiptBuilder.line("555-0100")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Cashier: John    Register: 3")
    |> ReceiptBuilder.line("Trans: 98765")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("ITEM              QTY    PRICE")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("USB Cable 3ft")
    |> ReceiptBuilder.line("  789456123000     1    $12.99")
    |> ReceiptBuilder.line("Wireless Mouse")
    |> ReceiptBuilder.line("  456789012345     1    $29.99")
    |> ReceiptBuilder.line("Phone Case")
    |> ReceiptBuilder.line("  123456789012     2    $15.99")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.right("Subtotal: $74.96")
    |> ReceiptBuilder.right("Tax: $5.25")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.size("TOTAL: $80.21", :double)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("VISA ****1234")
    |> ReceiptBuilder.line("APPROVED")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("Return within 30 days")
    |> ReceiptBuilder.center("with receipt")
    |> ReceiptBuilder.cut()
    
    case NetworkClient.print_receipt(receipt, opts) do
      :ok -> IO.puts("📝 Sent: Retail receipt")
      {:error, reason} -> IO.puts("❌ Error: #{inspect(reason)}")
    end
  end
  
  @doc """
  Receipt with barcode demo
  """
  def demo_barcode_receipt(opts \\ []) do
    receipt = ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("BARCODE TEST")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Product: Widget XL")
    |> ReceiptBuilder.line("SKU: WDG-XL-2024")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("Product Code:")
    |> ReceiptBuilder.barcode(:code128, "WDG2024XL001", height: 80)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.center("UPC Code:")
    |> ReceiptBuilder.barcode(:upc_a, "12345678901", text_position: :below)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.qr_code("https://example.com/product/WDG-XL-2024", size: 4)
    |> ReceiptBuilder.center("Scan for details")
    |> ReceiptBuilder.cut()
    
    case NetworkClient.print_receipt(receipt, opts) do
      :ok -> IO.puts("📝 Sent: Barcode receipt")
      {:error, reason} -> IO.puts("❌ Error: #{inspect(reason)}")
    end
  end
  
  @doc """
  Receipt with various formatting
  """
  def demo_formatted_receipt(opts \\ []) do
    receipt = ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.size("BIG TITLE", :double)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.bold("Bold Text Example")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.underline("Underlined Text", :single)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.inverse("Inverse Video Text")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.left("Left aligned")
    |> ReceiptBuilder.center("Center aligned")
    |> ReceiptBuilder.right("Right aligned")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.size("Double Width", :double_width)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.size("Double Height", :double_height)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.size("Quad Size", :quad)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.table_row(["Col1", "Col2", "Col3"], [16, 16, 16])
    |> ReceiptBuilder.table_row(["Data", "More", "Last"], [16, 16, 16])
    |> ReceiptBuilder.cut()
    
    case NetworkClient.print_receipt(receipt, opts) do
      :ok -> IO.puts("📝 Sent: Formatted receipt")
      {:error, reason} -> IO.puts("❌ Error: #{inspect(reason)}")
    end
  end
  
  @doc """
  Send raw ESC/POS commands directly
  """
  def demo_raw_commands(opts \\ []) do
    commands = [
      EscPos.init(),
      EscPos.bold(true),
      EscPos.align(:center),
      EscPos.text("RAW COMMAND TEST"),
      EscPos.line_feed(),
      EscPos.bold(false),
      EscPos.align(:left),
      EscPos.text("This is raw ESC/POS"),
      EscPos.line_feed(),
      EscPos.inverse(true),
      EscPos.text(" INVERSE "),
      EscPos.inverse(false),
      EscPos.line_feed(3),
      EscPos.cut(:partial)
    ]
    
    data = EscPos.build(commands)
    
    case NetworkClient.print_raw(data, opts) do
      :ok -> 
        IO.puts("📝 Sent: Raw ESC/POS commands")
        :ok
      {:error, reason} -> 
        IO.puts("❌ Error: #{inspect(reason)}")
        {:error, reason}
    end
  end
  
  # Helper functions
  
  defp format_time(time) do
    "#{String.pad_leading(to_string(time.hour), 2, "0")}:" <>
    "#{String.pad_leading(to_string(time.minute), 2, "0")}:" <>
    "#{String.pad_leading(to_string(time.second), 2, "0")}"
  end
end