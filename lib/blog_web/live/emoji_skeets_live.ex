defmodule BlogWeb.EmojiSkeetsLive do
  use BlogWeb, :live_view
  require Logger

  @max_skeets 100_000

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "bluesky:skeet")
    end

    {:ok,
     assign(socket,
       page_title: "Skeet Search",
       meta_attrs: [
         %{name: "title", content: "Skeet Search"},
         %{name: "description", content: "Search Bluesky posts in real-time"},
         %{property: "og:title", content: "Skeet Search"},
         %{property: "og:description", content: "Search Bluesky posts in real-time"},
         %{property: "og:type", content: "website"}
       ],
       search_term: "",
       skeets: [],
       filtered_skeets: []
     )}
  end

  def handle_event("update_search_term", %{"value" => search_term}, socket) do
    filtered_skeets = filter_skeets(socket.assigns.skeets, search_term)
    {:noreply, assign(socket, search_term: search_term, filtered_skeets: filtered_skeets)}
  end

  def handle_info({:new_skeet, skeet_data}, socket) do
    # Handle both old format (string) and new format (map with text and did)
    {skeet_text, did} = case skeet_data do
      %{text: text, did: did} -> {text, did}
      text when is_binary(text) -> {text, "unknown"}
    end

    updated_skeets =
      [{skeet_text, did} | socket.assigns.skeets]
      |> Enum.take(@max_skeets)

    filtered_skeets =
      filter_skeets(
        updated_skeets,
        socket.assigns.search_term
      )

    # If the new skeet matches the search term, send it to the receipt printer
    normalized_search = socket.assigns.search_term |> String.trim() |> String.downcase()
    
    if normalized_search != "" and String.contains?(String.downcase(skeet_text), normalized_search) do
        # Format the receipt text with DID
        receipt_text = """
        Bluesky Skeet Match!
        Search: #{socket.assigns.search_term}
        Time: #{DateTime.utc_now() |> DateTime.to_string()}
        User: #{did}

        #{skeet_text}
        """
        
        # Execute receipt_printer.py script to print directly via CUPS
        case System.cmd("python3", [
          "receipt_printer.py",
          receipt_text
        ], cd: File.cwd!(), stderr_to_stdout: true) do
          {_output, 0} ->
            Logger.info("Printed skeet matching '#{socket.assigns.search_term}'")
          {error, _exit_code} ->
            Logger.error("Failed to print skeet: #{error}")
        end
    end

    {:noreply, assign(socket, skeets: updated_skeets, filtered_skeets: filtered_skeets)}
  end

  defp filter_skeets(skeets, search_term) do
    normalized_search_term = search_term |> String.trim() |> String.downcase()

    if normalized_search_term == "" do
      [] # No search term, show no results
    else
      Enum.filter(skeets, fn
        {skeet_text, _did} ->
          String.contains?(String.downcase(skeet_text), normalized_search_term)
        skeet_text when is_binary(skeet_text) ->
          String.contains?(String.downcase(skeet_text), normalized_search_term)
      end)
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100 py-8">
      <div class="max-w-4xl mx-auto px-4">
        <h1 class="text-3xl font-bold mb-6">Skeet Search</h1>

        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 class="text-xl font-semibold mb-4">Search Skeets</h2>
          <div>
            <input
              type="text"
              name="search_term"
              value={@search_term}
              phx-keyup="update_search_term"
              phx-debounce="300"
              phx-value-value={@search_term}
              placeholder="Enter search term (e.g., elixir, phoenix, ❤️)..."
              class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>

          <div class="mt-4 text-sm text-gray-600">
            <%= if String.trim(@search_term) == "" do %>
              <p>
                Enter a search term to see skeets.
              </p>
            <% else %>
              <p>
                Filtering for: "<%= @search_term %>"
              </p>
            <% end %>

            <div class="mt-2 flex justify-between text-gray-500">
              <p>Total skeets collected: {length(@skeets)}</p>
              <%= if String.trim(@search_term) != "" do %>
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
                  <%= if String.trim(@search_term) == "" do %>
                    Enter a search term above to see skeets.
                  <% else %>
                    No skeets match your search term: "<%= @search_term %>".
                  <% end %>
                <% end %>
              </p>
            </div>
          <% else %>
            <%= for skeet_item <- @filtered_skeets do %>
              <% {skeet_text, did} = case skeet_item do
                {text, did} -> {text, did}
                text when is_binary(text) -> {text, "unknown"}
              end %>
              <div class="bg-white rounded-lg shadow-md p-4 transition-all hover:shadow-lg">
                <p class="text-xs text-gray-500 mb-2">DID: {did}</p>
                <p class="text-gray-800 whitespace-pre-wrap break-words">{skeet_text}</p>
              </div>
            <% end %>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
