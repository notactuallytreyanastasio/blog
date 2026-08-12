defmodule BlogWeb.Api.PushController do
  @moduledoc """
  Registers iOS device tokens for blink push notifications. Public on
  purpose: anyone with the app may subscribe to new-link pushes. Bogus
  tokens are format-checked here and pruned when APNs rejects them.
  """
  use BlogWeb, :controller

  alias Blog.Push

  def register(conn, %{"device_token" => token} = params) do
    case Push.register_device(token, params["env"] || "prod") do
      {:ok, _device} ->
        json(conn, %{status: "ok"})

      {:error, _changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{status: "error"})
    end
  end

  def register(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "device_token required"})
  end
end
