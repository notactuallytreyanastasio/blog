defmodule Blog.GifMaker.GifGenerator do
  require Logger

  def generate(frames, opts \\ []) do
    if Enum.empty?(frames) do
      {:error, "No frames selected"}
    else
      temp_dir = Path.join(System.tmp_dir!(), "gif_gen_#{:os.system_time(:millisecond)}")
      File.mkdir_p!(temp_dir)

      try do
        frame_paths = write_frames_to_temp(frames, temp_dir)
        framerate = calculate_framerate(frames)
        width = Keyword.get(opts, :width, 480)
        text = Keyword.get(opts, :text)
        generate_with_ffmpeg(frame_paths, framerate, width, temp_dir, text)
      after
        File.rm_rf(temp_dir)
      end
    end
  end

  defp write_frames_to_temp(frames, temp_dir) do
    frames
    |> Enum.with_index(1)
    |> Enum.map(fn {frame, idx} ->
      filename = "frame_#{String.pad_leading(Integer.to_string(idx), 4, "0")}.jpg"
      path = Path.join(temp_dir, filename)
      File.write!(path, frame.image_data)
      path
    end)
  end

  defp calculate_framerate(frames) when length(frames) < 2, do: 4.0

  defp calculate_framerate(frames) do
    timestamps = Enum.map(frames, & &1.timestamp_ms)

    time_diffs =
      timestamps
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [t1, t2] -> t2 - t1 end)
      |> Enum.reject(&(&1 <= 0))

    if Enum.empty?(time_diffs) do
      4.0
    else
      avg_diff_ms = Enum.sum(time_diffs) / length(time_diffs)

      cond do
        avg_diff_ms >= 1000 -> 5.0
        avg_diff_ms >= 500 -> 4.0
        avg_diff_ms >= 200 -> 3.0
        true ->
          fps = 1000.0 / avg_diff_ms
          min(max(fps, 2.0), 8.0)
      end
    end
  end

  defp generate_with_ffmpeg(_frame_paths, framerate, width, temp_dir, text) do
    output_path = Path.join(temp_dir, "output.gif")
    palette_path = Path.join(temp_dir, "palette.png")
    input_pattern = Path.join(temp_dir, "frame_%04d.jpg")

    text_filter = build_text_filter(text)
    scale_filter = "scale=#{width}:-1:flags=lanczos"
    palette_vf = "#{scale_filter}#{text_filter},palettegen=max_colors=256:reserve_transparent=0"

    # Pass 1: Generate palette
    palette_args = [
      "-y",
      "-framerate", Float.to_string(framerate),
      "-start_number", "1",
      "-i", input_pattern,
      "-vf", palette_vf,
      palette_path
    ]

    case System.cmd("ffmpeg", palette_args, stderr_to_stdout: true) do
      {_output, 0} ->
        # Pass 2: Create GIF with palette
        lavfi = "#{scale_filter}#{text_filter}[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5"

        gif_args = [
          "-y",
          "-framerate", Float.to_string(framerate),
          "-start_number", "1",
          "-i", input_pattern,
          "-i", palette_path,
          "-lavfi", lavfi,
          "-r", Float.to_string(framerate),
          output_path
        ]

        case System.cmd("ffmpeg", gif_args, stderr_to_stdout: true) do
          {_output, 0} ->
            case File.read(output_path) do
              {:ok, gif_data} ->
                Logger.info("Generated GIF: #{byte_size(gif_data)} bytes, #{framerate} fps")
                {:ok, gif_data}

              {:error, reason} ->
                {:error, "Failed to read GIF: #{reason}"}
            end

          {error, code} ->
            Logger.error("FFmpeg GIF generation failed (exit #{code}): #{String.slice(error, 0, 500)}")
            {:error, "GIF generation failed"}
        end

      {error, code} ->
        Logger.error("FFmpeg palette generation failed (exit #{code}): #{String.slice(error, 0, 500)}")
        {:error, "Palette generation failed"}
    end
  end

  defp build_text_filter(nil), do: ""
  defp build_text_filter(""), do: ""

  defp build_text_filter(text) do
    # Escape special characters for FFmpeg drawtext
    escaped =
      text
      |> String.replace("\\", "\\\\\\\\")
      |> String.replace("'", "\u2019")
      |> String.replace(":", "\\:")
      |> String.replace("%", "%%")

    ",drawtext=text='#{escaped}'" <>
      ":fontsize=18:fontcolor=white:borderw=2:bordercolor=black" <>
      ":x=(w-text_w)/2:y=h-text_h-10"
  end
end
