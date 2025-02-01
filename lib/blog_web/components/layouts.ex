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
    [
      {"Building a Blog with Phoenix LiveView", "March 15, 2024"},
      {"The Power of Pattern Matching in Elixir", "March 10, 2024"},
      {"Understanding Phoenix Contexts", "March 5, 2024"},
      {"Functional Programming Basics", "February 28, 2024"},
      {"Getting Started with Elixir", "February 20, 2024"}
    ]
  end
end
