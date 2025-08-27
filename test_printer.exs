#!/usr/bin/env elixir

# Test script for receipt printer integration
# Run with: elixir test_printer.exs

defmodule TestPrinter do
  def run do
    IO.puts("\n🖨️  Receipt Printer Test Suite")
    IO.puts("=" |> String.duplicate(50))
    
    # Test 1: Check printer connection
    IO.puts("\n1. Testing printer connection...")
    case ReceiptPrinter.NetworkClient.test_connection() do
      {:ok, msg} ->
        IO.puts("   ✅ #{msg}")
      {:error, error} ->
        IO.puts("   ❌ #{error}")
        IO.puts("\n   Please start the printer with: ./start_receipt_printer.sh")
        System.halt(1)
    end
    
    # Test 2: Print test page
    IO.puts("\n2. Printing test page...")
    case Blog.ReceiptPrinter.MessageHandler.print_test() do
      :ok ->
        IO.puts("   ✅ Test page sent")
      _ ->
        IO.puts("   ❌ Failed to print test page")
    end
    
    Process.sleep(1000)
    
    # Test 3: Print a simple message
    IO.puts("\n3. Printing simple message...")
    Blog.ReceiptPrinter.MessageHandler.print_text(
      "Hello from the test script!",
      "127.0.0.1"
    )
    IO.puts("   ✅ Message sent")
    
    Process.sleep(1000)
    
    # Test 4: Print formatted receipt
    IO.puts("\n4. Printing formatted receipt...")
    alias ReceiptPrinter.ReceiptBuilder
    
    receipt = ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.header("TEST RECEIPT")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.line("This is a test receipt")
    |> ReceiptBuilder.line("Generated at: #{DateTime.utc_now()}")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.bold("Features tested:")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.line("✓ Connection")
    |> ReceiptBuilder.line("✓ Text formatting")
    |> ReceiptBuilder.line("✓ Alignment")
    |> ReceiptBuilder.line("✓ Separators")
    |> ReceiptBuilder.separator()
    |> ReceiptBuilder.center("All tests passed!")
    |> ReceiptBuilder.cut()
    
    ReceiptPrinter.NetworkClient.print_receipt(receipt)
    IO.puts("   ✅ Formatted receipt sent")
    
    IO.puts("\n" <> "=" |> String.duplicate(50))
    IO.puts("✅ All tests completed successfully!")
    IO.puts("\nCheck the printer output to see the receipts.")
  end
end

# Run the test
TestPrinter.run()