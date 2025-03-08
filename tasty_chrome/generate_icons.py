#!/usr/bin/env python3
"""
Generate PNG icons from SVG for Chrome extension
"""

import os
import subprocess
from pathlib import Path

# Sizes needed for Chrome extension
ICON_SIZES = [16, 32, 48, 128]

def main():
    """Generate icons in different sizes from SVG"""
    script_dir = Path(__file__).parent
    images_dir = script_dir / "images"
    svg_path = images_dir / "icon.svg"

    if not svg_path.exists():
        print(f"Error: SVG file not found at {svg_path}")
        return

    for size in ICON_SIZES:
        output_path = images_dir / f"icon{size}.png"
        print(f"Generating {output_path}...")

        try:
            if os.name == 'nt':  # Windows
                # For Windows, you might need ImageMagick installed
                subprocess.run([
                    "magick",
                    "convert",
                    "-background", "none",
                    "-size", f"{size}x{size}",
                    str(svg_path),
                    str(output_path)
                ], check=True)
            else:  # macOS/Linux
                # Try using native macOS tools first
                try:
                    subprocess.run([
                        "sips",
                        "-z", str(size), str(size),
                        "-s", "format", "png",
                        str(svg_path),
                        "--out", str(output_path)
                    ], check=True)
                except (subprocess.SubprocessError, FileNotFoundError):
                    # Fallback to convert if available (requires ImageMagick)
                    subprocess.run([
                        "convert",
                        "-background", "none",
                        "-size", f"{size}x{size}",
                        str(svg_path),
                        str(output_path)
                    ], check=True)

            print(f"✓ Generated {output_path}")
        except (subprocess.SubprocessError, FileNotFoundError) as e:
            print(f"Error generating {output_path}: {e}")
            print("Make sure you have ImageMagick installed for image conversion.")

    print("\nIcon generation complete!")
    print("You can install ImageMagick with:")
    print("- macOS: brew install imagemagick")
    print("- Linux: sudo apt install imagemagick")
    print("- Windows: Download from https://imagemagick.org/script/download.php")

if __name__ == "__main__":
    main()