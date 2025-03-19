defmodule BlogWeb.BookmarksFirehoseLive do
  use BlogWeb, :live_view
  alias Blog.Bookmarks.Bookmark

  @table_name :bookmarks_table

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      BlogWeb.Endpoint.subscribe("bookmark:firehose")
    end

    bookmarks = get_all_bookmarks()
    tag_counts = get_tag_counts(bookmarks)

    {:ok,
     assign(socket,
       page_title: "Bookmarks Firehose",
       bookmarks: bookmarks,
       all_bookmarks: bookmarks,
       selected_tag: nil,
       tag_counts: tag_counts
     )}
  end

  @impl true
  def handle_info(%{event: "bookmark_added", payload: %Bookmark{} = bookmark}, socket) do
    all_bookmarks =
      [bookmark | socket.assigns.all_bookmarks]
      |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
      |> Enum.take(50)

    filtered_bookmarks = filter_bookmarks(all_bookmarks, socket.assigns.selected_tag)
    tag_counts = get_tag_counts(all_bookmarks)

    {:noreply,
     assign(socket,
       bookmarks: filtered_bookmarks,
       all_bookmarks: all_bookmarks,
       tag_counts: tag_counts
     )}
  end

  @impl true
  def handle_info(%{event: "bookmark_deleted", payload: %{id: id}}, socket) do
    all_bookmarks = Enum.reject(socket.assigns.all_bookmarks, &(&1.id == id))
    filtered_bookmarks = filter_bookmarks(all_bookmarks, socket.assigns.selected_tag)
    tag_counts = get_tag_counts(all_bookmarks)

    {:noreply,
     assign(socket,
       bookmarks: filtered_bookmarks,
       all_bookmarks: all_bookmarks,
       tag_counts: tag_counts
     )}
  end

  @impl true
  def handle_event("filter_tag", %{"tag" => tag}, socket) do
    selected_tag = if socket.assigns.selected_tag == tag, do: nil, else: tag
    filtered_bookmarks = filter_bookmarks(socket.assigns.all_bookmarks, selected_tag)

    {:noreply,
     assign(socket,
       selected_tag: selected_tag,
       bookmarks: filtered_bookmarks
     )}
  end

  defp get_all_bookmarks do
    case :ets.info(@table_name) do
      :undefined ->
        []

      _ ->
        :ets.tab2list(@table_name)
        |> Enum.map(fn {_id, bookmark} -> bookmark end)
        |> Enum.sort_by(& &1.inserted_at, {:desc, DateTime})
        |> Enum.take(50)
    end
  end

  defp get_tag_counts(bookmarks) do
    bookmarks
    |> Enum.flat_map(& &1.tags)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_tag, count} -> count end, :desc)
    |> Enum.take(5)
  end

  defp filter_bookmarks(bookmarks, nil), do: bookmarks

  defp filter_bookmarks(bookmarks, tag) do
    Enum.filter(bookmarks, fn bookmark ->
      tag in bookmark.tags
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-fuchsia-50 to-cyan-50">
      <div class="max-w-7xl mx-auto py-8 px-4">
        <div class="flex gap-6">
          <div class="w-64 shrink-0">
            <div class="bg-white/80 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-fuchsia-100">
              <div class="flex items-center mb-4">
                <div class="w-2 h-2 rounded-full bg-fuchsia-400 mr-1"></div>
                <div class="w-2 h-2 rounded-full bg-cyan-400 mr-1"></div>
                <div class="w-2 h-2 rounded-full bg-indigo-400 mr-2"></div>
                <h3 class="text-lg font-semibold text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-600 to-cyan-600">
                  Popular Tags
                </h3>
              </div>
              <div class="space-y-2">
                <%= for {tag, count} <- @tag_counts do %>
                  <button
                    phx-click="filter_tag"
                    phx-value-tag={tag}
                    class={"w-full text-left px-3 py-2 rounded-lg text-sm transition-colors #{if @selected_tag == tag, do: "bg-indigo-100 text-indigo-900", else: "hover:bg-white/50 text-gray-600"}"}
                  >
                    <div class="flex justify-between items-center">
                      <span class="font-medium">{tag}</span>
                      <span class={"px-2 py-0.5 rounded-full text-xs #{if @selected_tag == tag, do: "bg-indigo-200 text-indigo-900", else: "bg-gray-200 text-gray-700"}"}>
                        {count}
                      </span>
                    </div>
                  </button>
                <% end %>
              </div>
            </div>
          </div>

          <div class="flex-1">
            <div class="bg-white/80 backdrop-blur-sm rounded-xl p-6 shadow-lg border border-fuchsia-100">
              <div class="flex items-center mb-6">
                <div class="w-3 h-3 rounded-full bg-fuchsia-400 mr-2"></div>
                <div class="w-3 h-3 rounded-full bg-cyan-400 mr-2"></div>
                <div class="w-3 h-3 rounded-full bg-indigo-400 mr-4"></div>
                <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-600 to-cyan-600">
                  <%= if @selected_tag do %>
                    Bookmarks tagged with "{@selected_tag}"
                  <% else %>
                    All Bookmarks
                  <% end %>
                </h2>
              </div>

              <div class="space-y-0.5">
                <%= for bookmark <- @bookmarks do %>
                  <div class="flex items-center px-3 py-1.5 text-sm group">
                    <div class="w-[100px] shrink-0">
                      <span class="font-mono text-fuchsia-600/70">
                        {Calendar.strftime(bookmark.inserted_at, "%H:%M:%S")}
                      </span>
                    </div>

                    <div class="w-[200px] shrink-0 flex gap-1">
                      <%= for tag <- bookmark.tags do %>
                        <span class="text-cyan-600/90 font-medium">{tag}</span>
                      <% end %>
                    </div>

                    <div class="flex-1 min-w-0">
                      <a
                        href={bookmark.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        class="text-indigo-600 group-hover:text-indigo-500 block truncate"
                      >
                        {bookmark.title || bookmark.url}
                      </a>
                    </div>

                    <div class="w-[60px] text-right shrink-0">
                      <span class="text-gray-500 text-xs">reddit</span>
                    </div>
                  </div>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
