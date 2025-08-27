#!/bin/bash

set -e

echo "Receipt Printer Service Setup"
echo "=============================="
echo

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed"
    exit 1
fi

# Check if requests is installed
python3 -c "import requests" 2>/dev/null || {
    echo "Installing requests library..."
    pip3 install requests
}

# Create logs directory
mkdir -p logs

# Make the service script executable
chmod +x receipt_printer_service.py

# Generate secure token if not exists
if [ ! -f .env.receipt_printer ] || grep -q "your_secure_token_here_replace_me" .env.receipt_printer; then
    echo "Generating secure API token..."
    TOKEN=$(openssl rand -hex 32)
    sed -i '' "s/your_secure_token_here_replace_me/$TOKEN/" .env.receipt_printer
    echo "Token generated and saved to .env.receipt_printer"
    echo
    echo "IMPORTANT: Add this token to your Phoenix config:"
    echo "config :blog, :receipt_printer_api_token, \"$TOKEN\""
    echo
fi

# Load environment variables
source .env.receipt_printer

# Update plist with token
sed -i '' "s/YOUR_TOKEN_HERE/$RECEIPT_PRINTER_API_TOKEN/" com.bobbby.receipt-printer.plist

echo "Setup Options:"
echo "1. Install as LaunchAgent (runs when you log in)"
echo "2. Test run (foreground)"
echo "3. Run in background (stays until reboot)"
echo
read -p "Choose option (1-3): " option

case $option in
    1)
        echo "Installing LaunchAgent..."
        cp com.bobbby.receipt-printer.plist ~/Library/LaunchAgents/
        launchctl load ~/Library/LaunchAgents/com.bobbby.receipt-printer.plist
        echo "Service installed and started!"
        echo "To check status: launchctl list | grep receipt-printer"
        echo "To stop: launchctl unload ~/Library/LaunchAgents/com.bobbby.receipt-printer.plist"
        ;;
    2)
        echo "Starting test run..."
        echo "Press Ctrl+C to stop"
        python3 receipt_printer_service.py \
            --api-url "$API_URL" \
            --auth-token "$RECEIPT_PRINTER_API_TOKEN" \
            --printer-host "$PRINTER_HOST" \
            --printer-port "$PRINTER_PORT" \
            --poll-interval "$POLL_INTERVAL" \
            --debug
        ;;
    3)
        echo "Starting in background..."
        nohup python3 receipt_printer_service.py \
            --api-url "$API_URL" \
            --auth-token "$RECEIPT_PRINTER_API_TOKEN" \
            --printer-host "$PRINTER_HOST" \
            --printer-port "$PRINTER_PORT" \
            --poll-interval "$POLL_INTERVAL" \
            > logs/receipt-printer.log 2>&1 &
        echo "Service started with PID: $!"
        echo "Logs: tail -f logs/receipt-printer.log"
        ;;
    *)
        echo "Invalid option"
        exit 1
        ;;
esac