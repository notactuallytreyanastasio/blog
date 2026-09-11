defmodule Blog.Gallery.ICloud do
  @moduledoc """
  Read-only client for the public website of an iCloud Shared Album.

  Apple exposes two undocumented endpoints behind a shared album's "Public
  Website" checkbox. Neither needs auth — the token from the album URL
  (`https://www.icloud.com/sharedalbum/#TOKEN`) is the whole credential.

      POST /{token}/sharedstreams/webstream      -> photo metadata + a ctag
      POST /{token}/sharedstreams/webasseturls   -> short-lived signed CDN urls

  Albums are sharded across partitions. The first call goes to p01, which
  answers 330 and names the real host in `X-Apple-MMe-Host`; we follow that
  once and then cache the host for the life of the cache process.

  Signed asset urls carry an `e=` expiry roughly three hours out, which is why
  nothing here is ever handed to a browser directly — see
  `BlogWeb.GalleryController` for the redirect that keeps them server-side.
  """
  require Logger

  @first_host "p01-sharedstreams.icloud.com"
  @origin "https://www.icloud.com"
  @recv_timeout 20_000

  @type photo :: %{
          guid: String.t(),
          caption: String.t() | nil,
          created_at: DateTime.t() | nil,
          width: pos_integer(),
          height: pos_integer(),
          thumb: String.t(),
          display: String.t()
        }

  @doc "The host to start from when nothing has been discovered yet."
  @spec first_host() :: String.t()
  def first_host, do: @first_host

  @doc """
  Fetch the album listing. Pass the previously seen `ctag` to short-circuit:
  Apple answers with the same ctag when nothing has changed, so the caller can
  skip rebuilding. Returns the host that actually served the request so the
  caller can pin it for subsequent calls.
  """
  @spec fetch_stream(String.t(), String.t(), String.t() | nil) ::
          {:ok, %{host: String.t(), ctag: String.t(), name: String.t(), photos: [photo()]}}
          | {:error, term()}
  def fetch_stream(token, host \\ @first_host, ctag \\ nil) do
    case post(host, token, "webstream", %{"streamCtag" => ctag}) do
      {:ok, %{status: 330} = resp, _host} ->
        case mme_host(resp) do
          nil -> {:error, {:repartition_without_host, resp.status}}
          ^host -> {:error, {:repartition_loop, host}}
          other -> fetch_stream(token, other, ctag)
        end

      {:ok, %{status: 200, body: body}, served_by} ->
        {:ok,
         %{
           host: served_by,
           ctag: body["streamCtag"],
           name: body["streamName"] || "Shared Album",
           photos: body |> Map.get("photos", []) |> Enum.map(&parse_photo/1) |> Enum.reject(&is_nil/1)
         }}

      {:ok, %{status: status}, _host} ->
        {:error, {:http, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Resolve checksums to signed CDN urls. One call covers the whole album — 114
  photos (228 checksums, both derivative sizes) comes back in about a second —
  so callers should batch rather than resolve per photo.

  Returns `%{checksum => url}`.
  """
  @spec fetch_asset_urls(String.t(), String.t(), [String.t()]) ::
          {:ok, %{optional(String.t()) => String.t()}} | {:error, term()}
  def fetch_asset_urls(_token, _host, []), do: {:ok, %{}}

  def fetch_asset_urls(token, host, guids) do
    case post(host, token, "webasseturls", %{"photoGuids" => guids}) do
      {:ok, %{status: 200, body: body}, _host} ->
        urls =
          body
          |> Map.get("items", %{})
          |> Map.new(fn {checksum, %{"url_location" => loc, "url_path" => path}} ->
            {checksum, "https://" <> loc <> path}
          end)

        {:ok, urls}

      {:ok, %{status: status}, _host} ->
        {:error, {:http, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Seconds until a signed url expires, read from its `e=` query param. Returns 0
  when the url carries no expiry we understand, which makes callers treat it as
  already stale rather than trusting it forever.
  """
  @spec ttl(String.t()) :: non_neg_integer()
  def ttl(url) do
    with %URI{query: q} when is_binary(q) <- URI.parse(url),
         %{"e" => e} <- URI.decode_query(q),
         {expires, ""} <- Integer.parse(e) do
      max(expires - System.system_time(:second), 0)
    else
      _ -> 0
    end
  end

  defp post(host, token, path, payload) do
    url = "https://#{host}/#{token}/sharedstreams/#{path}"

    # Apple wants text/plain here; sending application/json gets a 400.
    result =
      Req.post(url,
        body: Jason.encode!(payload),
        headers: [{"content-type", "text/plain"}, {"origin", @origin}],
        receive_timeout: @recv_timeout,
        retry: :transient,
        decode_body: false
      )

    case result do
      {:ok, resp} -> {:ok, decode(resp), host}
      {:error, reason} -> {:error, reason}
    end
  end

  defp decode(%Req.Response{body: body} = resp) when is_binary(body) do
    case Jason.decode(body) do
      {:ok, decoded} -> %{resp | body: decoded}
      {:error, _} -> %{resp | body: %{}}
    end
  end

  defp decode(resp), do: resp

  defp mme_host(resp) do
    case Req.Response.get_header(resp, "x-apple-mme-host") do
      [host | _] -> host
      _ -> nil
    end
  end

  defp parse_photo(%{"photoGuid" => guid, "derivatives" => derivatives} = photo)
       when is_map(derivatives) and map_size(derivatives) > 0 do
    sized =
      derivatives
      |> Enum.filter(fn {key, d} -> match?({_, ""}, Integer.parse(key)) and is_binary(d["checksum"]) end)
      |> Enum.sort_by(fn {key, _} -> String.to_integer(key) end)

    case sized do
      [] ->
        nil

      _ ->
        {_, thumb} = List.first(sized)
        {_, display} = List.last(sized)

        %{
          guid: guid,
          thumb: thumb["checksum"],
          display: display["checksum"],
          # Top-level dimensions describe the original; the derivative is a
          # scaled copy of it, so this is the aspect ratio to lay out against.
          width: to_int(photo["width"] || display["width"], 1),
          height: to_int(photo["height"] || display["height"], 1),
          caption: blank_to_nil(photo["caption"]),
          created_at: parse_date(photo["dateCreated"] || photo["batchDateCreated"])
        }
    end
  end

  defp parse_photo(_), do: nil

  defp blank_to_nil(s) when is_binary(s) do
    case String.trim(s) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  defp blank_to_nil(_), do: nil

  defp parse_date(s) when is_binary(s) do
    case DateTime.from_iso8601(s) do
      {:ok, dt, _offset} -> dt
      _ -> nil
    end
  end

  defp parse_date(_), do: nil

  defp to_int(n, _default) when is_integer(n), do: n

  defp to_int(n, default) when is_binary(n) do
    case Integer.parse(n) do
      {i, _} -> i
      :error -> default
    end
  end

  defp to_int(_, default), do: default
end
