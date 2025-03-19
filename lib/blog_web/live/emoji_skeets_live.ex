defmodule BlogWeb.EmojiSkeetsLive do
  use BlogWeb, :live_view
  require Logger

  @emoji_options [
    {"😀", "grinning face"},
    {"❤️", "heart"},
    {"👍", "thumbs up"},
    {"🔥", "fire"},
    {"✨", "sparkles"},
    {"🎉", "party popper"},
    {"😂", "face with tears of joy"},
    {"🤔", "thinking face"},
    {"👀", "eyes"},
    {"🚀", "rocket"},
    {"😍", "heart eyes"},
    {"🙏", "folded hands"},
    {"💯", "hundred points"},
    {"🤣", "rolling on the floor laughing"},
    {"😎", "cool face with sunglasses"},
    {"👏", "clapping hands"},
    {"🌈", "rainbow"},
    {"💪", "flexed biceps"},
    {"🤷", "person shrugging"},
    {"🔗", "link"}
  ]

  @max_skeets 10_000

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to the Bluesky feed
      Phoenix.PubSub.subscribe(Blog.PubSub, "bluesky:skeet")
    end

    {:ok,
     assign(socket,
       page_title: "Emoji Skeet Filter",
       meta_attrs: [
         %{name: "title", content: "Emoji Skeet Filter"},
         %{name: "description", content: "Filter Bluesky posts by emoji"},
         %{property: "og:title", content: "Emoji Skeet Filter"},
         %{property: "og:description", content: "Filter Bluesky posts by emoji"},
         %{property: "og:type", content: "website"}
       ],
       selected_emojis: [],
       text_filters: [],
       text_input: "",
       skeets: [],
       filtered_skeets: [],
       emoji_options: @emoji_options
     )}
  end

  def handle_event("toggle_emoji", %{"emoji" => emoji}, socket) do
    selected_emojis = socket.assigns.selected_emojis

    # Toggle the emoji (add if not present, remove if present)
    updated_emojis =
      if Enum.member?(selected_emojis, emoji) do
        Enum.reject(selected_emojis, &(&1 == emoji))
      else
        [emoji | selected_emojis]
      end

    # Apply the filter with the updated emoji list
    filtered_skeets =
      filter_skeets(socket.assigns.skeets, updated_emojis, socket.assigns.text_filters)

    {:noreply, assign(socket, selected_emojis: updated_emojis, filtered_skeets: filtered_skeets)}
  end

  def handle_event("add_text_filter", %{"text_filter" => %{"value" => ""}}, socket) do
    # Don't add empty filters
    {:noreply, socket}
  end

  def handle_event("add_text_filter", %{"text_filter" => %{"value" => value}}, socket) do
    # Add the new text filter if it's not already in the list
    text_filters =
      if value not in socket.assigns.text_filters do
        [value | socket.assigns.text_filters]
      else
        socket.assigns.text_filters
      end

    # Apply the updated filters
    filtered_skeets =
      filter_skeets(
        socket.assigns.skeets,
        socket.assigns.selected_emojis,
        text_filters
      )

    {:noreply,
     assign(socket,
       text_filters: text_filters,
       text_input: "",
       filtered_skeets: filtered_skeets
     )}
  end

  def handle_event("remove_text_filter", %{"filter" => filter}, socket) do
    # Remove the text filter
    text_filters = Enum.reject(socket.assigns.text_filters, &(&1 == filter))

    # Apply the updated filters
    filtered_skeets =
      filter_skeets(
        socket.assigns.skeets,
        socket.assigns.selected_emojis,
        text_filters
      )

    {:noreply, assign(socket, text_filters: text_filters, filtered_skeets: filtered_skeets)}
  end

  def handle_event("update_text_input", %{"value" => value}, socket) do
    {:noreply, assign(socket, text_input: value)}
  end

  def handle_info({:new_skeet, skeet}, socket) do
    # Add the new skeet to the list, keeping only the most recent @max_skeets
    updated_skeets =
      [skeet | socket.assigns.skeets]
      |> Enum.take(@max_skeets)

    # Apply the current filters to the updated skeet list
    filtered_skeets =
      filter_skeets(
        updated_skeets,
        socket.assigns.selected_emojis,
        socket.assigns.text_filters
      )

    {:noreply, assign(socket, skeets: updated_skeets, filtered_skeets: filtered_skeets)}
  end

  defp filter_skeets(skeets, [], []) do
    # If no emojis or text filters are selected, show no skeets
    []
  end

  defp filter_skeets(skeets, selected_emojis, text_filters) do
    # Filter skeets that match both emoji and text filters
    Enum.filter(skeets, fn skeet ->
      emoji_match =
        if selected_emojis == [] do
          # No emoji filter applied
          true
        else
          Enum.any?(selected_emojis, fn emoji ->
            String.contains?(skeet, emoji)
          end)
        end

      text_match =
        if text_filters == [] do
          # No text filter applied
          true
        else
          Enum.all?(text_filters, fn filter ->
            String.contains?(String.downcase(skeet), String.downcase(filter))
          end)
        end

      emoji_match and text_match
    end)
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 py-8">
      <div class="max-w-4xl mx-auto px-4">
        <h1 class="text-3xl font-bold mb-6">Emoji Skeet Filter</h1>

        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 class="text-xl font-semibold mb-4">Select Emojis to Filter</h2>
          <div class="flex flex-wrap gap-3">
            <%= for {emoji, description} <- @emoji_options do %>
              <button
                phx-click="toggle_emoji"
                phx-value-emoji={emoji}
                class={"p-3 text-2xl rounded-lg transition-all #{if emoji in @selected_emojis, do: "bg-blue-100 ring-2 ring-blue-500", else: "bg-gray-100 hover:bg-gray-200"}"}
                title={description}
              >
                {emoji}
              </button>
            <% end %>
          </div>

          <div class="mt-6">
            <h2 class="text-xl font-semibold mb-4">Add Text Filters</h2>
            <form phx-submit="add_text_filter" class="flex gap-2">
              <input
                type="text"
                name="text_filter[value]"
                value={@text_input}
                phx-keyup="update_text_input"
                phx-value-value={@text_input}
                placeholder="Enter text to filter by..."
                class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
              />
              <button
                type="submit"
                class="px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
              >
                Add Filter
              </button>
            </form>

            <%= if @text_filters != [] do %>
              <div class="mt-3 flex flex-wrap gap-2">
                <%= for filter <- @text_filters do %>
                  <span class="inline-flex items-center px-3 py-1 bg-blue-100 text-blue-800 rounded-full text-sm">
                    {filter}
                    <button
                      phx-click="remove_text_filter"
                      phx-value-filter={filter}
                      class="ml-2 text-blue-500 hover:text-blue-700"
                    >
                      &times;
                    </button>
                  </span>
                <% end %>
              </div>
            <% end %>
          </div>

          <div class="mt-4 text-sm text-gray-600">
            <%= if @selected_emojis == [] and @text_filters == [] do %>
              <p>
                No filters selected. Select at least one emoji or add a text filter to see skeets.
              </p>
            <% else %>
              <%= if @selected_emojis != [] do %>
                <p>
                  Filtering for emojis: {Enum.map_join(@selected_emojis, " ", fn emoji -> emoji end)}
                </p>
              <% end %>

              <%= if @text_filters != [] do %>
                <p>
                  Filtering for text: {Enum.map_join(@text_filters, ", ", & &1)}
                </p>
              <% end %>
            <% end %>

            <div class="mt-2 flex justify-between text-gray-500">
              <p>Total skeets collected: {length(@skeets)}</p>
              <%= if @selected_emojis != [] or @text_filters != [] do %>
                <p>
                  Showing {length(@filtered_skeets)} of {length(@skeets)} skeets
                  ({length(@skeets) - length(@filtered_skeets)} filtered out)
                </p>
              <% end %>
            </div>
          </div>
        </div>

        <div class="space-y-4">
          <%= if @filtered_skeets == [] do %>
            <div class="bg-white rounded-lg shadow-md p-6 text-center">
              <p class="text-gray-500">
                <%= if @skeets == [] do %>
                  Waiting for skeets to appear...
                <% else %>
                  <%= if @selected_emojis == [] and @text_filters == [] do %>
                    Select at least one emoji or add a text filter to see skeets.
                  <% else %>
                    No skeets match your filters. Try selecting different filters.
                  <% end %>
                <% end %>
              </p>
            </div>
          <% else %>
            <%= for skeet <- @filtered_skeets do %>
              <div class="bg-white rounded-lg shadow-md p-4 transition-all hover:shadow-lg">
                <p class="text-gray-800 whitespace-pre-wrap break-words">{skeet}</p>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
