defmodule Blog.CollageMaker.ImageProcessor do
  require Logger

  @max_cell_size 2048

  def get_dimensions(path) do
    case System.cmd("identify", ["-format", "%w %h", path], stderr_to_stdout: true) do
      {output, 0} ->
        [w, h] = output |> String.trim() |> String.split(" ") |> Enum.map(&String.to_integer/1)
        {:ok, w, h}

      {error, _} ->
        {:error, "Failed to read image dimensions: #{String.trim(error)}"}
    end
  end

  def compute_cell_size(images) do
    min_dim =
      images
      |> Enum.map(fn img -> min(img.original_width, img.original_height) end)
      |> Enum.min()

    min(min_dim, @max_cell_size)
  end

  def square_crop(input_path, output_path, cell_size) do
    case get_dimensions(input_path) do
      {:ok, w, h} ->
        crop_size = min(w, h)

        args = [
          input_path,
          "-gravity", "center",
          "-crop", "#{crop_size}x#{crop_size}+0+0",
          "+repage",
          "-resize", "#{cell_size}x#{cell_size}!",
          "-quality", "92",
          output_path
        ]

        case System.cmd("convert", args, stderr_to_stdout: true) do
          {_, 0} -> {:ok, output_path}
          {error, _} -> {:error, "Failed to crop image: #{String.trim(error)}"}
        end

      error ->
        error
    end
  end

  def stitch_collage(image_paths, columns, cell_size, output_path) do
    total = length(image_paths)
    rows = ceil(total / columns)
    canvas_w = columns * cell_size
    canvas_h = rows * cell_size

    positions = compute_positions(total, columns, rows, cell_size)

    composite_args =
      Enum.zip(image_paths, positions)
      |> Enum.flat_map(fn {path, {x, y}} ->
        [path, "-geometry", "+#{x}+#{y}", "-composite"]
      end)

    args =
      ["-size", "#{canvas_w}x#{canvas_h}", "xc:#c0c0c0"] ++
        composite_args ++
        ["-quality", "92", output_path]

    Logger.info("Collage Maker: stitching #{total} images into #{columns}x#{rows} grid (#{canvas_w}x#{canvas_h})")

    case System.cmd("convert", args, stderr_to_stdout: true) do
      {_, 0} -> {:ok, output_path, canvas_w, canvas_h}
      {error, _} -> {:error, "Failed to stitch collage: #{String.trim(error)}"}
    end
  end

  defp compute_positions(total, columns, rows, cell_size) do
    for i <- 0..(total - 1) do
      row = div(i, columns)
      col = rem(i, columns)

      last_row? = row == rows - 1
      items_in_last_row = total - (rows - 1) * columns

      x =
        if last_row? and items_in_last_row < columns do
          offset = div((columns - items_in_last_row) * cell_size, 2)
          col * cell_size + offset
        else
          col * cell_size
        end

      y = row * cell_size
      {x, y}
    end
  end
end
