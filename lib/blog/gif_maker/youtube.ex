defmodule Blog.GifMaker.YouTube do
  require Logger

  @youtube_url_regex ~r/(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})/
  @cookies_path Application.compile_env(:blog, :yt_dlp_cookies_path, "/app/cookies.txt")

  def validate_url(url) do
    case Regex.run(@youtube_url_regex, url) do
      [_, video_id] -> {:ok, video_id}
      _ -> {:error, "Invalid YouTube URL"}
    end
  end

  def get_metadata(url) do
    args = cookie_args() ++ ["--dump-json", "--no-download", "--no-playlist", url]

    case System.cmd("yt-dlp", args, stderr_to_stdout: true) do
      {output, 0} ->
        case Jason.decode(output) do
          {:ok, data} ->
            {:ok,
             %{
               video_id: data["id"],
               title: data["title"],
               duration_seconds: data["duration"]
             }}

          {:error, _} ->
            {:error, "Failed to parse video metadata"}
        end

      {error, _code} ->
        Logger.error("yt-dlp metadata fetch failed: #{String.slice(error, 0, 500)}")
        {:error, "Failed to fetch video info. The video may be private or unavailable."}
    end
  end

  def download_segment(url, start_seconds, duration_seconds) do
    temp_dir = Path.join(System.tmp_dir!(), "gif_maker_dl_#{:os.system_time(:millisecond)}")
    File.mkdir_p!(temp_dir)
    output_path = Path.join(temp_dir, "segment.mp4")

    end_seconds = start_seconds + duration_seconds
    section_spec = "*#{format_time(start_seconds)}-#{format_time(end_seconds)}"

    args = cookie_args() ++ [
      "--download-sections", section_spec,
      "-f", "bestvideo[height<=720]+bestaudio/best[height<=720]",
      "--merge-output-format", "mp4",
      "--no-playlist",
      "-o", output_path,
      url
    ]

    Logger.info("Downloading segment: #{section_spec} from #{url}")

    case System.cmd("yt-dlp", args, stderr_to_stdout: true, timeout: 120_000) do
      {_output, 0} ->
        if File.exists?(output_path) do
          {:ok, output_path, temp_dir}
        else
          # yt-dlp sometimes appends format extension
          case Path.wildcard(Path.join(temp_dir, "segment.*")) do
            [actual_path | _] -> {:ok, actual_path, temp_dir}
            [] -> {:error, "Download completed but file not found"}
          end
        end

      {error, _code} ->
        File.rm_rf(temp_dir)
        Logger.error("yt-dlp download failed: #{String.slice(error, 0, 500)}")
        {:error, "Failed to download video segment"}
    end
  end

  defp format_time(seconds) when is_integer(seconds) do
    h = div(seconds, 3600)
    m = div(rem(seconds, 3600), 60)
    s = rem(seconds, 60)
    "#{pad(h)}:#{pad(m)}:#{pad(s)}"
  end

  defp format_time(seconds) when is_float(seconds), do: format_time(round(seconds))

  defp pad(n), do: String.pad_leading(Integer.to_string(n), 2, "0")

  defp cookie_args do
    path = Application.get_env(:blog, :yt_dlp_cookies_path, @cookies_path)

    if path && File.exists?(path) do
      ["--cookies", path]
    else
      []
    end
  end
end
