defmodule BlogWeb.Api.PushController do
  @moduledoc """
  Registers iOS device tokens (the app) and Web Push subscriptions (the PWA)
  for blink push notifications. Public on purpose: anyone with the app or the
  home-screen install may subscribe. Bogus tokens are format-checked here and
  pruned when the push service rejects them.
  """
  use BlogWeb, :controller

  alias Blog.Push

  def register(conn, %{"device_token" => token} = params) do
    tags = params["tags"] |> List.wrap() |> Enum.filter(&is_binary/1)

    case Push.register_device(token, params["env"] || "prod", tags) do
      {:ok, _device} ->
        json(conn, %{status: "ok"})

      {:error, _changeset} ->
        conn |> put_status(:unprocessable_entity) |> json(%{status: "error"})
    end
  end

  def register(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "device_token required"})
  end

  # --- Web Push (PWA) -------------------------------------------------------

  @doc "POST /api/push/web with the browser's PushSubscription JSON."
  def subscribe_web(conn, %{"subscription" => %{"endpoint" => endpoint, "keys" => keys}} = params) do
    tags = params["tags"] |> List.wrap() |> Enum.filter(&is_binary/1)

    attrs = %{
      endpoint: endpoint,
      p256dh: keys["p256dh"],
      auth: keys["auth"],
      followed_tags: tags,
      user_agent: conn |> get_req_header("user-agent") |> List.first()
    }

    case Push.register_web_subscription(attrs) do
      {:ok, _sub} -> json(conn, %{status: "ok"})
      {:error, _cs} -> conn |> put_status(:unprocessable_entity) |> json(%{status: "error"})
    end
  end

  def subscribe_web(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "subscription with endpoint and keys required"})
  end

  @doc "DELETE /api/push/web?endpoint=..."
  def unsubscribe_web(conn, %{"endpoint" => endpoint}) do
    Push.delete_web_subscription(endpoint)
    json(conn, %{status: "ok"})
  end

  def unsubscribe_web(conn, _params) do
    conn |> put_status(:bad_request) |> json(%{error: "endpoint required"})
  end

  @doc "POST /api/push/web/test: send a test push to one already-registered subscription."
  def test_web(conn, %{"endpoint" => endpoint}) do
    with %{} = sub <- Push.get_web_subscription(endpoint) || {:error, :unknown},
         true <- Blog.RateLimiter.allow?("push-test:" <> endpoint, 5, 600) || {:error, :rate_limited},
         :ok <-
           Blog.Push.WebPush.send(sub, %{
             "title" => "blinks is on",
             "body" => "you'll get a nudge here when a new link lands",
             "url" => "/blinks",
             "tag" => "blinks-test"
           }) do
      json(conn, %{status: "ok"})
    else
      {:error, :unknown} -> conn |> put_status(:not_found) |> json(%{error: "not subscribed"})
      {:error, :rate_limited} -> conn |> put_status(:too_many_requests) |> json(%{error: "slow down"})
      {:error, :expired} ->
        Push.delete_web_subscription(endpoint)
        conn |> put_status(:gone) |> json(%{error: "subscription expired"})
      {:error, reason} ->
        conn |> put_status(:bad_gateway) |> json(%{error: inspect(reason)})
    end
  end

  def test_web(conn, _params), do: conn |> put_status(:bad_request) |> json(%{error: "endpoint required"})
end
