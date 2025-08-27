#!/bin/bash

# Simple Receipt Printer Polling Service

API_URL="https://www.bobbby.online"
AUTH_TOKEN="bff5d349110d2f61b0d5ac83630afc687b154ddb18b70bb61362a881abdf0bcb"
PRINTER_HOST="127.0.0.1"
PRINTER_PORT="9100"
POLL_INTERVAL=30

echo "Receipt Printer Polling Service"
echo "================================"
echo "API: $API_URL"
echo "Printer: $PRINTER_HOST:$PRINTER_PORT"
echo "Poll interval: ${POLL_INTERVAL}s"
echo ""

# Function to send data to printer
send_to_printer() {
    local data="$1"
    echo "$data" | nc $PRINTER_HOST $PRINTER_PORT 2>/dev/null
    return $?
}

# Function to format receipt
format_receipt() {
    local content="$1"
    local sender_ip="$2"
    local message_id="$3"
    
    # ESC/POS commands as hex
    local ESC=$'\x1b'
    local GS=$'\x1d'
    
    # Build receipt
    printf "${ESC}@"  # Initialize
    printf "${ESC}a\x01"  # Center align
    printf "========================\n"
    printf "${ESC}!\x30"  # Double size
    printf "NEW MESSAGE\n"
    printf "${ESC}!\x00"  # Normal size
    printf "========================\n\n"
    printf "${ESC}a\x00"  # Left align
    printf "From: $sender_ip\n"
    printf "Time: $(date '+%Y-%m-%d %H:%M:%S')\n"
    printf "--------------------------------\n\n"
    printf "Message:\n"
    printf "  $content\n\n"
    printf "--------------------------------\n\n"
    printf "${ESC}a\x01"  # Center align
    printf "Thank you for your message!\n\n"
    printf "ID: MSG$(printf '%06d' $message_id)\n\n\n"
    printf "${GS}V\x42\x00"  # Partial cut
}

# Main loop
while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for messages..."
    
    # Fetch pending messages
    response=$(curl -s -H "X-Auth-Token: $AUTH_TOKEN" "$API_URL/api/receipt_messages/pending")
    
    # Check if we got a valid response
    if [ $? -ne 0 ] || [ -z "$response" ]; then
        echo "  Error fetching messages"
        sleep $POLL_INTERVAL
        continue
    fi
    
    # Parse messages using grep and sed (works on any system)
    message_count=$(echo "$response" | grep -o '"id"' | wc -l | tr -d ' ')
    
    if [ "$message_count" -gt 0 ]; then
        echo "  Found $message_count message(s)"
        
        # Extract each message (simple parsing)
        echo "$response" | tr ',' '\n' | while IFS= read -r line; do
            if echo "$line" | grep -q '"id":'; then
                msg_id=$(echo "$line" | sed 's/.*"id":\([0-9]*\).*/\1/')
            elif echo "$line" | grep -q '"content":'; then
                content=$(echo "$line" | sed 's/.*"content":"\(.*\)".*/\1/')
            elif echo "$line" | grep -q '"sender_ip":'; then
                sender_ip=$(echo "$line" | sed 's/.*"sender_ip":"\(.*\)".*/\1/')
                
                # We have all fields for this message, print it
                if [ -n "$msg_id" ] && [ -n "$content" ]; then
                    echo "  Processing message $msg_id from $sender_ip"
                    
                    # Format and send to printer
                    receipt_data=$(format_receipt "$content" "$sender_ip" "$msg_id")
                    
                    if send_to_printer "$receipt_data"; then
                        echo "    ✓ Printed successfully"
                        
                        # Mark as printed
                        curl -s -X POST \
                            -H "X-Auth-Token: $AUTH_TOKEN" \
                            "$API_URL/api/receipt_messages/$msg_id/printed" > /dev/null
                    else
                        echo "    ✗ Failed to print"
                        
                        # Mark as failed
                        curl -s -X POST \
                            -H "X-Auth-Token: $AUTH_TOKEN" \
                            "$API_URL/api/receipt_messages/$msg_id/failed" > /dev/null
                    fi
                    
                    # Reset for next message
                    msg_id=""
                    content=""
                    sender_ip=""
                    
                    sleep 1  # Small delay between prints
                fi
            fi
        done
    else
        echo "  No pending messages"
    fi
    
    sleep $POLL_INTERVAL
done