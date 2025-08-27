# Receipt Printer Emulator

This is a complete receipt printer emulation system that simulates a real network receipt printer. It consists of:

1. **Standalone Rust Binary** - Acts as the "printer hardware", listening on TCP port 9100 (standard receipt printer port)
2. **Elixir Client Library** - Sends ESC/POS commands to the printer over TCP, just like real printer drivers

## Architecture

```
Your Application
       ↓
[Elixir Client Library]
       ↓
   TCP Socket
   (Port 9100)
       ↓
[Rust Printer Binary]
       ↓
Console/File Output
```

## Setup

### 1. Build the Printer Emulator

```bash
cd receipt-printer-emulator
cargo build --release
cd ..
```

### 2. Start the Printer Emulator

Option A - Using the startup script:
```bash
./start_printer.sh [port] [output_mode] [verbose]

# Examples:
./start_printer.sh                    # Default: port 9100, console output
./start_printer.sh 9100 console       # Explicit defaults
./start_printer.sh 9100 file          # Save receipts to files
./start_printer.sh 9100 both verbose  # Console + files, verbose logging
```

Option B - Running directly:
```bash
./receipt-printer-emulator/target/release/receipt-printer --help
./receipt-printer-emulator/target/release/receipt-printer --port 9100 --verbose
```

### 3. Send Print Jobs from Elixir

```elixir
# In iex -S mix

# Test the connection
ReceiptPrinter.Demo.run_all()

# Or send individual receipts
ReceiptPrinter.Demo.demo_simple_receipt()
ReceiptPrinter.Demo.demo_restaurant_receipt()

# Custom receipt
alias ReceiptPrinter.{NetworkClient, ReceiptBuilder}

receipt = ReceiptBuilder.new()
|> ReceiptBuilder.header("MY STORE")
|> ReceiptBuilder.line("Hello World!")
|> ReceiptBuilder.separator()
|> ReceiptBuilder.item_line("Coffee", "$3.50")
|> ReceiptBuilder.total_line("TOTAL:", "$3.50", :bold)
|> ReceiptBuilder.cut()

NetworkClient.print_receipt(receipt)
```

## Features

### ESC/POS Commands Supported

- **Text Formatting**: Bold, underline, inverse, double width/height
- **Alignment**: Left, center, right
- **Paper Control**: Line feed, cut (full/partial)
- **Barcodes**: UPC-A/E, EAN13/8, Code39, Code128, ITF, Codabar
- **QR Codes**: With error correction levels
- **Special**: Cash drawer kick, initialization

### Output Modes

- **Console**: Displays receipts in the terminal with formatting
- **File**: Saves each receipt to `./receipts/receipt_NNNN_timestamp.txt`
- **Both**: Console display + file saving

### Network Protocol

The emulator listens on TCP port 9100 (configurable) and accepts raw ESC/POS command streams. It automatically detects cut commands to separate receipts, or can use a timeout-based auto-cut feature.

## How It Works

1. The Rust binary acts like a real printer, listening for connections
2. Your application connects via TCP and sends ESC/POS commands
3. The printer parses these commands and renders the receipt
4. Output appears in the console with visual formatting

This perfectly simulates having a real receipt printer connected to your computer!

## Testing

```elixir
# Test if printer is running
ReceiptPrinter.NetworkClient.test_connection()

# Send test page
ReceiptPrinter.Demo.demo_formatted_receipt()

# Send raw ESC/POS commands
alias ReceiptPrinter.EscPos

commands = [
  EscPos.init(),
  EscPos.bold(true),
  EscPos.text("TEST PRINT"),
  EscPos.line_feed(),
  EscPos.cut(:partial)
]

ReceiptPrinter.NetworkClient.print_raw(EscPos.build(commands))
```

## Customization

### Change Printer Settings

```elixir
# Connect to different port/host
opts = [host: "192.168.1.100", port: 9200]
ReceiptPrinter.NetworkClient.print_text("Hello", opts)
```

### Paper Width

Default is 48 characters. Change with:
```bash
./receipt-printer-emulator/target/release/receipt-printer --width 32
```

## Troubleshooting

1. **Connection Refused**: Make sure the printer binary is running
2. **Timeouts**: Check firewall settings for port 9100
3. **Formatting Issues**: Verify ESC/POS command sequences
4. **No Output**: Check the output mode setting (console/file/both)

## Real Printer Comparison

This emulator behaves like popular receipt printers:
- Epson TM-T88 series
- Star TSP100/TSP650
- Bixolon SRP-350

It uses the same ESC/POS protocol and TCP port (9100) that real printers use, making it perfect for development and testing without physical hardware.