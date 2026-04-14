they#!/usr/bin/env python3
"""
Receipt Printer Interface for EPSON TM-m50
Handles text formatting, word wrapping, and printing
"""

import subprocess
import textwrap
import sys
import struct
from typing import Optional, Union, Tuple
from PIL import Image, ImageOps
from pathlib import Path
import io

class ReceiptPrinter:
    def __init__(self, printer_name: str = "TM_m50", width: int = 42):
        """
        Initialize the receipt printer interface.
        
        Args:
            printer_name: Name of the printer in CUPS
            width: Number of characters per line (TM-m50 default is ~42 for normal font)
        """
        self.printer_name = printer_name
        self.width = width
        
        # ESC/POS commands
        self.ESC = b'\x1b'
        self.GS = b'\x1d'
        
        # Text formatting commands
        self.INIT = self.ESC + b'@'  # Initialize printer
        self.ALIGN_LEFT = self.ESC + b'a\x00'
        self.ALIGN_CENTER = self.ESC + b'a\x01'
        self.ALIGN_RIGHT = self.ESC + b'a\x02'
        
        # Font styles
        self.FONT_NORMAL = self.ESC + b'!\x00'
        self.FONT_BOLD = self.ESC + b'!\x08'
        self.FONT_DOUBLE_HEIGHT = self.ESC + b'!\x10'
        self.FONT_DOUBLE_WIDTH = self.ESC + b'!\x20'
        self.FONT_DOUBLE = self.ESC + b'!\x30'
        
        # Paper commands
        self.CUT_PAPER = self.GS + b'V\x42\x00'  # Feed and cut
        self.FEED_LINE = b'\n'
        
        # Image printing parameters
        self.image_width = 640  # TM-m50 full width (80mm at 203dpi)
    
    def wrap_text(self, text: str, width: Optional[int] = None) -> str:
        """
        Wrap text to fit receipt width, preserving existing line breaks.
        
        Args:
            text: Input text to wrap
            width: Optional custom width (uses self.width if not specified)
        
        Returns:
            Wrapped text with proper line breaks
        """
        if width is None:
            width = self.width
        
        wrapped_lines = []
        
        # Process each line separately to preserve intentional line breaks
        for line in text.split('\n'):
            if line.strip() == '':
                # Preserve empty lines
                wrapped_lines.append('')
            elif len(line) <= width:
                # Line fits within width
                wrapped_lines.append(line)
            else:
                # Wrap long lines
                wrapped = textwrap.fill(line, width=width, break_long_words=False)
                wrapped_lines.extend(wrapped.split('\n'))
        
        return '\n'.join(wrapped_lines)
    
    def format_receipt(self, text: str, title: Optional[str] = None, 
                      center_title: bool = True, add_cuts: bool = True) -> bytes:
        """
        Format text for receipt printing with optional title and formatting.
        
        Args:
            text: Main text content
            title: Optional title to print in larger font
            center_title: Whether to center the title
            add_cuts: Whether to add paper cut command at the end
        
        Returns:
            Formatted bytes ready for printing
        """
        output = self.INIT  # Initialize printer
        
        # Add title if provided
        if title:
            if center_title:
                output += self.ALIGN_CENTER
                output += self.FONT_DOUBLE
                # Wrap title with adjusted width for double-width font
                wrapped_title = self.wrap_text(title, width=self.width // 2)
                output += wrapped_title.encode('utf-8')
                output += self.FEED_LINE * 2
                output += self.ALIGN_LEFT
            else:
                output += self.FONT_BOLD
                output += title.encode('utf-8')
                output += self.FEED_LINE * 2
            
            output += self.FONT_NORMAL
        
        # Process main text
        wrapped_text = self.wrap_text(text)
        output += wrapped_text.encode('utf-8')
        
        # Add some line feeds before cutting
        if add_cuts:
            output += self.FEED_LINE * 4
            output += self.CUT_PAPER
        else:
            output += self.FEED_LINE * 2
        
        return output
    
    def print_text(self, text: str, title: Optional[str] = None, 
                   center_title: bool = True, add_cuts: bool = True) -> bool:
        """
        Print formatted text to the receipt printer.
        
        Args:
            text: Text to print
            title: Optional title
            center_title: Whether to center the title
            add_cuts: Whether to cut the paper after printing
        
        Returns:
            True if printing succeeded, False otherwise
        """
        try:
            # Format the receipt
            formatted_data = self.format_receipt(text, title, center_title, add_cuts)
            
            # Send to printer using lp command with raw option
            process = subprocess.Popen(
                ['lp', '-d', self.printer_name, '-o', 'raw'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            stdout, stderr = process.communicate(formatted_data)
            
            if process.returncode == 0:
                print(f"Printed successfully: {stdout.decode().strip()}")
                return True
            else:
                print(f"Printing failed: {stderr.decode().strip()}")
                return False
                
        except Exception as e:
            print(f"Error printing: {e}")
            return False
    
    def process_image(self, image_path: Union[str, Path, Image.Image], 
                     width: Optional[int] = None,
                     dither_method: str = 'floyd_steinberg',
                     threshold: int = 128) -> Image.Image:
        """
        Process an image for thermal printing with dithering.
        
        Args:
            image_path: Path to image file or PIL Image object
            width: Target width in pixels (defaults to printer width)
            dither_method: 'floyd_steinberg', 'ordered', 'threshold', or 'none'
            threshold: Threshold value for simple threshold method (0-255)
        
        Returns:
            Processed 1-bit PIL Image
        """
        if width is None:
            width = self.image_width
        
        # Load image if path provided
        if isinstance(image_path, (str, Path)):
            img = Image.open(image_path)
        else:
            img = image_path
        
        # Convert to RGB if necessary (handles RGBA, etc.)
        if img.mode not in ('L', '1'):
            img = img.convert('RGB')
        
        # Calculate height maintaining aspect ratio
        aspect_ratio = img.height / img.width
        new_height = int(width * aspect_ratio)
        
        # Resize image
        img = img.resize((width, new_height), Image.Resampling.LANCZOS)
        
        # Convert to grayscale if not already
        if img.mode != 'L':
            img = img.convert('L')
        
        # Apply dithering
        if dither_method == 'floyd_steinberg':
            # Floyd-Steinberg dithering (default PIL method)
            img = img.convert('1', dither=Image.Dither.FLOYDSTEINBERG)
        elif dither_method == 'ordered':
            # Ordered dithering (Bayer matrix)
            img = self._ordered_dither(img)
        elif dither_method == 'threshold':
            # Simple threshold
            img = img.point(lambda x: 255 if x > threshold else 0, mode='1')
        elif dither_method == 'none':
            # No dithering, just convert to 1-bit
            img = img.convert('1', dither=Image.Dither.NONE)
        else:
            raise ValueError(f"Unknown dither method: {dither_method}")
        
        return img
    
    def _ordered_dither(self, img: Image.Image) -> Image.Image:
        """
        Apply ordered (Bayer) dithering to an image.
        """
        # 4x4 Bayer dithering matrix
        bayer_matrix = [
            [0, 8, 2, 10],
            [12, 4, 14, 6],
            [3, 11, 1, 9],
            [15, 7, 13, 5]
        ]
        
        # Scale matrix to 0-255 range
        bayer_matrix = [[val * 17 for val in row] for row in bayer_matrix]
        
        width, height = img.size
        result = Image.new('1', (width, height))
        pixels = result.load()
        img_pixels = img.load()
        
        for y in range(height):
            for x in range(width):
                threshold = bayer_matrix[y % 4][x % 4]
                pixels[x, y] = 255 if img_pixels[x, y] > threshold else 0
        
        return result
    
    def image_to_esc_pos(self, img: Image.Image) -> bytes:
        """
        Convert a 1-bit PIL Image to ESC/POS bitmap commands.
        
        Args:
            img: 1-bit PIL Image
        
        Returns:
            Bytes containing ESC/POS commands for printing the image
        """
        if img.mode != '1':
            raise ValueError("Image must be 1-bit (mode '1')")
        
        width, height = img.size
        
        # Ensure width is multiple of 8
        if width % 8 != 0:
            new_width = (width // 8 + 1) * 8
            new_img = Image.new('1', (new_width, height), 255)
            new_img.paste(img, (0, 0))
            img = new_img
            width = new_width
        
        # Initialize command with center alignment
        command = self.INIT + self.ALIGN_CENTER
        
        # Use GS v 0 command (raster bit image)
        # Format: GS v 0 m xL xH yL yH [image data]
        # m = 0 (normal), 1 (double width), 2 (double height), 3 (double both)
        m = 0  # Normal size
        xL = (width // 8) % 256
        xH = (width // 8) // 256
        yL = height % 256
        yH = height // 256
        
        command += self.GS + b'v0' + bytes([m, xL, xH, yL, yH])
        
        # Convert image to bytes
        pixels = img.load()
        for y in range(height):
            row_data = bytearray()
            for x in range(0, width, 8):
                byte = 0
                for bit in range(8):
                    if x + bit < width:
                        # Invert: black pixels (0) should print
                        if pixels[x + bit, y] == 0:
                            byte |= (1 << (7 - bit))
                row_data.append(byte)
            command += bytes(row_data)
        
        # Reset alignment
        command += self.ALIGN_LEFT
        
        return command
    
    def print_image(self, image_path: Union[str, Path, Image.Image],
                   width: Optional[int] = None,
                   dither_method: str = 'floyd_steinberg',
                   threshold: int = 128,
                   add_cuts: bool = True) -> bool:
        """
        Print an image on the receipt printer.
        
        Args:
            image_path: Path to image file or PIL Image object
            width: Target width in pixels
            dither_method: Dithering method to use
            threshold: Threshold for simple threshold method
            add_cuts: Whether to cut paper after printing
        
        Returns:
            True if successful, False otherwise
        """
        try:
            # Process the image
            processed_img = self.process_image(
                image_path, width, dither_method, threshold
            )
            
            # Convert to ESC/POS commands
            image_data = self.image_to_esc_pos(processed_img)
            
            # Add paper feed and optional cut
            if add_cuts:
                image_data += self.FEED_LINE * 4 + self.CUT_PAPER
            else:
                image_data += self.FEED_LINE * 2
            
            # Send to printer
            process = subprocess.Popen(
                ['lp', '-d', self.printer_name, '-o', 'raw'],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            
            stdout, stderr = process.communicate(image_data)
            
            if process.returncode == 0:
                print(f"Image printed successfully: {stdout.decode().strip()}")
                return True
            else:
                print(f"Image printing failed: {stderr.decode().strip()}")
                return False
                
        except Exception as e:
            print(f"Error printing image: {e}")
            return False
    
    def print_separator(self, char: str = '-', width: Optional[int] = None):
        """Print a separator line."""
        if width is None:
            width = self.width
        self.print_text(char * width, add_cuts=False)


def main():
    """Example usage and command-line interface."""
    
    # Create printer instance
    printer = ReceiptPrinter("TM_m50", width=42)
    
    if len(sys.argv) > 1:
        # Check if it's an image file
        arg = sys.argv[1]
        if arg.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff')):
            # Print image
            dither_method = sys.argv[2] if len(sys.argv) > 2 else 'floyd_steinberg'
            print(f"Printing image: {arg} with {dither_method} dithering")
            printer.print_image(arg, dither_method=dither_method)
        else:
            # If text provided as command-line argument
            text = ' '.join(sys.argv[1:])
            printer.print_text(text)
    else:
        # Example receipt
        sample_text = """
Welcome to Our Store!

Order #1234
Date: 2024-01-15 14:30

Items:
- Cappuccino (Large)         $4.50
- Blueberry Muffin          $3.25
- Chicken Sandwich          $8.95
  Extra cheese              $1.00

This is a very long line that should wrap properly without breaking words in awkward places when printed on the receipt.

Subtotal:                  $17.70
Tax (8%):                   $1.42
===============================
Total:                     $19.12

Payment: Credit Card ****1234
Approved

Thank you for your visit!
Please come again soon.

Contact us at: (555) 123-4567
www.ourstore.com
        """
        
        printer.print_text(sample_text.strip(), title="RECEIPT", center_title=True)


if __name__ == "__main__":
    main()
