defmodule Blog.ThermalPrinter.ImageProcessor do
  @moduledoc """
  Image processing module for thermal printer output.
  Handles dithering and format conversion for Epson TM-M50-012 printer.
  """

  import Bitwise
  require Logger

  @doc """
  Process an uploaded image binary for thermal printing.
  Returns dithered binary data ready for the printer.
  """
  def process_image(image_binary, opts \\ []) do
    target_width = Keyword.get(opts, :width, 384)  # Standard 58mm thermal printer width
    
    with {:ok, pixels, width, height} <- decode_image(image_binary),
         {:ok, resized} <- resize_image(pixels, width, height, target_width),
         {:ok, grayscale} <- convert_to_grayscale(resized),
         {:ok, dithered} <- apply_floyd_steinberg_dithering(grayscale) do
      {:ok, dithered}
    end
  end

  defp decode_image(binary) do
    # Parse PNG/JPEG header to extract dimensions and pixel data
    case detect_format(binary) do
      :png -> decode_png(binary)
      :jpeg -> decode_jpeg(binary)
      _ -> {:error, "Unsupported image format"}
    end
  end

  defp detect_format(<<0x89, 0x50, 0x4E, 0x47, _rest::binary>>), do: :png
  defp detect_format(<<0xFF, 0xD8, 0xFF, _rest::binary>>), do: :jpeg
  defp detect_format(_), do: :unknown

  defp decode_png(binary) do
    # Simple PNG decoder - we'll use Erlang's :zlib for decompression
    # This is a simplified version - real implementation would need full PNG parsing
    try do
      # Skip PNG signature (8 bytes)
      <<_signature::binary-size(8), chunks::binary>> = binary
      
      # Parse IHDR chunk to get dimensions
      <<_length::32, "IHDR", width::32, height::32, _rest::binary>> = chunks
      
      # For now, return placeholder data
      # In production, you'd properly parse IDAT chunks and decompress
      pixels = generate_placeholder_pixels(width, height)
      {:ok, pixels, width, height}
    rescue
      _ -> {:error, "Failed to decode PNG"}
    end
  end

  defp decode_jpeg(_binary) do
    # JPEG decoding is complex - for MVP we'll use a simpler approach
    # Consider using NIFs or Ports for actual JPEG decoding if needed
    {:error, "JPEG decoding not yet implemented - use PNG for now"}
  end

  defp generate_placeholder_pixels(width, height) do
    # Generate random grayscale pixels for testing
    for _ <- 1..(width * height) do
      :rand.uniform(256) - 1
    end
  end

  defp resize_image(pixels, width, height, target_width) do
    # Calculate target height maintaining aspect ratio
    target_height = round(height * target_width / width)
    
    # Simple nearest-neighbor scaling
    resized = for y <- 0..(target_height - 1), x <- 0..(target_width - 1) do
      src_x = round(x * width / target_width)
      src_y = round(y * height / target_height)
      src_index = src_y * width + src_x
      Enum.at(pixels, src_index, 0)
    end
    
    {:ok, %{pixels: resized, width: target_width, height: target_height}}
  end

  defp convert_to_grayscale(%{pixels: pixels} = image) when is_list(pixels) do
    # Already grayscale if pixels are single values
    {:ok, image}
  end

  defp convert_to_grayscale(%{pixels: pixels, width: width, height: height}) do
    # Convert RGB to grayscale using luminance formula
    grayscale = Enum.map(pixels, fn
      {r, g, b} -> round(0.299 * r + 0.587 * g + 0.114 * b)
      pixel when is_integer(pixel) -> pixel
    end)
    
    {:ok, %{pixels: grayscale, width: width, height: height}}
  end

  @doc """
  Apply Floyd-Steinberg dithering algorithm to grayscale image
  """
  def apply_floyd_steinberg_dithering(%{pixels: pixels, width: width, height: height}) do
    # Convert list to array for efficient random access
    pixel_array = :array.from_list(pixels)
    
    # Process each pixel
    dithered = Enum.reduce(0..(height - 1), pixel_array, fn y, acc ->
      Enum.reduce(0..(width - 1), acc, fn x, acc2 ->
        index = y * width + x
        
        # Get current pixel value
        old_pixel = :array.get(index, acc2)
        
        # Threshold to black or white
        new_pixel = if old_pixel < 128, do: 0, else: 255
        
        # Calculate error
        error = old_pixel - new_pixel
        
        # Update current pixel
        acc3 = :array.set(index, new_pixel, acc2)
        
        # Distribute error to neighboring pixels
        acc3
        |> distribute_error(x + 1, y, width, height, error * 7 / 16)      # Right
        |> distribute_error(x - 1, y + 1, width, height, error * 3 / 16)  # Bottom-left
        |> distribute_error(x, y + 1, width, height, error * 5 / 16)      # Bottom
        |> distribute_error(x + 1, y + 1, width, height, error * 1 / 16)  # Bottom-right
      end)
    end)
    
    # Convert back to list and then to binary (1-bit per pixel)
    final_pixels = :array.to_list(dithered)
    binary_data = pixels_to_binary(final_pixels, width)
    
    {:ok, %{data: binary_data, width: width, height: height}}
  end

  defp distribute_error(array, x, y, width, height, error) when x >= 0 and x < width and y >= 0 and y < height do
    index = y * width + x
    old_value = :array.get(index, array)
    new_value = clamp(round(old_value + error), 0, 255)
    :array.set(index, new_value, array)
  end

  defp distribute_error(array, _, _, _, _, _), do: array

  defp clamp(value, min, max) do
    value
    |> max(min)
    |> min(max)
  end

  @doc """
  Convert pixel array to binary format for thermal printer.
  Each byte represents 8 horizontal pixels (1 bit per pixel).
  """
  def pixels_to_binary(pixels, _width) do
    pixels
    |> Enum.chunk_every(8, 8, [0, 0, 0, 0, 0, 0, 0, 0])
    |> Enum.map(fn chunk ->
      Enum.reduce(Enum.with_index(chunk), 0, fn {pixel, idx}, acc ->
        bit = if pixel > 127, do: 1, else: 0
        acc ||| (bit <<< (7 - idx))
      end)
    end)
    |> :binary.list_to_bin()
  end

  @doc """
  Format the dithered image for ESC/POS printing commands.
  Returns binary data with proper printer commands.
  """
  def format_for_escpos(%{data: data, width: width, height: height}) do
    # ESC * m nL nH [d1...dk]
    # m = 33 (24-dot double density)
    # nL = width low byte
    # nH = width high byte
    
    width_bytes = div(width, 8)
    commands = []
    
    # Initialize printer
    commands = [<<0x1B, 0x40>> | commands]  # ESC @ (Initialize)
    
    # Set line spacing to 24 dots
    commands = [<<0x1B, 0x33, 24>> | commands]  # ESC 3 n
    
    # Send image data line by line
    image_lines = for y <- 0..(height - 1) do
      start_idx = y * width_bytes
      line_data = binary_part(data, start_idx, width_bytes)
      
      # ESC * m nL nH [data]
      <<0x1B, 0x2A, 33, width_bytes::little-16, line_data::binary, 0x0A>>
    end
    
    # Reset line spacing
    commands = commands ++ image_lines ++ [<<0x1B, 0x32>>]  # ESC 2 (default spacing)
    
    # Cut paper
    commands = commands ++ [<<0x1D, 0x56, 0x42, 0x00>>]  # GS V m n
    
    {:ok, IO.iodata_to_binary(commands)}
  end
end