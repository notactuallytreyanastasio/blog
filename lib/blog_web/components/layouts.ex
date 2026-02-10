defmodule BlogWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use BlogWeb, :controller` and
  `use BlogWeb, :live_view`.
  """
  use BlogWeb, :html

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

  def hose_banner do
    try do
      if Blog.HoseMonitor.any_down?() do
        down = Blog.HoseMonitor.down_hoses()
        names = Enum.map_join(down, ", ", &hose_display_name/1)
        {:down, names}
      else
        :all_good
      end
    rescue
      _ -> :all_good
    end
  end

  defp hose_display_name(:bluesky_hose), do: "Relay"
  defp hose_display_name(:jetstream), do: "Jetstream"
  defp hose_display_name(:turbostream), do: "Turbostream"
  defp hose_display_name(other), do: to_string(other)

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
