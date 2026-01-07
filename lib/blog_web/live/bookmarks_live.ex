defmodule BlogWeb.BookmarksLive do
  use BlogWeb, :live_view
  alias Blog.Bookmarks.Store

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      topic = "bookmarks:#{socket.assigns.user_id}"
      BlogWeb.Endpoint.subscribe(topic)
    end

    bookmarks = Store.list_bookmarks(socket.assigns.user_id)

    {:ok,
     assign(socket,
       bookmarks: bookmarks,
       search_query: "",
       page_title: "My Bookmarks"
     )}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    bookmarks = Store.search_bookmarks(socket.assigns.user_id, query)
    {:noreply, assign(socket, bookmarks: bookmarks, search_query: query)}
  end

  @impl true
  def handle_event("delete_bookmark", %{"id" => id}, socket) do
    :ok = Store.delete_bookmark(id)
    bookmarks = Store.list_bookmarks(socket.assigns.user_id)
    {:noreply, assign(socket, :bookmarks, bookmarks)}
  end

  @impl true
  def handle_info(%{event: "bookmark_added", payload: bookmark}, socket) do
    bookmarks =
      [bookmark | socket.assigns.bookmarks]
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})

    {:noreply, assign(socket, :bookmarks, bookmarks)}
  end

  @impl true
  def handle_info(%{event: "bookmark_deleted", payload: %{id: id}}, socket) do
    bookmarks = Enum.reject(socket.assigns.bookmarks, &(&1.id == id))
    {:noreply, assign(socket, :bookmarks, bookmarks)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="os-desktop-win98">
      <div class="os-window os-window-win98" style="width: 100%; height: calc(100vh - 40px); max-width: none;">
        <div class="os-titlebar">
          <span class="os-titlebar-title">📑 My Bookmarks - Internet Explorer</span>
          <div class="os-titlebar-buttons">
            <span class="os-btn">_</span>
            <span class="os-btn">□</span>
            <a href="/" class="os-btn">×</a>
          </div>
        </div>
        <div class="os-menubar">
          <span>File</span>
          <span>Edit</span>
          <span>Favorites</span>
          <span>Help</span>
        </div>
        <div class="os-content" style="height: calc(100% - 80px); overflow-y: auto; background: #c0c0c0;">
          <div class="p-4">
            <div class="flex justify-between items-center mb-4">
              <h1 class="text-xl font-bold">My Bookmarks</h1>
              <div class="relative">
                <form phx-change="search" class="flex items-center">
                  <input
                    type="text"
                    name="query"
                    value={@search_query}
                    placeholder="Search bookmarks..."
                    class="w-64 px-3 py-2 border-2 inset bg-white text-sm"
                  />
                </form>
              </div>
            </div>

            <div class="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
              <%= for bookmark <- @bookmarks do %>
                <div class="bg-white border-2 outset p-4">
                  <div class="flex items-start space-x-3">
                    <%= if bookmark.favicon_url do %>
                      <img src={bookmark.favicon_url} class="w-5 h-5" alt="" />
                    <% end %>
                    <div class="flex-1 min-w-0">
                      <h3 class="font-bold text-sm text-blue-800 truncate hover:underline">
                        <a href={bookmark.url} target="_blank" rel="noopener noreferrer">
                          {bookmark.title || bookmark.url}
                        </a>
                      </h3>
                      <%= if bookmark.description do %>
                        <p class="mt-1 text-xs text-gray-600">
                          {bookmark.description}
                        </p>
                      <% end %>
                      <%= if bookmark.tags != [] do %>
                        <div class="mt-2 flex flex-wrap gap-1">
                          <%= for tag <- bookmark.tags do %>
                            <span class="inline-flex items-center px-2 py-0.5 bg-[#000080] text-white text-xs">
                              {tag}
                            </span>
                          <% end %>
                        </div>
                      <% end %>
                    </div>
                    <div class="flex-shrink-0">
                      <button
                        phx-click="delete_bookmark"
                        phx-value-id={bookmark.id}
                        class="text-red-600 hover:text-red-800 text-sm font-bold"
                      >
                        ×
                      </button>
                    </div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <div class="os-statusbar-section">Bookmarks: {length(@bookmarks)}</div>
          <div class="os-statusbar-section" style="flex: 1;">Ready</div>
        </div>
      </div>
    </div>
    """
  end
end
