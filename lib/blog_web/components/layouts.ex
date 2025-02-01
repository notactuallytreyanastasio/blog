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

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end
end
