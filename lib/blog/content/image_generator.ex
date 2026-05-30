defmodule Blog.Content.ImageGenerator do
  require Logger

  @public_path "/images/posts"
  @font "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
  @font_bold "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"

  defp priv_static, do: Path.join([:code.priv_dir(:blog) |> to_string(), "static"])
  defp cache_dir, do: Path.join(priv_static(), "images/posts")

  @spec ensure_post_image(String.t()) :: String.t() | nil
  def ensure_post_image(slug) do
    filename = "#{slug}.png"
    path = Path.join(cache_dir(), filename)
    public_path = Path.join(@public_path, filename)

    if File.exists?(path) do
      public_path
    else
      File.mkdir_p!(cache_dir())

      generator = case slug do
        "chess" -> &generate_chess_image/1
        _ -> &generate_splatter_image/1
      end

      case generator.(path) do
        {:ok, _} -> public_path
        {:error, _} -> nil
      end
    end
  end

  # Chess post: dark background + chess board on the right + title text on the left
  defp generate_chess_image(path) do
    sq = 60
    bx = 652
    by = 75

    square_cmds =
      for row <- 0..7, col <- 0..7 do
        x1 = bx + col * sq
        y1 = by + row * sq
        color = if rem(row + col, 2) == 0, do: "#f0d9b5", else: "#b58863"
        ["-fill", color, "-draw", "rectangle #{x1},#{y1} #{x1 + sq},#{y1 + sq}"]
      end
      |> List.flatten()

    commands =
      ["-size", "1200x630", "xc:#0f172a"] ++
      square_cmds ++
      [
        # Board border
        "-fill", "none",
        "-stroke", "#c9a96e",
        "-strokewidth", "4",
        "-draw", "rectangle #{bx - 2},#{by - 2} #{bx + 8 * sq + 2},#{by + 8 * sq + 2}",
        # Site name
        "-font", @font,
        "-fill", "#475569",
        "-pointsize", "26",
        "-annotate", "+80+64", "bobbby.online",
        # Main title line 1
        "-font", @font_bold,
        "-fill", "#f8fafc",
        "-pointsize", "76",
        "-annotate", "+80+180", "Opus 4.8 +",
        # Main title line 2
        "-annotate", "+80+272", "Workflows",
        # Subtitle
        "-font", @font,
        "-fill", "#94a3b8",
        "-pointsize", "34",
        "-annotate", "+80+340", "Building a nine-board chess variant",
        # Tag line
        "-fill", "#334155",
        "-pointsize", "26",
        "-annotate", "+80+530", "AI  ·  Chess  ·  Writing",
        path
      ]

    run_convert(commands)
  end

  # Default: colored splatter circles on white, using hex colors with alpha via MagickCore
  defp generate_splatter_image(path) do
    commands = [
      "-size", "1200x630",
      "xc:white",
      "-fill", "#3B82F699",
      "-draw", random_circles(20),
      "-fill", "#6366F199",
      "-draw", random_circles(20),
      "-fill", "#8B5CF699",
      "-draw", random_circles(20),
      path
    ]

    run_convert(commands)
  end

  defp run_convert(commands) do
    try do
      case System.cmd("convert", commands) do
        {_, 0} ->
          {:ok, List.last(commands)}

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

  defp random_circles(count) do
    1..count
    |> Enum.map(fn _ ->
      x = :rand.uniform(1200)
      y = :rand.uniform(630)
      size = :rand.uniform(100) + 50
      "circle #{x},#{y} #{x + size},#{y}"
    end)
    |> Enum.join(" ")
  end
end
