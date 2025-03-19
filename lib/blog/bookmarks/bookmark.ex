defmodule Blog.Bookmarks.Bookmark do
  @moduledoc """
  Represents a bookmark in the system.
  """

  @derive {Jason.Encoder,
           only: [:id, :url, :title, :description, :tags, :favicon_url, :user_id, :inserted_at]}
  @type t :: %__MODULE__{
          id: String.t(),
          url: String.t(),
          title: String.t() | nil,
          description: String.t() | nil,
          tags: [String.t()],
          favicon_url: String.t() | nil,
          user_id: String.t(),
          inserted_at: DateTime.t()
        }

  defstruct [
    :id,
    :url,
    :title,
    :description,
    :favicon_url,
    :user_id,
    tags: [],
    inserted_at: nil
  ]

  @doc """
  Creates a new bookmark struct with the given attributes.
  Automatically generates an ID and timestamp if not provided.
  """
  def new(attrs \\ %{}) do
    attrs = Map.new(attrs)

    %__MODULE__{
      id: attrs[:id] || generate_id(),
      url: attrs[:url],
      title: attrs[:title],
      description: attrs[:description],
      tags: attrs[:tags] || [],
      favicon_url: attrs[:favicon_url],
      user_id: attrs[:user_id],
      inserted_at: attrs[:inserted_at] || DateTime.utc_now()
    }
  end

  @doc """
  Validates a bookmark struct.
  Returns {:ok, bookmark} if valid, {:error, reason} if invalid.
  """
  def validate(%__MODULE__{} = bookmark) do
    cond do
      is_nil(bookmark.url) or bookmark.url == "" ->
        {:error, "URL is required"}

      is_nil(bookmark.user_id) or bookmark.user_id == "" ->
        {:error, "User ID is required"}

      true ->
        {:ok, bookmark}
    end
  end

  defp generate_id, do: System.unique_integer([:positive, :monotonic]) |> to_string()
end
