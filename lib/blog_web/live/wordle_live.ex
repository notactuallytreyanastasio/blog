defmodule BlogWeb.WordleLive do
  use BlogWeb, :live_view
  require Logger
  alias Blog.Wordle.Game

  @impl true
  def mount(_params, _session, socket) do
    # Create a new game instance
    game = Game.new()

    {:ok,
     assign(socket,
       game: game,
       page_title: "Wordle Clone",
       meta_attrs: [
         %{name: "description", content: "A LiveView wordle clone"},
         %{property: "og:title", content: "Wordle Clone"},
         %{
           property: "og:description",
           content: "A LiveView wordle clone"
         },
         %{property: "og:type", content: "website"}
       ]
     )}
  end

  @impl true
  def handle_event("new-game", _params, socket) do
    game = Game.reset_game(socket.assigns.game)
    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_event("toggle-hard-mode", _params, socket) do
    case Game.toggle_hard_mode(socket.assigns.game) do
      {:ok, game} -> {:noreply, assign(socket, game: game)}
      {:error, game} -> {:noreply, assign(socket, game: game)}
    end
  end

  @impl true
  def handle_event("key-press", %{"key" => key}, socket) do
    case Game.handle_key_press(socket.assigns.game, key) do
      {:ok, game} ->
        {:noreply, assign(socket, game: game)}

      {:error, game} ->
        {:noreply, assign(socket, game: game)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-[500px] p-2 md:p-4">
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-3xl font-bold">Wordle Clone</h1>
        <button
          class={"px-4 py-2 rounded font-bold text-sm #{if @game.hard_mode, do: "bg-yellow-500 text-white", else: "bg-gray-200 text-gray-700"}"}
          phx-click="toggle-hard-mode"
          disabled={not Enum.empty?(@game.guesses)}
        >
          HARD MODE
        </button>
      </div>

      <%!-- Mobile keyboard input --%>
      <input
        type="text"
        class="sr-only"
        id="mobile-input"
        autocomplete="off"
        spellcheck="false"
        autocapitalize="none"
        inputmode="text"
        phx-hook="FocusInput"
      />

      <div class="grid grid-rows-6 gap-[5px] mb-4" id="game-board">
        <%= for %{word: guess, result: result} <- @game.guesses do %>
          <div class="grid grid-cols-5 gap-[5px]">
            <%= for {letter, status} <- Enum.zip(String.graphemes(guess), result) do %>
              <div class={"w-full aspect-square flex items-center justify-center text-2xl font-bold text-white rounded-none uppercase transition-colors duration-500 #{color_class(status)}"}>
                <%= letter %>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if length(@game.guesses) < @game.max_attempts && !@game.game_over do %>
          <div class="grid grid-cols-5 gap-[5px]">
            <%= for i <- 0..4 do %>
              <div class={"w-full aspect-square flex items-center justify-center text-2xl font-bold rounded-none uppercase border-2 #{if i < String.length(@game.current_guess), do: "border-gray-600", else: "border-gray-300"}"}>
                <%= String.at(@game.current_guess, i) %>
              </div>
            <% end %>
          </div>

          <%= if length(@game.guesses) < @game.max_attempts - 1 do %>
            <%= for _i <- (length(@game.guesses) + 1)..(@game.max_attempts - 1) do %>
              <div class="grid grid-cols-5 gap-[5px]">
                <%= for _j <- 1..5 do %>
                  <div class="w-full aspect-square flex items-center justify-center text-2xl font-bold rounded-none border-2 border-gray-200">
                  </div>
                <% end %>
              </div>
            <% end %>
          <% end %>
        <% end %>
      </div>

      <%= if @game.message do %>
        <div class="text-center mb-4 font-bold text-lg">
          <%= @game.message %>
        </div>
      <% end %>

      <div class="grid grid-rows-3 gap-1 w-full">
        <%= for row <- keyboard_layout() do %>
          <div class="flex justify-center gap-1">
            <%= for key <- row do %>
              <button
                class={"flex-1 h-14 flex items-center justify-center rounded text-sm font-bold #{if key in ["Enter", "Backspace"], do: "px-1 text-xs", else: "px-0.5"} #{keyboard_color_class(Map.get(@game.used_letters, key))}"}
                phx-click="key-press"
                phx-touch-start="key-press"
                phx-value-key={key}
              >
                <%= if key == "Backspace" do %>
                  ⌫
                <% else %>
                  <%= String.upcase(key) %>
                <% end %>
              </button>
            <% end %>
          </div>
        <% end %>
      </div>

      <%= if @game.game_over do %>
        <div class="text-center mt-8">
          <button
            class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
            phx-click="new-game"
          >
            New Game
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp keyboard_layout do
    [
      ~w(q w e r t y u i o p),
      ~w(a s d f g h j k l),
      ~w(Enter z x c v b n m Backspace)
    ]
  end

  defp color_class(:correct), do: "bg-green-600 border-green-600"
  defp color_class(:present), do: "bg-yellow-500 border-yellow-500"
  defp color_class(:absent), do: "bg-gray-600 border-gray-600"
  defp color_class(_), do: "border-2 border-gray-300"

  defp keyboard_color_class(:correct), do: "bg-green-600 text-white"
  defp keyboard_color_class(:present), do: "bg-yellow-500 text-white"
  defp keyboard_color_class(:absent), do: "bg-gray-600 text-white"
  defp keyboard_color_class(_), do: "bg-gray-200"
end
