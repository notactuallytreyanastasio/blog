defmodule BlogWeb.LiveCase do
  @moduledoc """
  Test case for LiveView tests.

  Like `BlogWeb.ConnCase` but also imports `Phoenix.LiveViewTest`, so tests get
  `live/2`, `render_click/3`, `assert_redirected/2`, and friends. Enables the
  Ecto SQL sandbox via `Blog.DataCase`.

  Note: tests that use `:meck` to mock modules globally must run with
  `async: false`, since meck replaces the module process-wide.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint BlogWeb.Endpoint

      use BlogWeb, :verified_routes

      import Plug.Conn
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest
    end
  end

  setup tags do
    Blog.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
