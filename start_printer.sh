#!/bin/bash

# Receipt Printer Emulator Startup Script

echo "🖨️  Starting Receipt Printer Emulator..."
echo ""

# Check if the binary exists
if [ ! -f "receipt-printer-emulator/target/release/receipt-printer" ]; then
    echo "Binary not found. Building..."
    cd receipt-printer-emulator
    cargo build --release
    cd ..
fi

# Parse arguments
PORT=${1:-9100}
OUTPUT=${2:-console}
VERBOSE=""

if [ "$3" == "verbose" ]; then
    VERBOSE="--verbose"
fi

echo "Configuration:"
echo "  Port: $PORT"
echo "  Output: $OUTPUT"
echo "  Verbose: ${VERBOSE:-no}"
echo ""
echo "Press Ctrl+C to stop the printer emulator"
echo ""

# Run the printer emulator
./receipt-printer-emulator/target/release/receipt-printer \
    --port $PORT \
    --output $OUTPUT \
    --auto-cut-timeout 2 \
    $VERBOSE