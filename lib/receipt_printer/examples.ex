defmodule ReceiptPrinter.Examples do
  @moduledoc """
  Example receipts for testing the printer emulator.
  """
  
  alias ReceiptPrinter.ReceiptBuilder
  alias ReceiptPrinter.VirtualPrinter
  
  def run_all() do
    {:ok, printer} = VirtualPrinter.start_link(output_mode: :console)
    
    IO.puts("\n🧾 Running Receipt Printer Examples...\n")
    
    # Run each example
    simple_receipt() |> print(printer, "Simple Receipt")
    restaurant_receipt() |> print(printer, "Restaurant Receipt")
    retail_receipt() |> print(printer, "Retail Receipt")
    receipt_with_barcode() |> print(printer, "Receipt with Barcode")
    receipt_with_qr() |> print(printer, "Receipt with QR Code")
    
    IO.puts("\n✅ All examples completed!")
    
    # Return the printer pid for further inspection if needed
    printer
  end
  
  defp print(receipt_data, printer, name) do
    IO.puts("Printing: #{name}")
    VirtualPrinter.print(printer, receipt_data)
    Process.sleep(500)  # Small delay for readability
  end
  
  def simple_receipt() do
    ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("SIMPLE STORE")
    |> ReceiptBuilder.line("123 Main Street")
    |> ReceiptBuilder.line("City, ST 12345")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Date: #{Date.to_string(Date.utc_today())}")
    |> ReceiptBuilder.line("Time: #{Time.to_string(Time.utc_now())}")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.item_line("Coffee", "$3.50")
    |> ReceiptBuilder.item_line("Sandwich", "$8.00")
    |> ReceiptBuilder.item_line("Cookie", "$2.50")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.total_line("Subtotal:", "$14.00")
    |> ReceiptBuilder.total_line("Tax:", "$1.12")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.total_line("TOTAL:", "$15.12", :bold)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.center("Thank you for your purchase!")
    |> ReceiptBuilder.cut()
    |> ReceiptBuilder.build()
  end
  
  def restaurant_receipt() do
    ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("BELLA VISTA")
    |> ReceiptBuilder.subheader("Italian Restaurant")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.line("456 Restaurant Row")
    |> ReceiptBuilder.line("Foodie City, FC 54321")
    |> ReceiptBuilder.line("Tel: (555) 123-4567")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.line("Server: Sarah     Table: 12")
    |> ReceiptBuilder.line("Order #: 1847")
    |> ReceiptBuilder.line("Date: #{DateTime.to_string(DateTime.utc_now())}")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.bold("** DINE IN **")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.item_line("Bruschetta", "$8.50", 1)
    |> ReceiptBuilder.item_line("Caesar Salad", "$12.00", 2)
    |> ReceiptBuilder.item_line("Margherita Pizza", "$18.00", 1)
    |> ReceiptBuilder.item_line("Spaghetti Carbonara", "$16.50", 1)
    |> ReceiptBuilder.item_line("Tiramisu", "$8.00", 2)
    |> ReceiptBuilder.item_line("Espresso", "$3.50", 2)
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.total_line("Food:", "$74.00")
    |> ReceiptBuilder.total_line("Beverages:", "$7.00")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.total_line("Subtotal:", "$81.00")
    |> ReceiptBuilder.total_line("Tax (8%):", "$6.48")
    |> ReceiptBuilder.total_line("Service (18%):", "$14.58")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.total_line("TOTAL:", "$102.06", :double)
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.line("Payment: Credit Card ****1234")
    |> ReceiptBuilder.line("Auth: 123456")
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.center("Grazie! Come Again!")
    |> ReceiptBuilder.center("www.bellavista.com")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("Follow us @bellavista")
    |> ReceiptBuilder.cut()
    |> ReceiptBuilder.build()
  end
  
  def retail_receipt() do
    ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("TECH MART")
    |> ReceiptBuilder.line("Your Electronics Superstore")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Store #4821")
    |> ReceiptBuilder.line("789 Tech Boulevard")
    |> ReceiptBuilder.line("Silicon Valley, CA 94025")
    |> ReceiptBuilder.line("(650) 555-0100")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.table_row(["Date:", Date.to_string(Date.utc_today())], [20, 28])
    |> ReceiptBuilder.table_row(["Time:", Time.to_string(Time.utc_now())], [20, 28])
    |> ReceiptBuilder.table_row(["Trans #:", "48210392"], [20, 28])
    |> ReceiptBuilder.table_row(["Cashier:", "Mike R."], [20, 28])
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.line("ITEM                    QTY    PRICE   TOTAL")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("USB-C Cable 6ft")
    |> ReceiptBuilder.line("  SKU: 1029384756        1   $19.99  $19.99")
    |> ReceiptBuilder.line("")
    |> ReceiptBuilder.line("Wireless Mouse")
    |> ReceiptBuilder.line("  SKU: 2938475610        1   $34.99  $34.99")
    |> ReceiptBuilder.line("")
    |> ReceiptBuilder.line("Phone Case Clear")
    |> ReceiptBuilder.line("  SKU: 9283746501        2   $12.99  $25.98")
    |> ReceiptBuilder.line("")
    |> ReceiptBuilder.line("Screen Protector 3pk")
    |> ReceiptBuilder.line("  SKU: 8273645910        1   $15.99  $15.99")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.right("Subtotal: $96.95")
    |> ReceiptBuilder.right("Sales Tax (8.5%): $8.24")
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.size("TOTAL: $105.19", :double)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.double_separator()
    |> ReceiptBuilder.line("VISA ****8462")
    |> ReceiptBuilder.line("APPROVED")
    |> ReceiptBuilder.line("Auth Code: 483921")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.bold("CUSTOMER COPY")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("Return Policy")
    |> ReceiptBuilder.line("30 days with receipt")
    |> ReceiptBuilder.line("Unopened items only")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("Save 10% on your next visit!")
    |> ReceiptBuilder.center("Survey: techmart.com/survey")
    |> ReceiptBuilder.center("Code: 4821-0392")
    |> ReceiptBuilder.cut()
    |> ReceiptBuilder.build()
  end
  
  def receipt_with_barcode() do
    ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("BARCODE EXAMPLE")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Product: Widget Pro X")
    |> ReceiptBuilder.line("SKU: WPX-2024-001")
    |> ReceiptBuilder.line("Price: $49.99")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("Product Barcode:")
    |> ReceiptBuilder.barcode(:code128, "WPX2024001", 
        height: 100, 
        width: 3, 
        text_position: :below)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("UPC-A Example:")
    |> ReceiptBuilder.barcode(:upc_a, "12345678901", text_position: :below)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("CODE39 Example:")
    |> ReceiptBuilder.barcode(:code39, "ABC123", text_position: :below)
    |> ReceiptBuilder.cut()
    |> ReceiptBuilder.build()
  end
  
  def receipt_with_qr() do
    ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("QR CODE RECEIPT")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("Order #: 2024-1234")
    |> ReceiptBuilder.line("Total: $25.00")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.center("Scan for digital receipt:")
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.qr_code("https://store.example.com/receipt/2024-1234", 
        size: 4, 
        correction: :m)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("WiFi Access:")
    |> ReceiptBuilder.qr_code("WIFI:T:WPA;S:GuestNetwork;P:Welcome123;;", 
        size: 3, 
        correction: :l)
    |> ReceiptBuilder.blank_lines(1)
    |> ReceiptBuilder.line("Network: GuestNetwork")
    |> ReceiptBuilder.line("Password: Welcome123")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("Thank you!")
    |> ReceiptBuilder.cut()
    |> ReceiptBuilder.build()
  end
  
  # Test function to demonstrate raw ESC/POS commands
  def test_raw_commands() do
    alias ReceiptPrinter.EscPos
    
    # Build raw ESC/POS command sequence
    commands = [
      EscPos.init(),
      EscPos.bold(true),
      EscPos.align(:center),
      EscPos.font_size(:double),
      EscPos.text("RAW ESC/POS TEST"),
      EscPos.line_feed(),
      EscPos.font_size(:normal),
      EscPos.bold(false),
      EscPos.align(:left),
      EscPos.text("This tests raw commands"),
      EscPos.line_feed(),
      EscPos.inverse(true),
      EscPos.text(" INVERSE TEXT "),
      EscPos.inverse(false),
      EscPos.line_feed(3),
      EscPos.cut(:partial)
    ]
    
    EscPos.build(commands)
  end
  
  # Helper to test with the emulator directly
  def test_emulator() do
    emulator = ReceiptPrinterEmulator.new(width: 48)
    
    # Process a simple receipt
    receipt_data = simple_receipt()
    emulator = ReceiptPrinterEmulator.process(emulator, receipt_data)
    
    # Get different output formats
    text_output = ReceiptPrinterEmulator.render(emulator, :text)
    html_output = ReceiptPrinterEmulator.render(emulator, :html)
    
    IO.puts("\n=== TEXT OUTPUT ===")
    IO.puts(text_output)
    
    IO.puts("\n=== HTML OUTPUT (preview) ===")
    IO.puts(String.slice(html_output, 0, 500) <> "...")
    
    {text_output, html_output}
  end
end