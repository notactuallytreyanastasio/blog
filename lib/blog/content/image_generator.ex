defmodule Blog.Content.ImageGenerator do
  require Logger

  @cache_dir "priv/static/images/posts"
  @public_path "/images/posts"

  def ensure_post_image(slug) do
    filename = "#{slug}.png"
    path = Path.join(@cache_dir, filename)
    public_path = Path.join(@public_path, filename)

    if File.exists?(path) do
      public_path
    else
      File.mkdir_p!(@cache_dir)

      case generate_image(path) do
        {:ok, _} -> public_path
        {:error, _} -> nil
      end
    end
  end

  defp generate_image(path) do
    # Generate a 1200x630 image (optimal for OpenGraph)
    commands = [
      "-size",
      "1200x630",
      # Start with white background
      "xc:white",
      # Add some random splatter effects
      "-seed",
      "#{:rand.uniform(999_999)}",
      # Create multiple layers of colored circles
      "(",
      "-size",
      "1200x630",
      "xc:transparent",
      # Blue
      "-draw",
      random_circles(20, "rgba(59,130,246,0.6)"),
      ")",
      "(",
      "-size",
      "1200x630",
      "xc:transparent",
      # Indigo
      "-draw",
      random_circles(20, "rgba(99,102,241,0.6)"),
      ")",
      "(",
      "-size",
      "1200x630",
      "xc:transparent",
      # Violet
      "-draw",
      random_circles(20, "rgba(139,92,246,0.6)"),
      ")",
      "-composite",
      "-composite",
      # Add some noise for texture
      "-operator",
      "all",
      "Add",
      "2%",
      "gaussian-noise",
      path
    ]

    try do
      case System.cmd("convert", commands) do
        {_, 0} ->
          {:ok, path}

        {error, _} ->
          Logger.error("Failed to generate image: #{error}")
          {:error, "Failed to generate image"}
      end
    rescue
      e in ErlangError ->
        Logger.warning("ImageMagick not available: #{inspect(e)}")
        {:error, "ImageMagick not installed"}
    end
  end

  defp random_circles(count, color) do
    1..count
    |> Enum.map(fn _ ->
      x = :rand.uniform(1200)
      y = :rand.uniform(630)
      size = :rand.uniform(100) + 50
      "circle #{x},#{y} #{x + size},#{y} #{color}"
    end)
    |> Enum.join(" ")
  end
end
