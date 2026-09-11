defmodule BlogWeb.Api.BlinkController do
  use BlogWeb, :controller
  alias Blog.Blinks

  # Reads are public (the /blinks page and RSS already are); writes need the token.
  plug :require_token when action not in [:index, :tags, :random, :save, :unsave, :suggest]

  def create(conn, params) do
    attrs = %{
      "url" => params["url"],
      "title" => params["title"],
      "description" => params["description"],
      "tags" => params["tags"] || [],
      "quotes" => List.wrap(params["quotes"] || params["quote"] || [])
    }

    case Blinks.save_blink(attrs) do
      {:ok, blink} ->
        json(conn, %{status: "ok", blink: blink})

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
              opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: errors})
    end
  end

  def index(conn, params) do
    tags =
      (params["tags"] || params["tag"] || "")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    blinks =
      Blinks.list_blinks(
        query: params["q"],
        tags: tags,
        sort: if(params["sort"] == "popular", do: :popular),
        limit: min(String.to_integer(params["limit"] || "100"), 500),
        offset: String.to_integer(params["offset"] || "0")
      )

    json(conn, %{status: "ok", blinks: blinks})
  end

  # One random saved link — powers the app's "shuffle" discovery button.
  def random(conn, params) do
    exclude =
      (params["exclude"] || "")
      |> String.split(",")
      |> Enum.flat_map(fn s ->
        case Integer.parse(String.trim(s)) do
          {id, ""} -> [id]
          _ -> []
        end
      end)

    case Blinks.random_blink(exclude: exclude) do
      nil -> conn |> put_status(:not_found) |> json(%{error: "no blinks"})
      blink -> json(conn, %{status: "ok", blink: blink})
    end
  end

  # POST /api/blinks/:id/save {device_id} — anonymous bookmark, counts public
  def save(conn, %{"id" => id} = params) do
    with_device(conn, params, fn device_hash ->
      with_id(conn, id, fn id ->
        case Blinks.save_for_device(id, device_hash) do
          {:ok, count} -> json(conn, %{status: "ok", save_count: count})
          {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not found"})
        end
      end)
    end)
  end

  # DELETE /api/blinks/:id/save {device_id}
  def unsave(conn, %{"id" => id} = params) do
    with_device(conn, params, fn device_hash ->
      with_id(conn, id, fn id ->
        {:ok, count} = Blinks.unsave_for_device(id, device_hash)
        json(conn, %{status: "ok", save_count: count})
      end)
    end)
  end

  # POST /api/blinks/suggest {url, title, website: ""} — readers feed the
  # bookmark review queue (the share extension). Nothing publishes without
  # admin review, so guards stay light: honeypot + rate limit + url shape.
  def suggest(conn, params) do
    ip = client_ip(conn)

    cond do
      (params["website"] || "") != "" ->
        json(conn, %{status: "ok", queued: true})

      not (Blog.RateLimiter.allow?("suggest:" <> ip, 3, 60) and
             Blog.RateLimiter.allow?("suggest_day:" <> ip, 20, 24 * 3600)) ->
        conn |> put_status(429) |> json(%{status: "error", error: "rate limited"})

      not (is_binary(params["url"]) and String.starts_with?(params["url"], "http")) ->
        conn |> put_status(:unprocessable_entity) |> json(%{status: "error", error: "bad url"})

      true ->
        count =
          Blinks.import_candidates([
            %{"url" => params["url"], "title" => params["title"], "folder" => "app-suggest"}
          ])

        json(conn, %{status: "ok", queued: count == 1})
    end
  end

  defp with_device(conn, params, fun) do
    device_id = params["device_id"]

    if is_binary(device_id) and byte_size(device_id) in 8..64 and
         Blog.RateLimiter.allow?("save:" <> client_ip(conn), 30, 60) do
      secret = conn.secret_key_base || "blinks"

      hash =
        :crypto.hash(:sha256, device_id <> secret)
        |> Base.encode16(case: :lower)
        |> binary_part(0, 16)

      fun.(hash)
    else
      conn |> put_status(:bad_request) |> json(%{error: "device_id required"})
    end
  end

  defp client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [forwarded | _] -> forwarded |> String.split(",") |> hd() |> String.trim()
      [] -> conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  def update(conn, %{"id" => id} = params) do
    with_id(conn, id, fn id ->
      case Blinks.update_meta(id, params) do
        {:ok, blink} -> json(conn, %{status: "ok", blink: blink})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not found"})
        {:error, _} -> conn |> put_status(:unprocessable_entity) |> json(%{status: "error"})
      end
    end)
  end

  def add_tags(conn, %{"id" => id} = params) do
    with_id(conn, id, fn id ->
      case Blinks.add_tags(id, List.wrap(params["tags"] || [])) do
        {:ok, blink} -> json(conn, %{status: "ok", blink: blink})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not found"})
        {:error, _} -> conn |> put_status(:unprocessable_entity) |> json(%{status: "error"})
      end
    end)
  end

  def remove_tag(conn, %{"id" => id, "tag" => tag}) do
    with_id(conn, id, fn id ->
      case Blinks.remove_tag(id, tag) do
        {:ok, blink} -> json(conn, %{status: "ok", blink: blink})
        {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not found"})
        {:error, _} -> conn |> put_status(:unprocessable_entity) |> json(%{status: "error"})
      end
    end)
  end

  def tags(conn, _params) do
    json(conn, %{status: "ok", tags: Blinks.list_tags()})
  end

  def import_candidates(conn, %{"candidates" => candidates}) when is_list(candidates) do
    json(conn, %{status: "ok", imported: Blinks.import_candidates(candidates)})
  end

  def delete(conn, %{"id" => id}) do
    case Integer.parse(id) do
      {id, ""} ->
        case Blinks.delete_blink(id) do
          {:ok, blink} -> json(conn, %{status: "ok", deleted: blink.id})
          {:error, :not_found} -> conn |> put_status(:not_found) |> json(%{error: "not found"})
        end

      _ ->
        conn |> put_status(:bad_request) |> json(%{error: "bad id"})
    end
  end

  def lookup(conn, params) do
    json(conn, %{status: "ok", blink: Blinks.get_by_url(params["url"])})
  end

  def export(conn, %{"format" => "html"}) do
    blinks = Blinks.list_blinks(limit: 100_000)

    items =
      Enum.map_join(blinks, "\n", fn b ->
        added = b.inserted_at |> DateTime.from_naive!("Etc/UTC") |> DateTime.to_unix()

        ~s(<DT><A HREF="#{escape(b.url)}" ADD_DATE="#{added}" TAGS="#{escape(Enum.join(b.tags, ","))}">#{escape(b.title || b.url)}</A>) <>
          if b.description, do: "\n<DD>#{escape(b.description)}", else: ""
      end)

    body = """
    <!DOCTYPE NETSCAPE-Bookmark-file-1>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
    <TITLE>Bookmarks</TITLE>
    <H1>blinks</H1>
    <DL><p>
    #{items}
    </DL><p>
    """

    conn
    |> put_resp_content_type("text/html")
    |> put_resp_header("content-disposition", ~s(attachment; filename="blinks.html"))
    |> send_resp(200, body)
  end

  def export(conn, _params) do
    conn
    |> put_resp_header("content-disposition", ~s(attachment; filename="blinks.json"))
    |> json(%{status: "ok", blinks: Blinks.list_blinks(limit: 100_000)})
  end

  defp escape(s), do: Plug.HTML.html_escape(s)

  defp with_id(conn, id, fun) do
    case Integer.parse(id) do
      {id, ""} -> fun.(id)
      _ -> conn |> put_status(:bad_request) |> json(%{error: "bad id"})
    end
  end

  defp require_token(conn, _opts) do
    expected = Application.get_env(:blog, :blinks_api_token)

    provided =
      get_req_header(conn, "x-blinks-token")
      |> List.first()
      |> case do
        nil ->
          case get_req_header(conn, "authorization") do
            ["Bearer " <> token | _] -> token
            # ?token= supported so export links work straight from a browser
            _ -> conn.params["token"]
          end

        token ->
          token
      end

    if is_binary(expected) and expected != "" and Plug.Crypto.secure_compare(provided || "", expected) do
      conn
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid or missing auth token"})
      |> halt()
    end
  end
end
