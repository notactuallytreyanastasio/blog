defmodule Blog.HoseLinks.URLNormalizer do
  @moduledoc """
  Normalizes URLs to canonical form for deduplication.

  Strips protocol, www prefix, query parameters, and fragments.
  Handles special cases like YouTube URLs.

  Returns: "domain/path" (no protocol, no query, no fragment)
  """

  @spec normalize(String.t()) :: {:ok, String.t()} | :error
  def normalize(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: nil} -> :error
      %URI{host: ""} -> :error
      uri -> {:ok, do_normalize(uri)}
    end
  end

  def normalize(_), do: :error

  @spec extract_domain(String.t()) :: String.t()
  def extract_domain(normalized_url) do
    normalized_url
    |> String.split("/", parts: 2)
    |> List.first()
  end

  # --- Private ---

  defp do_normalize(uri) do
    host =
      uri.host
      |> String.downcase()
      |> String.replace_prefix("www.", "")

    path =
      (uri.path || "/")
      |> String.trim_trailing("/")

    path = if path == "", do: "", else: path

    if youtube_host?(host) do
      normalize_youtube(host, path, uri.query)
    else
      clean_host_path(host, path)
    end
  end

  defp youtube_host?(host) do
    host in ["youtube.com", "m.youtube.com", "youtu.be", "youtube-nocookie.com"]
  end

  defp normalize_youtube("youtu.be", path, _query) do
    video_id = String.trim_leading(path, "/")

    if video_id != "" do
      "youtube.com/watch/#{video_id}"
    else
      "youtu.be"
    end
  end

  defp normalize_youtube(_host, path, query) do
    case extract_youtube_video_id(path, query) do
      nil -> clean_host_path("youtube.com", path)
      video_id -> "youtube.com/watch/#{video_id}"
    end
  end

  defp extract_youtube_video_id(path, query) do
    cond do
      String.starts_with?(path, "/watch") ->
        parse_query_param(query, "v")

      String.starts_with?(path, "/shorts/") ->
        path |> String.replace_prefix("/shorts/", "") |> non_empty_or_nil()

      String.starts_with?(path, "/embed/") ->
        path |> String.replace_prefix("/embed/", "") |> non_empty_or_nil()

      String.starts_with?(path, "/v/") ->
        path |> String.replace_prefix("/v/", "") |> non_empty_or_nil()

      true ->
        nil
    end
  end

  defp parse_query_param(nil, _key), do: nil

  defp parse_query_param(query, key) do
    query
    |> URI.decode_query()
    |> Map.get(key)
    |> non_empty_or_nil()
  end

  defp non_empty_or_nil(""), do: nil
  defp non_empty_or_nil(nil), do: nil
  defp non_empty_or_nil(s), do: s

  defp clean_host_path(host, ""), do: host
  defp clean_host_path(host, path), do: host <> path
end
