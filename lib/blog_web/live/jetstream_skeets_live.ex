defmodule BlogWeb.JetstreamSkeetsLive do
  use BlogWeb, :live_view
  require Logger

  @max_skeets 100_000

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Subscribe to Jetstream feed
      Phoenix.PubSub.subscribe(Blog.PubSub, "jetstream:skeet")
      # Also subscribe to original feed for comparison
      Phoenix.PubSub.subscribe(Blog.PubSub, "bluesky:skeet")
    end

    {:ok,
     assign(socket,
       page_title: "Jetstream vs Relay Comparison",
       meta_attrs: [
         %{name: "title", content: "Jetstream Feed Comparison"},
         %{name: "description", content: "Compare Bluesky Jetstream vs Relay feeds"}
       ],
       search_term: "",
       jetstream_skeets: [],
       relay_skeets: [],
       jetstream_filtered: [],
       relay_filtered: [],
       jetstream_count: 0,
       relay_count: 0,
       jetstream_matches: 0,
       relay_matches: 0
     )}
  end

  def handle_event("update_search_term", %{"value" => search_term}, socket) do
    jetstream_filtered = filter_skeets(socket.assigns.jetstream_skeets, search_term)
    relay_filtered = filter_skeets(socket.assigns.relay_skeets, search_term)
    
    {:noreply, assign(socket, 
      search_term: search_term, 
      jetstream_filtered: jetstream_filtered,
      relay_filtered: relay_filtered,
      jetstream_matches: length(jetstream_filtered),
      relay_matches: length(relay_filtered)
    )}
  end

  def handle_info({:new_skeet, skeet_data}, socket) do
    # For now, we'll track the source differently since both feeds broadcast to separate topics
    # This handler receives from both subscriptions, so we need to check the data
    source = :unknown  # We'll determine this based on message inspection for now
    
    # Handle both old format (string) and new format (map with text and did)
    {skeet_text, did} = case skeet_data do
      %{text: text, did: did} -> {text, did}
      text when is_binary(text) -> {text, "unknown"}
    end
    
    # Update the appropriate list based on source
    {updated_socket, _matched} = if source == :jetstream do
      updated_skeets = [{skeet_text, did} | socket.assigns.jetstream_skeets] |> Enum.take(@max_skeets)
      filtered = filter_skeets(updated_skeets, socket.assigns.search_term)
      matched = check_match(skeet_text, socket.assigns.search_term)
      
      if matched do
        Logger.info("JETSTREAM MATCH: '#{socket.assigns.search_term}' in: #{String.slice(skeet_text, 0, 100)}")
        print_receipt(skeet_text, did, socket.assigns.search_term, "JETSTREAM")
      end
      
      {assign(socket, 
        jetstream_skeets: updated_skeets,
        jetstream_filtered: filtered,
        jetstream_count: socket.assigns.jetstream_count + 1,
        jetstream_matches: if(matched, do: socket.assigns.jetstream_matches + 1, else: socket.assigns.jetstream_matches)
      ), matched}
    else
      updated_skeets = [{skeet_text, did} | socket.assigns.relay_skeets] |> Enum.take(@max_skeets)
      filtered = filter_skeets(updated_skeets, socket.assigns.search_term)
      matched = check_match(skeet_text, socket.assigns.search_term)
      
      if matched do
        Logger.info("RELAY MATCH: '#{socket.assigns.search_term}' in: #{String.slice(skeet_text, 0, 100)}")
        print_receipt(skeet_text, did, socket.assigns.search_term, "RELAY")
      end
      
      {assign(socket, 
        relay_skeets: updated_skeets,
        relay_filtered: filtered,
        relay_count: socket.assigns.relay_count + 1,
        relay_matches: if(matched, do: socket.assigns.relay_matches + 1, else: socket.assigns.relay_matches)
      ), matched}
    end

    {:noreply, updated_socket}
  end

  defp check_match(skeet_text, search_term) do
    normalized_search = search_term |> String.trim() |> String.downcase()
    normalized_search != "" and String.contains?(String.downcase(skeet_text), normalized_search)
  end

  defp print_receipt(skeet_text, did, search_term, source) do
    receipt_text = """
    === #{source} MATCH ===
    Search: #{search_term}
    Time: #{DateTime.utc_now() |> DateTime.to_string()}
    User: #{did}
    
    #{skeet_text}
    """
    
    # Execute receipt_printer.py script
    case System.cmd("python3", [
      "receipt_printer.py",
      receipt_text
    ], cd: File.cwd!(), stderr_to_stdout: true) do
      {output, 0} ->
        Logger.info("Printed #{source} match. Output: #{output}")
      {error, exit_code} ->
        Logger.error("Failed to print #{source} match. Exit: #{exit_code}, Error: #{error}")
    end
  end

  defp filter_skeets(skeets, search_term) do
    normalized_search_term = search_term |> String.trim() |> String.downcase()

    if normalized_search_term == "" do
      []
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
      <div class="max-w-7xl mx-auto px-4">
        <h1 class="text-3xl font-bold mb-6">Jetstream vs Relay Comparison</h1>

        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
          <h2 class="text-xl font-semibold mb-4">Search Filter</h2>
          <input
            type="text"
            value={@search_term}
            phx-keyup="update_search_term"
            phx-debounce="300"
            phx-value-value={@search_term}
            placeholder="Enter search term..."
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          
          <div class="mt-4 grid grid-cols-2 gap-4 text-sm">
            <div class="bg-blue-50 p-3 rounded">
              <h3 class="font-semibold text-blue-900">Jetstream Stats</h3>
              <p>Total received: {@jetstream_count}</p>
              <p>Matches found: {@jetstream_matches}</p>
              <p>Currently showing: {length(@jetstream_filtered)}</p>
            </div>
            <div class="bg-green-50 p-3 rounded">
              <h3 class="font-semibold text-green-900">Relay Stats</h3>
              <p>Total received: {@relay_count}</p>
              <p>Matches found: {@relay_matches}</p>
              <p>Currently showing: {length(@relay_filtered)}</p>
            </div>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-6">
          <!-- Jetstream Column -->
          <div>
            <h2 class="text-xl font-semibold mb-4 text-blue-700">
              Jetstream Feed
              <span class="text-sm font-normal text-gray-500 ml-2">
                (jetstream2.us-east.bsky.network)
              </span>
            </h2>
            <div class="space-y-3">
              <%= if @jetstream_filtered == [] do %>
                <div class="bg-white rounded-lg shadow-md p-4 text-center text-gray-500">
                  <%= if @search_term == "" do %>
                    Enter a search term to see Jetstream skeets
                  <% else %>
                    No Jetstream skeets match "{@search_term}"
                  <% end %>
                </div>
              <% else %>
                <%= for skeet_item <- Enum.take(@jetstream_filtered, 20) do %>
                  <% {skeet_text, did} = case skeet_item do
                    {text, did} -> {text, did}
                    text when is_binary(text) -> {text, "unknown"}
                  end %>
                  <div class="bg-white rounded-lg shadow-md p-3 border-l-4 border-blue-500">
                    <p class="text-xs text-gray-500 mb-1 truncate">DID: {did}</p>
                    <p class="text-sm text-gray-800 break-words">{String.slice(skeet_text, 0, 200)}<%= if String.length(skeet_text) > 200 do %>...<% end %></p>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>

          <!-- Relay Column -->
          <div>
            <h2 class="text-xl font-semibold mb-4 text-green-700">
              Relay Feed
              <span class="text-sm font-normal text-gray-500 ml-2">
                (bsky-relay.c.theo.io)
              </span>
            </h2>
            <div class="space-y-3">
              <%= if @relay_filtered == [] do %>
                <div class="bg-white rounded-lg shadow-md p-4 text-center text-gray-500">
                  <%= if @search_term == "" do %>
                    Enter a search term to see Relay skeets
                  <% else %>
                    No Relay skeets match "{@search_term}"
                  <% end %>
                </div>
              <% else %>
                <%= for skeet_item <- Enum.take(@relay_filtered, 20) do %>
                  <% {skeet_text, did} = case skeet_item do
                    {text, did} -> {text, did}
                    text when is_binary(text) -> {text, "unknown"}
                  end %>
                  <div class="bg-white rounded-lg shadow-md p-3 border-l-4 border-green-500">
                    <p class="text-xs text-gray-500 mb-1 truncate">DID: {did}</p>
                    <p class="text-sm text-gray-800 break-words">{String.slice(skeet_text, 0, 200)}<%= if String.length(skeet_text) > 200 do %>...<% end %></p>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end