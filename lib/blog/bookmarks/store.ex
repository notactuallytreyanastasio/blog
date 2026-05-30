defmodule Blog.Bookmarks.Store do
  use GenServer
  alias Blog.Bookmarks.Bookmark

  @table_name :bookmarks_table

  @spec start_link(term()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    # Table is already created in application.ex
    {:ok, %{}}
  end

  @spec add_bookmark(struct() | map()) :: {:ok, struct()} | {:error, String.t()}
  def add_bookmark(%Bookmark{} = bookmark) do
    case Bookmark.validate(bookmark) do
      {:ok, bookmark} ->
        true = :ets.insert(@table_name, {bookmark.id, bookmark})

        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          "bookmark:firehose",
          %{event: "bookmark_added", payload: bookmark}
        )

        {:ok, bookmark}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def add_bookmark(attrs) when is_map(attrs) do
    attrs
    |> Bookmark.new()
    |> add_bookmark()
  end

  # Chrome extension compatibility
  @spec add_bookmark(
          String.t() | nil,
          String.t() | nil,
          String.t() | nil,
          [String.t()] | nil,
          String.t() | nil,
          String.t() | nil
        ) :: {:ok, struct()} | {:error, String.t()}
  def add_bookmark(url, title, description, tags, favicon_url, user_id) do
    attrs = %{
      url: url,
      title: title,
      description: description,
      tags: tags || [],
      favicon_url: favicon_url,
      user_id: user_id
    }

    attrs
    |> Bookmark.new()
    |> add_bookmark()
  end

  @spec get_bookmark(term()) :: {:ok, struct()} | {:error, :not_found}
  def get_bookmark(id) do
    case :ets.lookup(@table_name, id) do
      [{^id, bookmark}] -> {:ok, bookmark}
      [] -> {:error, :not_found}
    end
  end

  @spec list_bookmarks(String.t()) :: [struct()]
  def list_bookmarks(user_id) do
    :ets.match_object(@table_name, {:_, %{user_id: user_id}})
    |> Enum.map(fn {_id, bookmark} -> bookmark end)
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end

  @spec delete_bookmark(term()) :: :ok
  def delete_bookmark(id) do
    :ets.delete(@table_name, id)

    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "bookmark:firehose",
      %{event: "bookmark_deleted", payload: %{id: id}}
    )

    :ok
  end

  @spec search_bookmarks(String.t(), String.t()) :: [struct()]
  def search_bookmarks(user_id, query) do
    query = String.downcase(query)

    :ets.match_object(@table_name, {:_, %{user_id: user_id}})
    |> Enum.map(fn {_id, bookmark} -> bookmark end)
    |> Enum.filter(fn bookmark ->
      String.contains?(String.downcase(bookmark.title || ""), query) ||
        String.contains?(String.downcase(bookmark.description || ""), query) ||
        String.contains?(String.downcase(bookmark.url), query) ||
        Enum.any?(bookmark.tags, &String.contains?(String.downcase(&1), query))
    end)
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end
end
