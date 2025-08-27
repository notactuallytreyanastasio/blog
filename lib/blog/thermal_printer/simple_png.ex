defmodule Blog.ThermalPrinter.SimplePNG do
  @moduledoc """
  Minimal PNG decoder for thermal printer processing.
  Handles basic PNG decoding without external dependencies.
  """

  import Bitwise
  
  @png_signature <<137, 80, 78, 71, 13, 10, 26, 10>>

  def decode(binary) do
    with {:ok, chunks} <- validate_and_parse(binary),
         {:ok, ihdr} <- get_ihdr(chunks),
         {:ok, idat_data} <- get_idat_data(chunks),
         {:ok, pixels} <- decompress_and_process(idat_data, ihdr) do
      {:ok, pixels, ihdr.width, ihdr.height}
    end
  end

  defp validate_and_parse(<<@png_signature, rest::binary>>) do
    parse_chunks(rest, [])
  end

  defp validate_and_parse(_), do: {:error, "Invalid PNG signature"}

  defp parse_chunks(<<>>, acc), do: {:ok, Enum.reverse(acc)}
  
  defp parse_chunks(<<length::32, type::binary-size(4), rest::binary>>, acc) do
    <<data::binary-size(length), _crc::32, remaining::binary>> = rest
    chunk = %{type: type, data: data}
    
    if type == "IEND" do
      {:ok, Enum.reverse([chunk | acc])}
    else
      parse_chunks(remaining, [chunk | acc])
    end
  rescue
    _ -> {:error, "Invalid chunk structure"}
  end

  defp get_ihdr(chunks) do
    case Enum.find(chunks, &(&1.type == "IHDR")) do
      nil -> {:error, "No IHDR chunk found"}
      %{data: <<width::32, height::32, bit_depth::8, color_type::8, 
                compression::8, filter::8, interlace::8>>} ->
        {:ok, %{
          width: width,
          height: height,
          bit_depth: bit_depth,
          color_type: color_type,
          compression: compression,
          filter: filter,
          interlace: interlace
        }}
      _ -> {:error, "Invalid IHDR chunk"}
    end
  end

  defp get_idat_data(chunks) do
    idat_chunks = Enum.filter(chunks, &(&1.type == "IDAT"))
    
    if Enum.empty?(idat_chunks) do
      {:error, "No IDAT chunks found"}
    else
      combined = idat_chunks
                 |> Enum.map(& &1.data)
                 |> IO.iodata_to_binary()
      {:ok, combined}
    end
  end

  defp decompress_and_process(compressed_data, ihdr) do
    try do
      decompressed = :zlib.uncompress(compressed_data)
      process_scanlines(decompressed, ihdr)
    rescue
      _ -> {:error, "Failed to decompress image data"}
    end
  end

  defp process_scanlines(data, %{width: width, height: height, color_type: color_type}) do
    bytes_per_pixel = bytes_per_pixel(color_type)
    scanline_length = width * bytes_per_pixel
    
    # Process each scanline (includes filter byte)
    {pixels, _} = Enum.reduce(0..(height - 1), {[], data}, fn _y, {acc_pixels, remaining} ->
      <<filter_type::8, scanline::binary-size(scanline_length), rest::binary>> = remaining
      
      # For simplicity, only handle filter type 0 (None)
      pixels = if filter_type == 0 do
        process_pixels(scanline, color_type)
      else
        # Fallback for other filter types
        process_pixels(scanline, color_type)
      end
      
      {acc_pixels ++ pixels, rest}
    end)
    
    {:ok, pixels}
  rescue
    _ -> {:error, "Failed to process scanlines"}
  end

  defp bytes_per_pixel(0), do: 1  # Grayscale
  defp bytes_per_pixel(2), do: 3  # RGB
  defp bytes_per_pixel(3), do: 1  # Palette
  defp bytes_per_pixel(4), do: 2  # Grayscale + Alpha
  defp bytes_per_pixel(6), do: 4  # RGBA
  defp bytes_per_pixel(_), do: 1

  defp process_pixels(data, 0) do
    # Grayscale
    :binary.bin_to_list(data)
  end

  defp process_pixels(data, 2) do
    # RGB - convert to grayscale
    data
    |> :binary.bin_to_list()
    |> Enum.chunk_every(3)
    |> Enum.map(fn [r, g, b] ->
      round(0.299 * r + 0.587 * g + 0.114 * b)
    end)
  end

  defp process_pixels(data, 6) do
    # RGBA - convert to grayscale, ignore alpha
    data
    |> :binary.bin_to_list()
    |> Enum.chunk_every(4)
    |> Enum.map(fn [r, g, b, _a] ->
      round(0.299 * r + 0.587 * g + 0.114 * b)
    end)
  end

  defp process_pixels(data, _) do
    # Fallback - treat as grayscale
    :binary.bin_to_list(data)
  end
end