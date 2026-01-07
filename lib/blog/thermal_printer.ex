defmodule Blog.ThermalPrinter do
  @moduledoc """
  Main interface for thermal printer functionality.
  Handles image processing and printing for Epson TM-M50-012.
  """

  import Bitwise
  alias Blog.ThermalPrinter.{ImageProcessor, SimplePNG}

  @doc """
  Process an uploaded image from LiveView and prepare it for printing.
  
  ## Examples
  
      # From a LiveView upload
      {:ok, dithered} = Blog.ThermalPrinter.process_upload(upload_entry)
      
      # From raw binary data
      {:ok, dithered} = Blog.ThermalPrinter.process_image(image_binary)
  """
  def process_upload(upload_entry) do
    consume_uploaded_entry(upload_entry, fn %{path: path} ->
      binary = File.read!(path)
      process_image(binary)
    end)
  end

  def process_image(image_binary, opts \\ []) do
    width = Keyword.get(opts, :width, 384)
    
    with {:ok, pixels, orig_width, orig_height} <- decode_image(image_binary),
         {:ok, processed} <- process_pixels(pixels, orig_width, orig_height, width),
         {:ok, commands} <- ImageProcessor.format_for_escpos(processed) do
      {:ok, commands}
    end
  end

  @doc """
  Get a preview of the dithered image as a data URL for display in the browser.
  """
  def get_preview(image_binary, opts \\ []) do
    width = Keyword.get(opts, :width, 384)
    
    with {:ok, pixels, orig_width, orig_height} <- decode_image(image_binary),
         {:ok, processed} <- process_pixels(pixels, orig_width, orig_height, width) do
      # Convert to base64 data URL for preview
      preview_data = create_preview_png(processed)
      {:ok, "data:image/png;base64,#{Base.encode64(preview_data)}"}
    end
  end

  defp decode_image(binary) do
    case detect_format(binary) do
      :png -> SimplePNG.decode(binary)
      :jpeg -> {:error, "JPEG not yet supported - please use PNG"}
      _ -> {:error, "Unsupported image format"}
    end
  end

  defp detect_format(<<0x89, 0x50, 0x4E, 0x47, _rest::binary>>), do: :png
  defp detect_format(<<0xFF, 0xD8, 0xFF, _rest::binary>>), do: :jpeg
  defp detect_format(_), do: :unknown

  defp process_pixels(pixels, width, height, target_width) do
    # Calculate target height maintaining aspect ratio
    target_height = round(height * target_width / width)
    
    # Resize
    resized = resize_pixels(pixels, width, height, target_width, target_height)
    
    # Apply dithering
    ImageProcessor.apply_floyd_steinberg_dithering(%{
      pixels: resized,
      width: target_width,
      height: target_height
    })
  end

  defp resize_pixels(pixels, src_width, src_height, dst_width, dst_height) do
    for y <- 0..(dst_height - 1), x <- 0..(dst_width - 1) do
      src_x = min(round(x * src_width / dst_width), src_width - 1)
      src_y = min(round(y * src_height / dst_height), src_height - 1)
      src_index = src_y * src_width + src_x
      Enum.at(pixels, src_index, 0)
    end
  end

  defp create_preview_png(%{data: data, width: width, height: height}) do
    # Convert 1-bit data back to 8-bit grayscale for preview
    pixels = data
             |> :binary.bin_to_list()
             |> Enum.flat_map(fn byte ->
               for bit <- 7..0//-1 do
                 if (byte &&& (1 <<< bit)) != 0, do: 255, else: 0
               end
             end)
             |> Enum.take(width * height)
    
    # Create a simple grayscale PNG
    # This is a minimal implementation - consider using a library for production
    create_minimal_png(pixels, width, height)
  end

  defp create_minimal_png(_pixels, _width, _height) do
    # Simplified PNG creation - would need proper implementation
    # For now, return a placeholder
    <<137, 80, 78, 71, 13, 10, 26, 10>>  # PNG signature
  end

  # Helper for LiveView uploads
  defp consume_uploaded_entry(entry, fun) do
    # This would be called from LiveView context
    # Simplified version for illustration
    fun.(entry)
  end
end