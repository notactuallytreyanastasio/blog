defmodule Blog.Bookmarks.Store do
  use GenServer

  @table_name :bookmarks_table

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    # Table is already created in application.ex
    {:ok, %{}}
  end

  def add_bookmark(bookmark) when is_map(bookmark) do
    bookmark = %{
      id: generate_id(),
      url: bookmark.url,
      title: bookmark.title,
      description: bookmark.description,
      tags: bookmark.tags || [],
      favicon_url: bookmark.favicon_url,
      user_id: bookmark.user_id,
      inserted_at: DateTime.utc_now()
    }

    true = :ets.insert(@table_name, {bookmark.id, bookmark})
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "bookmarks:firehose",
      %{bookmark: bookmark, action: :created}
    )

    {:ok, bookmark}
  end

  def add_bookmark(url, title, description, tags, favicon_url, user_id) do
    bookmark = %{
      id: generate_id(),
      url: url,
      title: title,
      description: description,
      tags: tags || [],
      favicon_url: favicon_url,
      user_id: user_id,
      inserted_at: DateTime.utc_now()
    }

    true = :ets.insert(@table_name, {bookmark.id, bookmark})
    {:ok, bookmark}
  end

  def get_bookmark(id) do
    case :ets.lookup(@table_name, id) do
      [{^id, bookmark}] -> {:ok, bookmark}
      [] -> {:error, :not_found}
    end
  end

  def list_bookmarks(user_id) do
    :ets.match_object(@table_name, {:_, %{user_id: user_id}})
    |> Enum.map(fn {_id, bookmark} -> bookmark end)
    |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
  end

  def delete_bookmark(id) do
    :ets.delete(@table_name, id)
    :ok
  end

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

  defp generate_id, do: System.unique_integer([:positive, :monotonic]) |> to_string()
end
