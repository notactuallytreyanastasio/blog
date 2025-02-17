defmodule BlogWeb.MirrorLive do
  use BlogWeb, :live_view
  require Logger

  @source_url "https://raw.githubusercontent.com/notactuallytreyanastasio/blog/main/lib/blog_web/live/mirror_live.ex"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      # Fetch source code asynchronously when client connects
      Task.async(fn -> fetch_source_code() end)
    end

    {:ok,
     assign(socket,
       source_code: "Loading source code...",
       page_title: "I am looking at myself",
       meta_attrs: [
         %{name: "title", content: "Mirror Mirror on the wall"},
         %{name: "description", content: "A page that shows its own source code"},
         %{property: "og:title", content: "Mirror Mirror on the wall"},
         %{property: "og:description", content: "A page that shows its own source code"},
         %{property: "og:type", content: "website"}
       ]
     )}
  end

  def handle_info({ref, source_code}, socket) when is_reference(ref) do
    # Flush the DOWN message
    Process.demonitor(ref, [:flush])
    {:noreply, assign(socket, source_code: source_code)}
  end

  defp fetch_source_code do
    case :httpc.request(:get, {@source_url, []}, [], []) do
      {:ok, {{_, 200, _}, _, body}} ->
        to_string(body)
      error ->
        Logger.error("Failed to fetch source code: #{inspect(error)}")
        "// Failed to load source code"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-900 text-white p-8">
      <div class="max-w-4xl mx-auto">
        <h1 class="text-3xl font-bold mb-8">Mirror Mirror on the wall, who's the most meta of them all?</h1>
        <div class="bg-gray-800 rounded-lg p-6 shadow-lg">
          <pre class="text-sm font-mono whitespace-pre-wrap overflow-x-auto">
            <code class="language-elixir">
              <%= @source_code %>
            </code>
          </pre>
        </div>
      </div>
    </div>
    """
  end
end
