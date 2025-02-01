defmodule Blog.Content.Post do
  defstruct [:body, :title, :written_on, :tags, :slug]

  def all do
    "priv/static/posts/*.md"
    |> Path.wildcard()
    |> Enum.map(&parse_post_file/1)
    |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime})
  end

  def get_by_slug(slug) do
    require Logger
    all_posts = all()
    Logger.debug("Looking for slug: #{slug}")
    Logger.debug("Available slugs: #{inspect(Enum.map(all_posts, & &1.slug))}")
    Logger.debug("First post for debugging: #{inspect(List.first(all_posts), pretty: true)}")

    found = Enum.find(all_posts, &(&1.slug == slug))
    Logger.debug("Found post?: #{inspect(found != nil)}")
    found
  end

  defp parse_post_file(file) do
    require Logger
    filename = Path.basename(file, ".md")
    Logger.debug("Parsing file: #{filename}")
    [year, month, day, hour, minute, second | title_words] = String.split(filename, "-")
    datetime = parse_datetime(year, month, day, hour, minute, second)
    slug = Enum.join(title_words, "-")
    Logger.debug("Generated slug: #{slug}")

    %__MODULE__{
      body: File.read!(file),
      title: humanize_title(slug),
      written_on: datetime,
      slug: slug,
      tags: parse_tags(file)
    }
  end

  defp parse_datetime(year, month, day, hour, minute, second) do
    {:ok, datetime} = NaiveDateTime.new(
      String.to_integer(year),
      String.to_integer(month),
      String.to_integer(day),
      String.to_integer(hour),
      String.to_integer(minute),
      String.to_integer(second)
    )
    datetime  # Make sure we're returning the datetime
  end

  defp humanize_title(slug) do
    slug
    |> String.replace("-", " ")
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  defp parse_tags(file) do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.find(fn line -> String.starts_with?(line, "tags:") end)
    |> case do
      nil -> []
      tags_line ->
        tags_line
        |> String.replace("tags:", "")
        |> String.trim()
        |> String.split(",")
        |> Enum.map(&String.trim/1)
        |> Enum.map(&%Blog.Content.Tag{name: &1})
    end
  end
end
