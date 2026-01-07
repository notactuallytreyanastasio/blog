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
    <div class="os-desktop-win98">
      <div class="os-window os-window-win98" style="width: 100%; height: calc(100vh - 40px); max-width: none;">
        <div class="os-titlebar">
          <span class="os-titlebar-title">🦋 Skeet Search - Bluesky Monitor</span>
          <div class="os-titlebar-buttons">
            <span class="os-btn">_</span>
            <span class="os-btn">□</span>
            <a href="/" class="os-btn">×</a>
          </div>
        </div>
        <div class="os-menubar">
          <span>File</span>
          <span>Search</span>
          <span>View</span>
          <span>Help</span>
        </div>
        <div class="os-content" style="height: calc(100% - 80px); overflow-y: auto; background: #c0c0c0;">
          <div class="p-4">
            <div class="bg-white border-2 inset p-4 mb-4">
              <h2 class="text-lg font-bold mb-3">Search Skeets</h2>
              <div>
                <input
                  type="text"
                  name="search_term"
                  value={@search_term}
                  phx-keyup="update_search_term"
                  phx-debounce="300"
                  phx-value-value={@search_term}
                  placeholder="Enter search term (e.g., elixir, phoenix, ❤️)..."
                  class="w-full px-3 py-2 border-2 inset bg-white"
                />
              </div>

              <div class="mt-3 text-sm">
                <%= if String.trim(@search_term) == "" do %>
                  <p>Enter a search term to see skeets.</p>
                <% else %>
                  <p>Filtering for: "<%= @search_term %>"</p>
                <% end %>

                <div class="mt-2 flex justify-between text-gray-600">
                  <p>Total skeets collected: {length(@skeets)}</p>
                  <%= if String.trim(@search_term) != "" do %>
                    <p>
                      Showing {length(@filtered_skeets)} of {length(@skeets)} skeets
                    </p>
                  <% end %>
                </div>
              </div>
            </div>

            <div class="space-y-2">
              <%= if @filtered_skeets == [] do %>
                <div class="bg-white border-2 inset p-4 text-center">
                  <p class="text-gray-600">
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
                  <div class="bg-white border-2 outset p-3 hover:bg-blue-50">
                    <p class="text-xs text-gray-500 mb-1">DID: {did}</p>
                    <p class="text-gray-800 whitespace-pre-wrap break-words">{skeet_text}</p>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <div class="os-statusbar-section">Skeets: {length(@skeets)}</div>
          <div class="os-statusbar-section" style="flex: 1;">Matches: {length(@filtered_skeets)}</div>
        </div>
      </div>
    </div>
    """
  end
end
