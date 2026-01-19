defmodule Blog.PokeAround.Link do
  @moduledoc """
  A stumble-able link extracted from the Bluesky firehose.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "pa_links" do
    field :url, :string
    field :url_hash, :string

    # Source post
    field :post_uri, :string
    field :post_text, :string
    field :post_created_at, :utc_datetime_usec

    # Author (denormalized)
    field :author_did, :string
    field :author_handle, :string
    field :author_display_name, :string
    field :author_followers_count, :integer

    # Quality
    field :score, :integer, default: 0

    # Metadata
    field :title, :string
    field :description, :string
    field :image_url, :string
    field :domain, :string

    # Categorization
    field :tags, {:array, :string}, default: []
    field :langs, {:array, :string}, default: []

    # Stats
    field :stumble_count, :integer, default: 0

    # Tagging
    field :tagged_at, :utc_datetime_usec
    many_to_many :normalized_tags, Blog.PokeAround.Tag, join_through: "pa_link_tags"

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields [:url, :url_hash]
  @optional_fields [
    :post_uri,
    :post_text,
    :post_created_at,
    :author_did,
    :author_handle,
    :author_display_name,
    :author_followers_count,
    :score,
    :title,
    :description,
    :image_url,
    :domain,
    :tags,
    :langs,
    :stumble_count,
    :tagged_at
  ]

  def changeset(link, attrs) do
    link
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:url_hash)
  end

  @doc """
  Generate a hash for URL deduplication.

  Normalizes the URL by:
  - Lowercasing the scheme and host
  - Removing trailing slashes
  - Sorting query params
  """
  def hash_url(url) when is_binary(url) do
    url
    |> normalize_url()
    |> then(&:crypto.hash(:sha256, &1))
    |> Base.encode16(case: :lower)
    |> String.slice(0, 32)
  end

  defp normalize_url(url) do
    case URI.parse(url) do
      %URI{host: nil} ->
        url

      uri ->
        host = String.downcase(uri.host || "")
        path = String.trim_trailing(uri.path || "/", "/")
        path = if path == "", do: "/", else: path

        query =
          case uri.query do
            nil -> nil
            q -> q |> URI.decode_query() |> Enum.sort() |> URI.encode_query()
          end

        %URI{uri | host: host, path: path, query: query}
        |> URI.to_string()
    end
  end

  @doc """
  Extract domain from URL.
  """
  def extract_domain(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: host} when is_binary(host) ->
        host
        |> String.downcase()
        |> String.replace_prefix("www.", "")

      _ ->
        nil
    end
  end
end
