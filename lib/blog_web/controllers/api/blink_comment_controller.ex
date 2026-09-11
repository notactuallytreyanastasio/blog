defmodule BlogWeb.Api.BlinkCommentController do
  use BlogWeb, :controller

  alias Blog.Blinks.Comments
  alias Blog.RateLimiter

  plug :require_token when action in [:delete]

  @token_salt "blink comment"
  # Bots submit forms instantly; humans take at least a few seconds to type.
  @min_token_age 3
  @max_token_age 2 * 3600

  # GET /api/blinks/:blink_id/comments
  # Also issues the post_token the client must echo back when commenting.
  def index(conn, %{"blink_id" => blink_id}) do
    with_id(conn, blink_id, fn id ->
      json(conn, %{
        status: "ok",
        comments: Comments.list_comments(id),
        post_token: Phoenix.Token.sign(conn, @token_salt, System.system_time(:second))
      })
    end)
  end

  # POST /api/blinks/:blink_id/comments {author_name, content, post_token, website}
  def create(conn, %{"blink_id" => blink_id} = params) do
    with_id(conn, blink_id, fn id ->
      cond do
        # Honeypot: "website" is invisible to humans. Pretend it worked.
        (params["website"] || "") != "" ->
          json(conn, %{status: "ok"})

        not token_old_enough?(conn, params["post_token"]) ->
          conn |> put_status(429) |> json(%{status: "error", error: "slow down"})

        not (RateLimiter.allow?("comment:" <> client_ip(conn), 4, 60) and
               RateLimiter.allow?("comment_day:" <> client_ip(conn), 60, 24 * 3600)) ->
          conn |> put_status(429) |> json(%{status: "error", error: "rate limited"})

        true ->
          attrs = %{
            "blink_id" => id,
            "author_name" => params["author_name"],
            "content" => params["content"],
            "ip_hash" => ip_hash(conn)
          }

          case Comments.create_comment(attrs) do
            {:ok, comment} ->
              json(conn, %{status: "ok", comment: comment})

            {:error, :duplicate} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{status: "error", error: "you already said that"})

            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> json(%{status: "error", error: first_error(changeset)})
          end
      end
    end)
  end

  # POST /api/blinks/comments/:id/report
  def report(conn, %{"id" => id}) do
    with_id(conn, id, fn id ->
      if RateLimiter.allow?("comment_report:" <> client_ip(conn), 10, 60) do
        case Comments.report_comment(id) do
          {:ok, _} -> json(conn, %{status: "ok"})
          {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not found"})
        end
      else
        conn |> put_status(429) |> json(%{status: "error", error: "rate limited"})
      end
    end)
  end

  # POST /api/blinks/comments/:id/react {emoji, device_id}
  def react(conn, %{"id" => id} = params), do: reaction(conn, id, params, :add)

  # DELETE /api/blinks/comments/:id/react {emoji, device_id}
  def unreact(conn, %{"id" => id} = params), do: reaction(conn, id, params, :remove)

  defp reaction(conn, id, params, op) do
    device_id = params["device_id"]

    cond do
      not (is_binary(device_id) and byte_size(device_id) in 8..64) ->
        conn |> put_status(:bad_request) |> json(%{error: "device_id required"})

      not RateLimiter.allow?("react:" <> client_ip(conn), 30, 60) ->
        conn |> put_status(429) |> json(%{status: "error", error: "rate limited"})

      true ->
        with_id(conn, id, fn id ->
          fun = if op == :add, do: &Comments.react/3, else: &Comments.unreact/3

          case fun.(id, params["emoji"] || "", device_hash(conn, device_id)) do
            {:ok, reactions} ->
              json(conn, %{status: "ok", reactions: reactions})

            {:error, :bad_emoji} ->
              conn |> put_status(:unprocessable_entity) |> json(%{error: "bad emoji"})

            {:error, :not_found} ->
              conn |> put_status(:not_found) |> json(%{error: "not found"})
          end
        end)
    end
  end

  defp device_hash(conn, device_id) do
    secret = conn.secret_key_base || "blinks"

    :crypto.hash(:sha256, device_id <> secret)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end

  # DELETE /api/blinks/comments/:id (admin)
  def delete(conn, %{"id" => id}) do
    with_id(conn, id, fn id ->
      case Comments.delete_comment(id) do
        {:ok, _} -> json(conn, %{status: "ok"})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not found"})
      end
    end)
  end

  defp token_old_enough?(conn, token) when is_binary(token) do
    case Phoenix.Token.verify(conn, @token_salt, token, max_age: @max_token_age) do
      {:ok, issued_at} -> System.system_time(:second) - issued_at >= @min_token_age
      _ -> false
    end
  end

  defp token_old_enough?(_conn, _), do: false

  defp client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded | _] -> forwarded |> String.split(",") |> hd() |> String.trim()
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  defp ip_hash(conn) do
    secret = conn.secret_key_base || "blink-comments"

    :crypto.hash(:sha256, client_ip(conn) <> secret)
    |> Base.encode16(case: :lower)
    |> binary_part(0, 16)
  end

  defp first_error(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map(fn {field, msgs} -> "#{field} #{Enum.join(msgs, ", ")}" end)
    |> Enum.join("; ")
  end

  defp with_id(conn, id, fun) do
    case Integer.parse(to_string(id)) do
      {id, ""} -> fun.(id)
      _ -> conn |> put_status(:bad_request) |> json(%{error: "bad id"})
    end
  end

  defp require_token(conn, _opts) do
    expected = Application.get_env(:blog, :blinks_api_token)

    provided =
      case get_req_header(conn, "x-blinks-token") do
        [token | _] ->
          token

        [] ->
          case get_req_header(conn, "authorization") do
            ["Bearer " <> token | _] -> token
            _ -> conn.params["token"]
          end
      end

    if is_binary(expected) and expected != "" and
         Plug.Crypto.secure_compare(provided || "", expected) do
      conn
    else
      conn |> put_status(:unauthorized) |> json(%{error: "unauthorized"}) |> halt()
    end
  end
end
