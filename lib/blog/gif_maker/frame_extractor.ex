defmodule Blog.GifMaker.FrameExtractor do
  require Logger
  alias Blog.GifMaker

  def extract_frames(video_path, job_id) do
    temp_dir = Path.join(System.tmp_dir!(), "gif_maker_frames_#{:os.system_time(:millisecond)}")
    File.mkdir_p!(temp_dir)

    try do
      output_pattern = Path.join(temp_dir, "frame_%04d.jpg")

      args = [
        "-i", video_path,
        "-vf", "fps=1",
        "-q:v", "2",
        output_pattern
      ]

      Logger.info("Extracting frames from #{video_path}")

      case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
        {_output, 0} ->
          store_frames(temp_dir, job_id)

        {error, code} ->
          Logger.error("FFmpeg frame extraction failed (exit #{code}): #{String.slice(error, 0, 500)}")
          {:error, "Frame extraction failed"}
      end
    after
      File.rm_rf(temp_dir)
    end
  end

  defp store_frames(temp_dir, job_id) do
    frame_files =
      temp_dir
      |> File.ls!()
      |> Enum.filter(&String.ends_with?(&1, ".jpg"))
      |> Enum.sort()

    if Enum.empty?(frame_files) do
      {:error, "No frames extracted"}
    else
      frames_data =
        frame_files
        |> Enum.with_index(1)
        |> Enum.map(fn {filename, frame_number} ->
          file_path = Path.join(temp_dir, filename)
          {:ok, image_data} = File.read(file_path)
          file_size = byte_size(image_data)
          timestamp_ms = (frame_number - 1) * 1000

          %{
            job_id: job_id,
            frame_number: frame_number,
            timestamp_ms: timestamp_ms,
            image_data: image_data,
            file_size: file_size
          }
        end)

      {count, _} = GifMaker.insert_frames(frames_data)
      Logger.info("Stored #{count} frames for job #{job_id}")
      {:ok, count}
    end
  end
end
