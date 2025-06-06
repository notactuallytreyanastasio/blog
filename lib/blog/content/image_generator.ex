defmodule Blog.Content.ImageGenerator do
  require Logger

  @cache_dir "priv/static/images/posts"
  @public_path "/images/posts"

  def ensure_post_image(slug) do
    filename = "#{slug}.png"
    path = Path.join(@cache_dir, filename)
    public_path = Path.join(@public_path, filename)

    if not File.exists?(path) do
      File.mkdir_p!(@cache_dir)
      generate_image(path)
    end

    public_path
  end

  defp generate_image(path) do
    Logger.info("Attempting to generate image at: #{path}")
    
    # Check if ImageMagick is available
    case System.cmd("which", ["convert"]) do
      {convert_path, 0} ->
        Logger.info("ImageMagick convert found at: #{String.trim(convert_path)}")
      _ ->
        Logger.error("ImageMagick convert command not found in PATH")
        {:error, "ImageMagick not available"}
    end
    
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
      random_circles(20, "#3B82F6"),
      ")",
      "(",
      "-size",
      "1200x630",
      "xc:transparent",
      # Indigo
      "-draw",
      random_circles(20, "#6366F1"),
      ")",
      "(",
      "-size",
      "1200x630",
      "xc:transparent",
      # Violet
      "-draw",
      random_circles(20, "#8B5CF6"),
      ")",
      "-composite",
      "-composite",
      # Add some noise for texture
      "+noise",
      "Gaussian",
      path
    ]

    Logger.info("Running ImageMagick with commands: #{inspect(commands)}")
    
    case System.cmd("convert", commands) do
      {_, 0} ->
        Logger.info("Successfully generated image at: #{path}")
        {:ok, path}

      {error, exit_code} ->
        Logger.error("Failed to generate image. Exit code: #{exit_code}, Error: #{error}")
        {:error, "Failed to generate image"}
    end
  end

  defp random_circles(count, color) do
    1..count
    |> Enum.map(fn _ ->
      x = :rand.uniform(1200)
      y = :rand.uniform(630)
      size = :rand.uniform(100) + 50
      "fill #{color} circle #{x},#{y} #{x + size},#{y}"
    end)
    |> Enum.join(" ")
  end
end
