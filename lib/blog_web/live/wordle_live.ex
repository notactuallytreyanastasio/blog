defmodule BlogWeb.WordleLive do
  use BlogWeb, :live_view
  require Logger
  alias Blog.Wordle.Game

  defmodule HardModeWarningComponent do
    use BlogWeb, :live_component

    @impl true
    def render(assigns) do
      ~H"""
      <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50" phx-click="dismiss-hard-mode-warning">
        <div class="bg-white rounded-lg p-6 max-w-sm mx-4 shadow-xl" phx-click-away="dismiss-hard-mode-warning">
          <div class="text-center">
            <div class="text-2xl mb-2">⚠️</div>
            <h2 class="text-lg font-bold mb-2">Hard Mode Enabled</h2>
            <p class="text-sm text-gray-600 mb-4">
              You're playing in Hard Mode! Any revealed hints must be used in subsequent guesses.
            </p>
            <button
              class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 text-sm font-medium"
              phx-click="dismiss-hard-mode-warning"
            >
              Got it!
            </button>
          </div>
        </div>
      </div>
      """
    end
  end

  @impl true
  def mount(_params, _session, socket) do
    player_id = get_player_id(socket)

    # Subscribe to the global wordle games topic
    Phoenix.PubSub.subscribe(Blog.PubSub, Game.topic())

    # Check if this is the first visit for hard mode warning
    show_hard_mode_warning = not visited_before?(socket)

    # Instead of creating a game immediately, just assign the player_id
    # and set up a placeholder for the game
    {:ok,
     assign(socket,
       game: nil,
       player_id: player_id,
       other_games: %{},
       show_hard_mode_warning: show_hard_mode_warning,
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

  # Initialize the game on first interaction
  defp lazy_load_game(socket) do
    case socket.assigns.game do
      nil ->
        # Create a new game instance on first interaction
        game = Game.new(socket.assigns.player_id)

        # Log game creation
        IO.puts(
          "WordleLive: Created new game session #{game.session_id} for player #{socket.assigns.player_id}"
        )

        # Subscribe to this specific game's topic
        Phoenix.PubSub.subscribe(Blog.PubSub, Game.game_topic(game.session_id))

        # Return socket with new game
        assign(socket, game: game)

      _game ->
        # Game already exists, return socket unchanged
        socket
    end
  end

  @impl true
  def handle_info({:game_update, %{session_id: session_id} = game_state}, socket) do
    is_me = socket.assigns.player_id == session_id

    if is_me do
      Logger.debug("Got update for my game")
      {:noreply, assign(socket, :game, game_state)}
    else
      Logger.debug("Got update for another player's game: #{session_id}")
      other_games = Map.put(socket.assigns.other_games, session_id, game_state)

      # Limit to 12 most recent games
      other_games =
        if map_size(other_games) > 12 do
          other_games
          |> Enum.sort_by(fn {_id, game} -> game.last_activity end, :desc)
          |> Enum.take(12)
          |> Map.new()
        else
          other_games
        end

      {:noreply, assign(socket, :other_games, other_games)}
    end
  end

  # Handle the :game_updated message format (which is what Game module is sending)
  @impl true
  def handle_info({:game_updated, game}, socket) do
    # Delegate to the existing handler by converting the message format
    handle_info({:game_update, game}, socket)
  end

  @impl true
  def handle_event("new-game", _params, socket) do
    # Ensure game is initialized
    socket = lazy_load_game(socket)
    game = Game.reset_game(socket.assigns.game)
    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_event("toggle-hard-mode", _params, socket) do
    # Ensure game is initialized
    socket = lazy_load_game(socket)

    case Game.toggle_hard_mode(socket.assigns.game) do
      {:ok, game} -> {:noreply, assign(socket, game: game)}
      {:error, game} -> {:noreply, assign(socket, game: game)}
    end
  end

  @impl true
  def handle_event("key-press", %{"key" => key}, socket) do
    # Ensure game is initialized
    socket = lazy_load_game(socket)

    case Game.handle_key_press(socket.assigns.game, key) do
      {:ok, game} ->
        {:noreply, assign(socket, game: game)}

      {:error, game} ->
        {:noreply, assign(socket, game: game)}
    end
  end

  @impl true
  def handle_event("dismiss-hard-mode-warning", _params, socket) do
    {:noreply, assign(socket, show_hard_mode_warning: false)}
  end

  @impl true
  def render(assigns) do
    assigns = assigns |> Map.put_new(:game, default_game_state(assigns.player_id))

    ~H"""
    <div class="fixed inset-0 overflow-hidden bg-gray-50">
      <!-- Background of other players' games -->
      <%= if map_size(@other_games) > 0 do %>
        <div class="absolute inset-0 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 2xl:grid-cols-8 gap-0.5 p-0.5 overflow-hidden">
          <%= for {session_id, game} <- Enum.sort_by(@other_games, fn {_id, game} -> game.last_activity end, :desc) do %>
            <div class="bg-white rounded-sm shadow-sm opacity-30 text-xs">
              <div class="flex justify-between items-center px-1 pt-1">
                <div class="font-bold truncate max-w-[90%] text-xs">
                  {game.player_id}
                  <span class={[if(game.hard_mode, do: "text-yellow-600", else: "hidden")]}>★</span>
                </div>
                <span class="text-xs text-gray-500">
                  {if game.last_activity, do: format_time_ago(game.last_activity), else: ""}
                </span>
              </div>

              <div class="text-xs px-1 flex justify-between">
                <div>{game.target_word}</div>
                <%= cond do %>
                  <% game.game_over && Enum.any?(game.guesses, fn %{word: word} -> word == game.target_word end) -> %>
                    <span class="text-green-600">Won</span>
                  <% game.game_over -> %>
                    <span class="text-red-600">Lost</span>
                  <% true -> %>
                    <span class="text-blue-600">{length(game.guesses)}/{game.max_attempts}</span>
                <% end %>
              </div>

              <div class="grid grid-rows-6 gap-[1px] p-1">
                <%= for %{word: guess, result: result} <- game.guesses do %>
                  <div class="grid grid-cols-5 gap-[1px]">
                    <%= for {letter, status} <- Enum.zip(String.graphemes(guess), result) do %>
                      <div class={[
                        "w-full aspect-square flex items-center justify-center text-base md:text-xl lg:text-2xl font-bold text-white rounded-none uppercase",
                        color_class(status)
                      ]}>
                        {letter}
                      </div>
                    <% end %>
                  </div>
                <% end %>

                <%= if length(game.guesses) < game.max_attempts && !game.game_over do %>
                  <div class="grid grid-cols-5 gap-[1px]">
                    <%= for i <- 0..4 do %>
                      <div class={[
                        "w-full aspect-square flex items-center justify-center text-base md:text-xl lg:text-2xl font-bold rounded-none uppercase border",
                        if(i < String.length(game.current_guess),
                          do: "border-gray-600",
                          else: "border-gray-300"
                        )
                      ]}>
                        {String.at(game.current_guess, i)}
                      </div>
                    <% end %>
                  </div>

                  <%= for _i <- (length(game.guesses) + 1)..(game.max_attempts - 1) do %>
                    <div class="grid grid-cols-5 gap-[1px]">
                      <%= for _j <- 1..5 do %>
                        <div class="w-full aspect-square flex items-center justify-center text-base md:text-xl lg:text-2xl font-bold rounded-none border border-gray-200">
                        </div>
                      <% end %>
                    </div>
                  <% end %>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% end %>
      
    <!-- Main player's game - centered on screen -->
      <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
        <div class="w-full max-w-[min(400px,90vw)] bg-white shadow-xl rounded-lg p-3 pointer-events-auto">
          <div class="flex justify-between items-center mb-1">
            <h1 class="text-xl font-bold">Wordle Clone</h1>
            <button
              class={"px-2 py-0.5 rounded font-bold text-xs #{if @game && @game.hard_mode, do: "bg-yellow-500 text-white", else: "bg-gray-200 text-gray-700"}"}
              phx-click="toggle-hard-mode"
              disabled={@game && not Enum.empty?(@game.guesses)}
            >
              HARD MODE
            </button>
          </div>

          <div class="text-[10px] text-gray-500 mb-1">
            Player ID: {@player_id}
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

          <div class="grid grid-rows-6 gap-[3px] mb-1" id="game-board">
            <%= if @game do %>
              <%= for %{word: guess, result: result} <- @game.guesses do %>
                <div class="grid grid-cols-5 gap-[3px]">
                  <%= for {letter, status} <- Enum.zip(String.graphemes(guess), result) do %>
                    <div class={"w-full aspect-square flex items-center justify-center text-lg sm:text-xl font-bold text-white rounded-none uppercase transition-colors duration-500 #{color_class(status)}"}>
                      {letter}
                    </div>
                  <% end %>
                </div>
              <% end %>

              <%= if length(@game.guesses) < @game.max_attempts && !@game.game_over do %>
                <div class="grid grid-cols-5 gap-[3px]">
                  <%= for i <- 0..4 do %>
                    <div class={"w-full aspect-square flex items-center justify-center text-lg sm:text-xl font-bold rounded-none uppercase border-2 #{if i < String.length(@game.current_guess), do: "border-gray-600", else: "border-gray-300"}"}>
                      {String.at(@game.current_guess, i)}
                    </div>
                  <% end %>
                </div>

                <%= if length(@game.guesses) < @game.max_attempts - 1 do %>
                  <%= for _i <- (length(@game.guesses) + 1)..(@game.max_attempts - 1) do %>
                    <div class="grid grid-cols-5 gap-[3px]">
                      <%= for _j <- 1..5 do %>
                        <div class="w-full aspect-square flex items-center justify-center text-lg sm:text-xl font-bold rounded-none border-2 border-gray-200">
                        </div>
                      <% end %>
                    </div>
                  <% end %>
                <% end %>
              <% end %>
            <% else %>
              <div class="grid grid-cols-5 gap-[3px]">
                <%= for _j <- 1..5 do %>
                  <div class="w-full aspect-square flex items-center justify-center text-lg sm:text-xl font-bold rounded-none border-2 border-gray-300">
                  </div>
                <% end %>
              </div>
              <%= for _i <- 1..5 do %>
                <div class="grid grid-cols-5 gap-[3px]">
                  <%= for _j <- 1..5 do %>
                    <div class="w-full aspect-square flex items-center justify-center text-lg sm:text-xl font-bold rounded-none border-2 border-gray-200">
                    </div>
                  <% end %>
                </div>
              <% end %>
            <% end %>
          </div>

          <%= if @game && @game.message do %>
            <div class="text-center mb-1 font-bold text-sm">
              {@game.message}
            </div>
          <% else %>
            <div class="text-center mb-1 font-medium text-sm text-gray-500">
              Type to start playing!
            </div>
          <% end %>

          <div class="grid grid-rows-3 gap-1 w-full">
            <%= for row <- keyboard_layout() do %>
              <div class="flex justify-center gap-1">
                <%= for key <- row do %>
                  <button
                    class={"flex-1 h-8 sm:h-10 flex items-center justify-center rounded text-xs font-bold #{if key in ["Enter", "Backspace"], do: "px-1 text-xs", else: "px-0.5"} #{keyboard_color_class(@game && Map.get(@game.used_letters || %{}, key))}"}
                    phx-click="key-press"
                    phx-touch-start="key-press"
                    phx-value-key={key}
                  >
                    <%= if key == "Backspace" do %>
                      ⌫
                    <% else %>
                      {String.upcase(key)}
                    <% end %>
                  </button>
                <% end %>
              </div>
            <% end %>
          </div>

          <%= if @game && @game.game_over do %>
            <div class="text-center mt-2">
              <%= cond do %>
                <%# Player won %>
                <% Enum.any?(@game.guesses, fn %{word: word} -> word == @game.target_word end) -> %>
                  <div class="mb-2">
                    <div class="text-green-600 font-bold text-lg">🎉 Congratulations!</div>
                    <div class="text-sm text-gray-600">You found the word!</div>
                  </div>
                <%# Player lost %>
                <% true -> %>
                  <div class="mb-2">
                    <div class="text-red-600 font-bold text-lg">Game Over</div>
                    <div class="text-sm text-gray-600">The word was:</div>
                    <div class="text-xl font-bold text-gray-800 uppercase tracking-wider mt-1 bg-gray-100 px-3 py-1 rounded">
                      {@game.target_word}
                    </div>
                  </div>
              <% end %>
              
              <button
                class="bg-green-600 text-white px-3 py-1 text-sm rounded hover:bg-green-700"
                phx-click="new-game"
              >
                New Game
              </button>
            </div>
          <% end %>
        </div>
      </div>

      <%!-- Hard Mode Warning Popup --%>
      <%= if @show_hard_mode_warning do %>
        <.live_component module={__MODULE__.HardModeWarningComponent} id="hard-mode-warning" />
      <% end %>
    </div>
    """
  end

  # Default game state for rendering before the real game is initialized
  defp default_game_state(player_id) do
    nil
  end

  defp keyboard_layout do
    [
      ~w(q w e r t y u i o p),
      ~w(a s d f g h j k l),
      ~w(Backspace z x c v b n m Enter)
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

  defp format_time_ago(timestamp) when is_binary(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, datetime, _} ->
        seconds_diff = DateTime.diff(DateTime.utc_now(), datetime)

        cond do
          seconds_diff < 60 -> "just now"
          seconds_diff < 3600 -> "#{div(seconds_diff, 60)} min ago"
          seconds_diff < 86400 -> "#{div(seconds_diff, 3600)} hours ago"
          true -> "#{div(seconds_diff, 86400)} days ago"
        end

      _ ->
        "Unknown"
    end
  end

  defp format_time_ago(_), do: "Unknown"

  defp visited_before?(socket) do
    # Check if there's a wordle_visited cookie or session flag
    case get_connect_params(socket) do
      %{"wordle_visited" => "true"} -> true
      _ -> false
    end
  end

  defp get_player_id(socket) do
    # First look for a user_id in the session
    user_id =
      case socket.assigns[:current_user] do
        %{id: id} when is_integer(id) ->
          "user-#{id}"

        _ ->
          # Try getting from the socket assigns.session (LiveView stores session here)
          session = socket.assigns[:session] || %{}

          case Map.get(session, "user_id") do
            nil -> nil
            id -> "user-#{id}"
          end
      end

    # If we have a user_id, use it, otherwise try connect params or generate a random one
    cond do
      user_id ->
        IO.puts("Using user_id from session: #{user_id}")
        user_id

      connected?(socket) ->
        case get_connect_params(socket) do
          %{"player_id" => player_id} when is_binary(player_id) and player_id != "" ->
            player_id

          _ ->
            # Generate a random player ID and store it
            random_id = "player-#{:rand.uniform(10000)}"
            IO.puts("Generated new random player_id: #{random_id}")
            random_id
        end

      true ->
        # For the initial server render (not connected yet), generate a temporary ID
        # This will be replaced once connected
        "player-#{:rand.uniform(10000)}"
    end
  end
end
