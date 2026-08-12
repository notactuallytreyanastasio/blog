defmodule BlogWeb.Api.PushController do
  @moduledoc "Registers iOS device tokens for blink push notifications."
  use BlogWeb, :controller

  alias Blog.Push

  plug :require_token

  # Named device_token (not token): the auth plug's ?token= fallback would
  # otherwise read the device token as the API token and 401.
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

  # Same contract as BlinkController.require_token (kept local: that plug is
  # a private function of the other controller).
  defp require_token(conn, _opts) do
    expected = Application.get_env(:blog, :blinks_api_token)

    provided =
      get_req_header(conn, "x-blinks-token")
      |> List.first()
      |> case do
        nil ->
          case get_req_header(conn, "authorization") do
            ["Bearer " <> token | _] -> token
            _ -> conn.params["token"]
          end

        token ->
          token
      end

    if is_binary(expected) and expected != "" and
         Plug.Crypto.secure_compare(provided || "", expected) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid or missing auth token"})
      |> halt()
    end
  end
end
