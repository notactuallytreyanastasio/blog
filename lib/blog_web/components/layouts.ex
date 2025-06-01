defmodule BlogWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use BlogWeb, :controller` and
  `use BlogWeb, :live_view`.
  """
  # Ensure CSRF and other LV helpers are available
  import Phoenix.LiveView.Helpers
  use BlogWeb, :html
  alias BlogWeb.Presence

  embed_templates "layouts/*"

  def recent_posts do
    Blog.Content.Post.all()
    |> Enum.map(fn post ->
      {post.title, format_date(post.written_on), post.slug}
    end)
  end

  def posts_by_tag do
    Blog.Content.Post.all()
    |> Enum.flat_map(fn post ->
      Enum.map(post.tags, fn tag -> {tag.name, {post.title, post.slug}} end)
    end)
    |> Enum.group_by(
      fn {tag_name, _} -> tag_name end,
      fn {_, post_info} -> post_info end
    )
    |> Enum.map(fn {tag_name, posts} -> {tag_name, Enum.take(posts, 2)} end)
  end

  def total_readers do
    try do
      count =
        Blog.PubSub
        |> Phoenix.Presence.list("readers")
        |> map_size()

      count
    rescue
      # Handle the case when the Presence table doesn't exist
      ArgumentError -> 0
      # Handle other potential errors
      _ -> 0
    end
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end
end
