defmodule BlogWeb.BookmarkChannel do
  use BlogWeb, :channel
  alias Blog.Bookmarks.Store

  @impl true
  def join("bookmark:client:" <> user_id, _params, socket) do
    bookmarks = Store.list_bookmarks(user_id)
    {:ok, %{bookmarks: bookmarks}, assign(socket, :user_id, user_id)}
  end

  @impl true
  def handle_in("add_bookmark", params, socket) do
    %{
      "url" => url,
      "title" => title,
      "description" => description,
      "tags" => tags,
      "favicon_url" => favicon_url
    } = params

    case Store.add_bookmark(url, title, description, tags, favicon_url, socket.assigns.user_id) do
      {:ok, bookmark} ->
        broadcast!(socket, "bookmark_added", bookmark)
        BlogWeb.Endpoint.broadcast("bookmark:firehose", "bookmark_added", bookmark)
        {:reply, {:ok, bookmark}, socket}

      error ->
        {:reply, {:error, %{reason: "failed to add bookmark"}}, socket}
    end
  end

  @impl true
  def handle_in("delete_bookmark", %{"id" => id}, socket) do
    :ok = Store.delete_bookmark(id)
    broadcast!(socket, "bookmark_deleted", %{id: id})
    BlogWeb.Endpoint.broadcast("bookmark:firehose", "bookmark_deleted", %{id: id})
    {:reply, :ok, socket}
  end

  @impl true
  def handle_in("search_bookmarks", %{"query" => query}, socket) do
    results = Store.search_bookmarks(socket.assigns.user_id, query)
    {:reply, {:ok, %{bookmarks: results}}, socket}
  end

  @impl true
  def handle_in("bookmark:create", params, socket) do
    # Extract the bookmark data from the params
    bookmark_data = %{
      "url" => params["url"],
      "title" => params["title"] || params["url"],
      "description" => params["description"] || "",
      "tags" => params["tags"] || [],
      "favicon_url" => params["favicon_url"] || nil
    }

    case Store.add_bookmark(
           bookmark_data["url"],
           bookmark_data["title"],
           bookmark_data["description"],
           bookmark_data["tags"],
           bookmark_data["favicon_url"],
           socket.assigns.user_id
         ) do
      {:ok, bookmark} ->
        broadcast!(socket, "bookmark_added", bookmark)
        BlogWeb.Endpoint.broadcast("bookmark:firehose", "bookmark_added", bookmark)
        {:reply, {:ok, bookmark}, socket}

      error ->
        {:reply, {:error, %{reason: "failed to add bookmark"}}, socket}
    end
  end
end
