#!/usr/bin/env python3
"""
Receipt Printer Polling Service
Polls the blog API for pending messages and prints them locally
"""

import json
import time
import socket
import requests
import logging
import argparse
import sys
from datetime import datetime
from typing import Optional, Dict, List
import os
from pathlib import Path

# Hardcoded API key for receipt printer authentication
RECEIPT_PRINTER_API_KEY = "67656cfac9eea273fed7a403088874506ab41b700056d01f660537e2be7316f4"

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


class ReceiptPrinterService:
    def __init__(self, api_url: str, auth_token: str, printer_host: str = "127.0.0.1", 
                 printer_port: int = 9100, poll_interval: int = 10):
        self.api_url = api_url.rstrip('/')
        self.auth_token = auth_token
        self.printer_host = printer_host
        self.printer_port = printer_port
        self.poll_interval = poll_interval
        self.session = requests.Session()
        self.session.headers.update({
            'X-Auth-Token': auth_token,
            'Content-Type': 'application/json'
        })
        
    def fetch_pending_messages(self) -> List[Dict]:
        """Fetch pending messages from the API"""
        try:
            response = self.session.get(f"{self.api_url}/api/receipt_messages/pending")
            response.raise_for_status()
            data = response.json()
            return data.get('messages', [])
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to fetch messages: {e}")
            return []
    
    def mark_message_printed(self, message_id: int) -> bool:
        """Mark a message as printed in the API"""
        try:
            response = self.session.post(
                f"{self.api_url}/api/receipt_messages/{message_id}/printed"
            )
            response.raise_for_status()
            return True
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to mark message {message_id} as printed: {e}")
            return False
    
    def mark_message_failed(self, message_id: int) -> bool:
        """Mark a message as failed in the API"""
        try:
            response = self.session.post(
                f"{self.api_url}/api/receipt_messages/{message_id}/failed"
            )
            response.raise_for_status()
            return True
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to mark message {message_id} as failed: {e}")
            return False
    
    def format_receipt(self, message: Dict) -> bytes:
        """Format a message as ESC/POS receipt data"""
        ESC = b'\x1b'
        GS = b'\x1d'
        
        # Initialize printer
        commands = ESC + b'@'  # Initialize
        
        # Header
        commands += ESC + b'a\x01'  # Center align
        commands += b'=' * 24 + b'\n'
        commands += ESC + b'!\x30'  # Double height/width
        commands += b'NEW MESSAGE\n'
        commands += ESC + b'!\x00'  # Normal size
        commands += b'=' * 24 + b'\n\n'
        
        # Metadata
        commands += ESC + b'a\x00'  # Left align
        sender_text = f"From: {message.get('sender_name') or message.get('sender_ip', 'Unknown')}\n"
        commands += sender_text.encode('utf-8')
        
        timestamp = message.get('created_at', '')
        if timestamp:
            try:
                dt = datetime.fromisoformat(timestamp.replace('Z', '+00:00'))
                time_text = f"Time: {dt.strftime('%Y-%m-%d %H:%M:%S UTC')}\n"
                commands += time_text.encode('utf-8')
            except:
                pass
        
        commands += b'-' * 48 + b'\n\n'
        
        # Message content
        commands += b'Message:\n'
        content = message.get('content', '')
        
        # Word wrap at 48 characters
        wrapped_lines = self.wrap_text(content, 44)
        for line in wrapped_lines:
            commands += b'  ' + line.encode('utf-8') + b'\n'
        
        commands += b'\n'
        
        # Image indicator
        if message.get('image_url'):
            commands += b'-' * 48 + b'\n'
            commands += ESC + b'a\x01'  # Center
            commands += b'[Image Attached]\n'
            commands += ESC + b'a\x00'  # Left
            commands += b'\n'
        
        # Footer
        commands += b'-' * 48 + b'\n\n'
        commands += ESC + b'a\x01'  # Center
        commands += b'Thank you for your message!\n\n'
        
        # Message ID
        message_id = f"ID: MSG{message.get('id', 0):06d}\n"
        commands += message_id.encode('utf-8')
        
        # Cut paper
        commands += b'\n' * 3
        commands += GS + b'V\x42\x00'  # Partial cut
        
        return commands
    
    def wrap_text(self, text: str, width: int) -> List[str]:
        """Word wrap text to specified width"""
        lines = []
        for paragraph in text.split('\n'):
            if not paragraph:
                lines.append('')
                continue
                
            words = paragraph.split()
            current_line = ''
            
            for word in words:
                if not current_line:
                    current_line = word
                elif len(current_line) + 1 + len(word) <= width:
                    current_line += ' ' + word
                else:
                    lines.append(current_line)
                    current_line = word
            
            if current_line:
                lines.append(current_line)
        
        return lines
    
    def print_to_printer(self, data: bytes) -> bool:
        """Send data to the printer via TCP"""
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
                sock.settimeout(5)
                sock.connect((self.printer_host, self.printer_port))
                sock.sendall(data)
                logger.info(f"Successfully sent {len(data)} bytes to printer")
                return True
        except Exception as e:
            logger.error(f"Failed to print: {e}")
            return False
    
    def process_message(self, message: Dict) -> bool:
        """Process a single message"""
        message_id = message.get('id')
        logger.info(f"Processing message {message_id} from {message.get('sender_ip')}")
        
        # Format receipt
        receipt_data = self.format_receipt(message)
        
        # Save to file for debugging
        debug_dir = Path("printed_receipts")
        debug_dir.mkdir(exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        debug_file = debug_dir / f"receipt_{message_id}_{timestamp}.bin"
        with open(debug_file, 'wb') as f:
            f.write(receipt_data)
        logger.debug(f"Saved receipt to {debug_file}")
        
        # Print
        if self.print_to_printer(receipt_data):
            logger.info(f"Successfully printed message {message_id}")
            self.mark_message_printed(message_id)
            return True
        else:
            logger.error(f"Failed to print message {message_id}")
            self.mark_message_failed(message_id)
            return False
    
    def run(self):
        """Main polling loop"""
        logger.info(f"Starting receipt printer service")
        logger.info(f"API URL: {self.api_url}")
        logger.info(f"Printer: {self.printer_host}:{self.printer_port}")
        logger.info(f"Poll interval: {self.poll_interval} seconds")
        
        while True:
            try:
                messages = self.fetch_pending_messages()
                
                if messages:
                    logger.info(f"Found {len(messages)} pending message(s)")
                    for message in messages:
                        self.process_message(message)
                        time.sleep(1)  # Small delay between prints
                
                time.sleep(self.poll_interval)
                
            except KeyboardInterrupt:
                logger.info("Service stopped by user")
                break
            except Exception as e:
                logger.error(f"Unexpected error: {e}")
                time.sleep(self.poll_interval)


def main():
    parser = argparse.ArgumentParser(description='Receipt Printer Polling Service')
    parser.add_argument('--api-url', default='https://www.bobbby.online',
                        help='Blog API URL')
    parser.add_argument('--auth-token', required=False,
                        help='API authentication token')
    parser.add_argument('--printer-host', default='127.0.0.1',
                        help='Printer host/IP')
    parser.add_argument('--printer-port', type=int, default=9100,
                        help='Printer port')
    parser.add_argument('--poll-interval', type=int, default=10,
                        help='Polling interval in seconds')
    parser.add_argument('--debug', action='store_true',
                        help='Enable debug logging')
    parser.add_argument('--print-text', type=str,
                        help='Print text directly without using API')
    parser.add_argument('--api-key', type=str,
                        help='API key for authentication')
    
    args = parser.parse_args()
    
    if args.debug:
        logging.getLogger().setLevel(logging.DEBUG)
    
    # Direct print mode - print text and exit
    if args.print_text:
        # Verify API key for direct printing
        if args.api_key != RECEIPT_PRINTER_API_KEY:
            logger.error("Invalid API key for direct printing")
            sys.exit(1)
        
        service = ReceiptPrinterService(
            api_url=args.api_url,
            auth_token='dummy',  # Not needed for direct printing
            printer_host=args.printer_host,
            printer_port=args.printer_port,
            poll_interval=args.poll_interval
        )
        
        # Create a simple message structure for direct printing
        message = {
            'id': int(time.time()),  # Use integer for ID
            'content': args.print_text,
            'sender_name': 'Direct Print',
            'created_at': datetime.now().isoformat()
        }
        
        # Format and print the receipt
        receipt_data = service.format_receipt(message)
        if service.print_to_printer(receipt_data):
            logger.info("Successfully printed text")
            sys.exit(0)
        else:
            logger.error("Failed to print text")
            sys.exit(1)
    
    # Normal polling mode
    if not args.auth_token:
        parser.error("--auth-token is required when not using --print-text")
    
    service = ReceiptPrinterService(
        api_url=args.api_url,
        auth_token=args.auth_token,
        printer_host=args.printer_host,
        printer_port=args.printer_port,
        poll_interval=args.poll_interval
    )
    
    try:
        service.run()
    except Exception as e:
        logger.error(f"Service failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()