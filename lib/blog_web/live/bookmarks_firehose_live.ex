defmodule BlogWeb.BookmarksFirehoseLive do
  use BlogWeb, :live_view

  @table_name :bookmarks_table

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      BlogWeb.Endpoint.subscribe("bookmark:firehose")
    end

    {:ok,
     assign(socket,
       page_title: "Bookmarks Firehose",
       bookmarks: get_all_bookmarks()
     )}
  end

  @impl true
  def handle_info(%{event: "bookmark_added", payload: bookmark}, socket) do
    bookmarks = [bookmark | socket.assigns.bookmarks]
                |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
                |> Enum.take(50)

    {:noreply, assign(socket, bookmarks: bookmarks)}
  end

  @impl true
  def handle_info(%{event: "bookmark_deleted", payload: %{id: id}}, socket) do
    bookmarks = Enum.reject(socket.assigns.bookmarks, &(&1.id == id))
    {:noreply, assign(socket, bookmarks: bookmarks)}
  end

  defp get_all_bookmarks do
    case :ets.info(@table_name) do
      :undefined -> []
      _ ->
        :ets.tab2list(@table_name)
        |> Enum.map(fn {_id, bookmark} -> bookmark end)
        |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
        |> Enum.take(50)
    end
  end

  defp get_subreddit(tags) do
    tags |> Enum.find(fn tag -> String.starts_with?(tag, "r/") end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-fuchsia-50 to-cyan-50">
      <div class="max-w-7xl mx-auto py-8 px-4">
        <div class="bg-white/80 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-fuchsia-100">
          <div class="flex items-center mb-6">
            <div class="w-3 h-3 rounded-full bg-fuchsia-400 mr-2"></div>
            <div class="w-3 h-3 rounded-full bg-cyan-400 mr-2"></div>
            <div class="w-3 h-3 rounded-full bg-indigo-400 mr-4"></div>
            <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-600 to-cyan-600">
              Bookmarks Firehose
            </h2>
          </div>

          <div class="space-y-0.5">
            <%= for bookmark <- @bookmarks do %>
              <div class="flex items-center px-3 py-1.5 text-sm rounded-lg hover:bg-white/80 group transition-colors">
                <div class="flex items-center gap-2 w-[140px] shrink-0">
                  <span class="font-mono text-fuchsia-600/70"><%= Calendar.strftime(bookmark.inserted_at, "%H:%M:%S") %></span>
                </div>

                <a href={bookmark.url}
                   target="_blank"
                   rel="noopener noreferrer"
                   class="text-indigo-600 group-hover:text-indigo-500 flex-1 hover:underline">
                  <%= bookmark.title || bookmark.url %>
                </a>

                <div class="w-[60px] text-right shrink-0">
                  <span class="bg-gradient-to-r from-fuchsia-100 to-cyan-100 text-xs px-2 py-0.5 rounded-full text-gray-600 font-medium">reddit</span>
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
