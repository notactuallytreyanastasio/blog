defmodule BlogWeb.MirrorLive do
  @moduledoc "Self-reflecting code display that shows its own source with spinning character animations."
  use BlogWeb, :live_view

  require Logger

  alias Blog.Mirror.SourceProcessor

  @source_url "https://raw.githubusercontent.com/notactuallytreyanastasio/blog/main/lib/blog_web/live/mirror_live.ex"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Task.async(fn -> fetch_source_code() end)
    end

    {:ok,
     assign(socket,
       lines: nil,
       page_title: "I am looking at myself",
       page_description: "A page that shows its own source code",
       page_image: nil
     )}
  end

  @impl true
  def handle_info({ref, source_code}, socket) when is_reference(ref) do
    Process.demonitor(ref, [:flush])
    characters = SourceProcessor.process(source_code)
    {:noreply, assign(socket, lines: characters)}
  end

  def handle_info({:DOWN, _, :process, _, reason}, socket) do
    Logger.error("Failed to fetch source code: #{inspect(reason)}")
    characters = SourceProcessor.process(SourceProcessor.fallback_source())
    {:noreply, assign(socket, lines: characters)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="os-desktop-osx">
      <div class="os-window os-window-osx mirror-window">
        <div class="os-titlebar">
          <div class="os-titlebar-buttons">
            <a href="/" class="os-btn-close"></a>
            <span class="os-btn-min"></span>
            <span class="os-btn-max"></span>
          </div>
          <span class="os-titlebar-title">Mirror.app - Self-Reflecting Code</span>
          <div class="os-titlebar-spacer"></div>
        </div>
        <div class="os-content mirror-content">
          <div class="p-6">
            <h1 class="text-2xl font-bold mb-6 text-white">
              Mirror Mirror on the wall, who's the most meta of them all?
            </h1>
            <div class="bg-gray-800 rounded-lg p-6 shadow-lg">
              <pre class="text-sm font-mono text-white mirror-code"><code class="language-elixir"><%= if @lines do %><%= for line <- @lines do %><%= for char <- line do %><span class="mirror-char" style={"animation: mirror-spin-#{char.duration} #{char.duration}s linear #{char.delay}ms infinite;"}><%= char.char %></span><% end %>
              <% end %><% else %>Loading source code...<% end %></code></pre>
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <span>Viewing: mirror_live.ex</span>
          <span>Mode: Self-Reflection</span>
        </div>
      </div>
    </div>
    """
  end

  defp fetch_source_code do
    case Blog.CodeDecompiler.decompile_to_string(__MODULE__) do
      {:error, _} -> fetch_from_github()
      result when is_binary(result) -> result
    end
  rescue
    e ->
      Logger.error("Exception decompiling: #{inspect(e)}")
      fetch_from_github()
  end

  defp fetch_from_github do
    case Req.get(@source_url) do
      {:ok, %{status: 200, body: body}} ->
        body

      error ->
        Logger.error("Failed to fetch from GitHub: #{inspect(error)}")
        SourceProcessor.fallback_source()
    end
  rescue
    e ->
      Logger.error("Exception fetching from GitHub: #{inspect(e)}")
      SourceProcessor.fallback_source()
  end

  @doc false
  def source_url, do: @source_url
end
