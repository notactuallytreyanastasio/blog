defmodule BlogWeb.TemperSnakeLive do
  use BlogWeb, :live_view

  # The game is not written in Elixir and nothing here simulates it. It is a
  # snake game written in Temper, compiled to Blimp, run by the Blimp
  # interpreter compiled to WebAssembly, in the visitor's browser.
  #
  # All of that is a self-contained page under priv/static, so this LiveView
  # frames it rather than reimplementing it. An iframe because the page owns
  # its own DOM -- the Blimp view host patches it on every frame, and LiveView
  # patching the same nodes would be two writers on one document.
  @game_path "/static/temper-snake/index.html"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Snake, by way of Temper and Blimp")}
  end

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :game_path, @game_path)

    ~H"""
    <div class="max-w-2xl mx-auto px-4 py-10 space-y-6">
      <div>
        <h1 class="text-2xl font-semibold tracking-tight">Snake, by way of Temper and Blimp</h1>
        <p class="mt-1 text-sm text-gray-500">
          w a s d or the arrow keys. Click the board first so it has focus.
        </p>
      </div>

      <iframe
        src={@game_path}
        title="Snake"
        class="w-full rounded-lg border border-gray-200 dark:border-gray-800"
        style="height: 470px;"
        loading="lazy"
      >
      </iframe>

      <div class="prose prose-sm dark:prose-invert max-w-none">
        <p>
          The game is about 300 lines of
          <a href="https://github.com/temperlang/temper">Temper</a>, a language that
          compiles to several others.
          <a href="https://github.com/notactuallytreyanastasio/temper_snake">Someone wrote it</a>
          to run on six backends. This is a seventh: Blimp, an actor language
          with a tree-walking interpreter written in Zig.
        </p>
        <p>
          Nothing on this page simulates snake. The board you are looking at is
          drawn by the game's own <code>render</code> function, compiled from
          Temper to Blimp, executed by the Blimp interpreter compiled to
          WebAssembly and running in your browser. The score, the food
          placement and the collision that ends it are all the original Temper.
        </p>
        <p>
          The game's own runner reads <code>w/a/s/d</code> from standard input
          and sleeps 200ms between frames, which a browser gives you neither
          of. So there is a second runner, written in Blimp, that describes its
          input and its clock instead of performing them:
        </p>
        <pre><code>timer(200, :tick)
    key("w", :up), key("a", :left), key("s", :down), key("d", :right)</code></pre>
        <p>
          Those draw nothing. The host turns the first into an interval and the
          rest into a keydown table, and the game receives <code>:tick</code>
          and <code>:up</code> as ordinary actor messages.
        </p>
      </div>
    </div>
    """
  end
end
