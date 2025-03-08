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
    bookmarks = [bookmark | socket.assigns.bookmarks]
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
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-bold text-gray-900">My Bookmarks</h1>
        <div class="relative">
          <form phx-change="search" class="flex items-center">
            <input
              type="text"
              name="query"
              value={@search_query}
              placeholder="Search bookmarks..."
              class="w-64 px-4 py-2 border border-gray-300 rounded-lg focus:ring-indigo-500 focus:border-indigo-500"
            />
          </form>
        </div>
      </div>

      <div class="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3">
        <%= for bookmark <- @bookmarks do %>
          <div class="bg-white overflow-hidden shadow rounded-lg">
            <div class="p-6">
              <div class="flex items-start space-x-4">
                <%= if bookmark.favicon_url do %>
                  <img src={bookmark.favicon_url} class="w-6 h-6" alt="" />
                <% end %>
                <div class="flex-1 min-w-0">
                  <h3 class="text-lg font-medium text-gray-900 truncate">
                    <a href={bookmark.url} target="_blank" rel="noopener noreferrer">
                      <%= bookmark.title || bookmark.url %>
                    </a>
                  </h3>
                  <%= if bookmark.description do %>
                    <p class="mt-1 text-sm text-gray-500">
                      <%= bookmark.description %>
                    </p>
                  <% end %>
                  <%= if bookmark.tags != [] do %>
                    <div class="mt-2 flex flex-wrap gap-2">
                      <%= for tag <- bookmark.tags do %>
                        <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-indigo-100 text-indigo-800">
                          <%= tag %>
                        </span>
                      <% end %>
                    </div>
                  <% end %>
                </div>
                <div class="flex-shrink-0">
                  <button
                    phx-click="delete_bookmark"
                    phx-value-id={bookmark.id}
                    class="text-gray-400 hover:text-gray-500"
                  >
                    <svg class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
