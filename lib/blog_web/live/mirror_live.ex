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

    # Process the source code
    characters = process_source_code(source_code)

    {:noreply, assign(socket, lines: characters)}
  end

  def handle_info({:DOWN, _, :process, _, reason}, socket) do
    Logger.error("Failed to fetch source code: #{inspect(reason)}")

    # Create a fallback source code
    fallback = fallback_source_code()
    characters = process_source_code(fallback)

    {:noreply, assign(socket, lines: characters)}
  end

  defp process_source_code(source) do
    # Handle both string and error tuple cases
    source_str =
      case source do
        {:error, reason} ->
          Logger.error("Error decompiling source: #{inspect(reason)}")
          fallback_source_code()

        str when is_binary(str) ->
          str

        other ->
          Logger.error("Unexpected source format: #{inspect(other)}")
          fallback_source_code()
      end

    # Split into lines first, then characters
    source_str
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.graphemes()
      |> Enum.map(fn char ->
        %{
          char: char,
          duration: :rand.uniform(10) + 5,
          delay: :rand.uniform(5000),
          direction: if(:rand.uniform() > 0.5, do: 1, else: -1)
        }
      end)
    end)
  end

  defp fallback_source_code do
    """
    defmodule BlogWeb.MirrorLive do
      use BlogWeb, :live_view

      # Source code could not be loaded
      # This is a fallback representation

      def render(assigns) do
        ~H\"\"\"
        <div>
          <h1>Mirror Mirror on the wall</h1>
          <p>Source code could not be loaded</p>
        </div>
        \"\"\"
      end
    end
    """
  end

  defp fetch_source_code do
    try do
      # Try to decompile first
      result = CodeDecompiler.decompile_to_string(__MODULE__)

      # If result is an error tuple, try fetching from GitHub
      case result do
        {:error, _} ->
          fetch_from_github()

        _ ->
          result
      end
    rescue
      e ->
        Logger.error("Exception decompiling: #{inspect(e)}")
        fetch_from_github()
    end
  end

  defp fetch_from_github do
    try do
      case Req.get(@source_url) do
        {:ok, %{status: 200, body: body}} ->
          body

        error ->
          Logger.error("Failed to fetch from GitHub: #{inspect(error)}")
          fallback_source_code()
      end
    rescue
      e ->
        Logger.error("Exception fetching from GitHub: #{inspect(e)}")
        fallback_source_code()
    end
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-900 text-white p-8">
      <div class="max-w-4xl mx-auto">
        <h1 class="text-3xl font-bold mb-8">
          Mirror Mirror on the wall, who's the most meta of them all?
        </h1>
        <div class="bg-gray-800 rounded-lg p-6 shadow-lg">
          <pre class="text-sm font-mono" style="tab-size: 2;"><code class="language-elixir"><%= if assigns[:lines] do %><%= for line <- @lines do %><%= for char <- line do %><span style={"display: inline-block; animation: spin#{char.duration} #{char.duration}s linear #{char.delay}ms infinite;"}><%= char.char %></span><% end %>
          <% end %><% else %>Loading source code...<% end %></code></pre>
        </div>
      </div>
    </div>

    <style>
      <%= for duration <- 5..15 do %>
        @keyframes spin<%= duration %> {
          from { transform: rotate(0deg); }
          to { transform: rotate(<%= if rem(duration, 2) == 0, do: "360", else: "-360" %>deg); }
        }
      <% end %>
    </style>
    """
  end

  @doc """
  Source code available at: #{@source_url}
  """
end
