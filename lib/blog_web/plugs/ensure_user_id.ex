defmodule BlogWeb.Plugs.EnsureUserId do
  @moduledoc """
  A plug that ensures a user_id is present in the session.

  This is used to identify users in the chat functionality.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, "user_id") do
      # User ID already exists in session
      conn
    else
      # Generate a new user ID and put it in the session
      user_id = System.unique_integer([:positive]) |> to_string()
      put_session(conn, "user_id", user_id)
    end
  end
end
