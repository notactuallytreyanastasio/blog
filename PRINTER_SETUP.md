# Receipt Printer Setup & Usage Guide

## 🚀 Quick Start

### 1. Start the Printer Emulator

```bash
# In terminal 1
./start_receipt_printer.sh
```

The printer will start listening on TCP port 9100 (standard receipt printer port).

### 2. Test the Connection

```bash
# In terminal 2
iex -S mix

# Test printer connection
Blog.ReceiptPrinter.MessageHandler.print_test()
```

### 3. Your Web Messages Will Now Print!

When someone submits a message through `/receipt` on your website, it will:
1. Save to the database
2. Automatically send to the printer
3. Print out as a formatted receipt

## 📋 System Architecture

```
Web User → LiveView Form → Database → Message Handler → TCP Socket → Printer Binary → Console/File
```

### Components:

1. **LiveView Form** (`lib/blog_web/live/receipt_message_live.ex`)
   - Accepts user messages
   - Captures sender IP
   - Handles image uploads

2. **Database Context** (`lib/blog/receipt_messages.ex`)
   - Stores messages
   - Triggers printing
   - Tracks status (pending/printed/failed)

3. **Message Handler** (`lib/blog/receipt_printer/message_handler.ex`)
   - Formats messages into receipts
   - Handles word wrapping
   - Adds decorative elements

4. **Network Client** (`lib/receipt_printer/network_client.ex`)
   - Sends ESC/POS commands over TCP
   - Manages printer connections

5. **Rust Printer Binary** (`receipt-printer-emulator/`)
   - Listens on port 9100
   - Parses ESC/POS commands
   - Renders receipts with formatting

## 🎨 Receipt Format

Each message prints as:

```
════════════════════════
    NEW MESSAGE
════════════════════════

From: [IP/Name]
Time: 2024-08-27 12:34:56 UTC
────────────────────────
Message:
  [User's message text
   with proper word
   wrapping]
────────────────────────
Thank you for your message!
[QR Code]
Message ID: ABC12345
```

## 🛠️ Configuration

### Environment Variables

```bash
# Printer settings (defaults shown)
export PORT=9100           # TCP port
export MODE=both          # Output: console, file, or both
export VERBOSE=1          # Enable verbose logging
```

### Start with Custom Settings

```bash
PORT=9200 MODE=file ./start_receipt_printer.sh
```

### Output Locations

- **Console**: Prints to terminal with colors and formatting
- **File**: Saves to `./printed_receipts/receipt_NNNN_timestamp.txt`

## 📝 Testing

### Run Full Test Suite

```bash
elixir test_printer.exs
```

### Manual Testing in IEx

```elixir
# Send a test message
Blog.ReceiptPrinter.MessageHandler.print_message(%{
  content: "Hello, this is a test!",
  sender_ip: "192.168.1.100",
  sender_name: "Test User"
})

# Print demo messages
Blog.ReceiptPrinter.MessageHandler.demo_messages()

# Check pending messages
Blog.ReceiptMessages.list_pending_messages()

# Print all pending
Blog.ReceiptPrinter.MessageHandler.print_queue()
```

### Direct ESC/POS Commands

```elixir
alias ReceiptPrinter.{ReceiptBuilder, NetworkClient}

receipt = ReceiptBuilder.new()
|> ReceiptBuilder.header("CUSTOM RECEIPT")
|> ReceiptBuilder.line("Your text here")
|> ReceiptBuilder.cut()

NetworkClient.print_receipt(receipt)
```

## 🔧 Troubleshooting

### Printer Not Connecting

1. Check if printer is running:
   ```bash
   ps aux | grep receipt-printer
   ```

2. Check port availability:
   ```bash
   lsof -i :9100
   ```

3. Test with netcat:
   ```bash
   echo "Test" | nc localhost 9100
   ```

### Messages Not Printing

1. Check database for pending messages:
   ```elixir
   Blog.ReceiptMessages.list_pending_messages()
   ```

2. Check logs:
   ```elixir
   # In IEx
   Logger.configure(level: :debug)
   ```

3. Manually trigger printing:
   ```elixir
   message = Blog.ReceiptMessages.get_receipt_message!(id)
   Blog.ReceiptPrinter.MessageHandler.print_message(message)
   ```

### Building Issues

If the Rust binary won't build:

```bash
cd receipt-printer-emulator
cargo clean
cargo build --release
```

## 🚀 Production Deployment

### Option 1: Systemd Service (Linux)

```bash
# Copy service file
sudo cp receipt-printer.service /etc/systemd/system/

# Edit paths in service file
sudo nano /etc/systemd/system/receipt-printer.service

# Enable and start
sudo systemctl enable receipt-printer
sudo systemctl start receipt-printer

# Check status
sudo systemctl status receipt-printer
```

### Option 2: Supervisor

Add to your supervisor config:

```ini
[program:receipt_printer]
command=/path/to/receipt-printer --port 9100 --output both
directory=/path/to/blog
autostart=true
autorestart=true
stderr_logfile=/var/log/receipt_printer.err.log
stdout_logfile=/var/log/receipt_printer.out.log
```

### Option 3: Docker

```dockerfile
FROM rust:latest
WORKDIR /app
COPY receipt-printer-emulator .
RUN cargo build --release
EXPOSE 9100
CMD ["./target/release/receipt-printer"]
```

## 📊 Monitoring

### Check Printer Status

```elixir
# Message statistics
Blog.ReceiptMessages.count_by_status()
# => %{"pending" => 5, "printed" => 42, "failed" => 1}

# Recent messages
Blog.ReceiptMessages.list_recent_messages(10)

# Clean old messages (30+ days)
Blog.ReceiptMessages.delete_old_messages(30)
```

### View Printed Receipts

```bash
# List all printed receipts
ls -la printed_receipts/

# View latest receipt
ls -t printed_receipts/*.txt | head -1 | xargs cat
```

## 🎯 Features

- ✅ Real-time message printing
- ✅ ESC/POS protocol support
- ✅ Word wrapping
- ✅ Bold, underline, alignment
- ✅ Barcodes and QR codes
- ✅ Automatic retry on failure
- ✅ Status tracking
- ✅ Image attachment indicators
- ✅ Message archiving

## 📚 API Reference

### Message Handler

- `print_message/1` - Print a message struct
- `print_text/2` - Print plain text
- `print_test/0` - Print test page
- `print_queue/0` - Print all pending
- `demo_messages/0` - Print demo receipts

### Network Client

- `print_raw/2` - Send raw ESC/POS data
- `print_receipt/2` - Send ReceiptBuilder
- `print_text/2` - Send text lines
- `test_connection/1` - Check printer status
- `batch_print/2` - Print multiple receipts

### Receipt Builder

See `/lib/receipt_printer/receipt_builder.ex` for full API.

## 🌟 Tips

1. **Auto-cut timeout**: Messages auto-cut after 3 seconds of inactivity
2. **Batch printing**: Use `batch_print/2` for multiple receipts
3. **Custom width**: Adjust with `--width` flag (default: 48 chars)
4. **Debug mode**: Use `--verbose` for detailed logging
5. **Network printers**: Change host/port in MessageHandler

## 💡 Examples

### Custom Welcome Message

```elixir
defmodule MyPrinter do
  alias ReceiptPrinter.{ReceiptBuilder, NetworkClient}
  
  def print_welcome(name) do
    ReceiptBuilder.new()
    |> ReceiptBuilder.init_printer()
    |> ReceiptBuilder.size("WELCOME", :double)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.center(name)
    |> ReceiptBuilder.blank_lines(2)
    |> ReceiptBuilder.qr_code("https://example.com/user/#{name}")
    |> ReceiptBuilder.cut()
    |> then(&NetworkClient.print_receipt/1)
  end
end
```

Enjoy your receipt printer! 🖨️