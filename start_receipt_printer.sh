#!/bin/bash

# Receipt Printer Emulator - Production Startup Script
# This starts the receipt printer emulator that listens on TCP port 9100

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PRINTER_DIR="$SCRIPT_DIR/receipt-printer-emulator"
BINARY="$PRINTER_DIR/target/release/receipt-printer"
RECEIPTS_DIR="$SCRIPT_DIR/printed_receipts"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}    Receipt Printer Emulator - Starting    ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

# Check if Rust/cargo is installed
if ! command -v cargo &> /dev/null; then
    echo -e "${RED}Error: Cargo is not installed.${NC}"
    echo "Please install Rust from https://rustup.rs/"
    exit 1
fi

# Build the printer emulator if needed
if [ ! -f "$BINARY" ]; then
    echo -e "${YELLOW}Binary not found. Building receipt printer emulator...${NC}"
    cd "$PRINTER_DIR"
    cargo build --release
    cd "$SCRIPT_DIR"
    echo -e "${GREEN}✓ Build completed${NC}"
    echo ""
fi

# Create receipts directory
mkdir -p "$RECEIPTS_DIR"

# Parse command line arguments
PORT=${PORT:-9100}
MODE=${MODE:-both}  # console, file, or both
VERBOSE=${VERBOSE:-}

# Show configuration
echo -e "${GREEN}Configuration:${NC}"
echo -e "  Port:        ${YELLOW}$PORT${NC}"
echo -e "  Output Mode: ${YELLOW}$MODE${NC}"
echo -e "  Output Dir:  ${YELLOW}$RECEIPTS_DIR${NC}"
echo -e "  Verbose:     ${YELLOW}${VERBOSE:-No}${NC}"
echo ""
echo -e "${GREEN}The printer is ready to receive print jobs on TCP port $PORT${NC}"
echo -e "${BLUE}You can now run your Elixir application and print receipts!${NC}"
echo ""
echo -e "To test from Elixir:"
echo -e "  ${YELLOW}iex -S mix${NC}"
echo -e "  ${YELLOW}Blog.ReceiptPrinter.MessageHandler.print_test()${NC}"
echo ""
echo -e "${RED}Press Ctrl+C to stop the printer${NC}"
echo -e "${BLUE}────────────────────────────────────────────${NC}"
echo ""

# Trap Ctrl+C to show a nice message
trap 'echo -e "\n${YELLOW}Printer stopped.${NC}"; exit 0' INT

# Run the printer emulator
VERBOSE_FLAG=""
if [ -n "$VERBOSE" ]; then
    VERBOSE_FLAG="--verbose"
fi

"$BINARY" \
    --port "$PORT" \
    --output "$MODE" \
    --output-dir "$RECEIPTS_DIR" \
    --auto-cut-timeout 3 \
    --width 48 \
    $VERBOSE_FLAG