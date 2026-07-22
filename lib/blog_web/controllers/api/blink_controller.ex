defmodule BlogWeb.Api.BlinkController do
  use BlogWeb, :controller
  alias Blog.Blinks

  plug :require_token

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
        limit: min(String.to_integer(params["limit"] || "100"), 500)
      )

    json(conn, %{status: "ok", blinks: blinks})
  end

  def tags(conn, _params) do
    json(conn, %{status: "ok", tags: Blinks.list_tags()})
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
