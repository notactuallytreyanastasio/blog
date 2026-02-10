defmodule Blog.Content.Post do
  defstruct [:body, :title, :written_on, :tags, :slug, :author_name, :is_guest_post]

  # Allowlist of posts to display (excludes cached/deleted posts from old deploys)
  @allowed_slugs ~w(
    building-this-blog
    on-making-a-link-blog
    a-me-museum
    a-hilarious-shared-keyboard-key
    a-fun-experiment
    i-pulled-the-paul-tickets
    a-quick-typewriter-set-letter-project
    lets-write-letters
    whats-my-schtick
    nathan-fielder
    a-genstage-tutorial-and-reflection
    327-years-of-tree-law-in-the-usa-
    many-layer-dips-i-decided-to-try-making-a-robot-llm-post-like-me
  )

  def all do
    file_posts =
      ((:code.priv_dir(:blog) |> to_string) <> "/static/posts/*.md")
      |> Path.wildcard()
      |> Enum.reject(fn file ->
        case file |> String.split("-") |> List.last() |> String.length() do
          35 -> true
          _ -> false
        end
      end)
      |> Enum.map(&parse_post_file/1)
      |> Enum.filter(fn post -> post.slug in @allowed_slugs end)

    guest_posts = list_published_drafts()

    (file_posts ++ guest_posts)
    |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime})
  end

  defp list_published_drafts do
    Blog.Editor.list_published()
    |> Enum.map(&draft_to_post/1)
  end

  defp draft_to_post(draft) do
    %__MODULE__{
      body: draft.content || "",
      title: draft.title || "Untitled",
      written_on: draft.updated_at |> DateTime.to_naive(),
      slug: draft.slug,
      tags: [%Blog.Content.Tag{name: "guest-post"}],
      author_name: draft.author_name,
      is_guest_post: true
    }
  end

  @spec get_by_slug(any()) :: any()
  def get_by_slug(slug) do
    # First check file-based posts
    case all() |> Enum.find(&(&1.slug == slug)) do
      nil ->
        # Check if it's a published draft
        case Blog.Editor.get_draft_by_slug(slug) do
          %{status: "published"} = draft -> draft_to_post(draft)
          _ -> nil
        end

      post ->
        post
    end
  end

  defp parse_post_file(file) do
    filename = Path.basename(file, ".md")
    [year, month, day, hour, minute, second | title_words] = String.split(filename, "-")
    _title = Enum.join(title_words, " ")
    datetime = parse_datetime(year, month, day, hour, minute, second)
    slug = Enum.join(title_words, "-")

    %__MODULE__{
      body: File.read!(file),
      title: humanize_title(slug),
      written_on: datetime,
      slug: slug,
      tags: parse_tags(file)
    }
  end

  defp parse_datetime(year, month, day, hour, minute, second) do
    {:ok, datetime} =
      NaiveDateTime.new(
        String.to_integer(year),
        String.to_integer(month),
        String.to_integer(day),
        String.to_integer(hour),
        String.to_integer(minute),
        String.to_integer(second)
      )

    datetime
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
      nil ->
        []

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
