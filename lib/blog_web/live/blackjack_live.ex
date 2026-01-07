defmodule BlogWeb.BlackjackLive do
  use BlogWeb, :live_view
  alias Blog.Games.Blackjack

  @impl true
  def mount(_params, session, socket) do
    # Generate unique player ID for this connection
    # Using System.unique_integer ensures unique IDs even across different browser windows
    player_id = session["user_id"] || "player-#{System.unique_integer([:positive])}"

    socket =
      socket
      |> assign(:player_id, player_id)
      |> assign(:game_id, nil)
      |> assign(:players_in_lobby, %{player_id => %{name: "Player #{random_name_suffix()}"}})
      # Track active games that can be joined
      |> assign(:active_games, %{})
      |> assign(:view, :lobby)
      |> assign(:game, nil)
      |> assign(:game_message, nil)

    if connected?(socket) do
      # Subscribe to PubSub events
      BlogWeb.BlackjackLive.PubSub.subscribe()

      # Broadcasting player joined lobby
      BlogWeb.BlackjackLive.PubSub.broadcast_player_joined(player_id)

      # Request active games list
      BlogWeb.BlackjackLive.PubSub.broadcast_request_games(player_id)
    end

    {:ok, socket}
  end

  @impl true
  def handle_event("create_game", _params, socket) do
    # Generate a unique game ID
    game_id = "game-#{System.unique_integer([:positive])}"

    # Create a new game with all players in the lobby
    player_ids = Map.keys(socket.assigns.players_in_lobby)
    game = Blackjack.new_game(player_ids)

    # Subscribe to the game-specific PubSub topic
    if connected?(socket) do
      BlogWeb.BlackjackLive.PubSub.subscribe_to_game(game_id)
    end

    socket =
      socket
      |> assign(:game_id, game_id)
      |> assign(:game, game)
      |> assign(:view, :game)

    # Broadcast game started to all players WITH the player lobby data
    # This ensures everyone has the same player names
    BlogWeb.BlackjackLive.PubSub.broadcast_game_started(
      player_ids,
      game_id,
      game,
      socket.assigns.players_in_lobby
    )

    # Also broadcast game info to the lobby so new players can see it
    BlogWeb.BlackjackLive.PubSub.broadcast_game_info_to_lobby(
      game_id,
      game,
      socket.assigns.player_id,
      socket.assigns.players_in_lobby
    )

    # Set up a recurring timer to periodically republish game info
    if connected?(socket) do
      :timer.send_interval(10000, self(), :republish_game_info)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("join_game", %{"game_id" => game_id}, socket) do
    player_id = socket.assigns.player_id
    player_name = get_player_name(socket.assigns.players_in_lobby, player_id)

    # Subscribe to the game-specific PubSub topic
    if connected?(socket) do
      BlogWeb.BlackjackLive.PubSub.subscribe_to_game(game_id)
    end

    # Send a request to the game host to add us to the game
    # Include our current name to ensure it's correctly displayed
    BlogWeb.BlackjackLive.PubSub.broadcast_player_joined_game(
      game_id,
      player_id,
      player_name
    )

    socket =
      socket
      |> assign(:game_id, game_id)
      |> assign(:view, :game)

      # Add a temporary message to indicate we're waiting to join
      |> assign(:game_message, "Waiting to join game...")

    {:noreply, socket}
  end

  @impl true
  def handle_event("hit", _, socket) do
    game = Blackjack.hit(socket.assigns.game, socket.assigns.player_id)

    socket =
      socket
      |> assign(:game, game)
      |> maybe_show_game_over_flash(game)

    # Broadcast updated game state
    if socket.assigns.game_id do
      BlogWeb.BlackjackLive.PubSub.broadcast_game_updated(socket.assigns.game_id, game)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("stand", _, socket) do
    game = Blackjack.stand(socket.assigns.game, socket.assigns.player_id)

    socket =
      socket
      |> assign(:game, game)
      |> maybe_show_game_over_flash(game)

    # Broadcast updated game state
    if socket.assigns.game_id do
      BlogWeb.BlackjackLive.PubSub.broadcast_game_updated(socket.assigns.game_id, game)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("new_round", _, socket) do
    game = Blackjack.new_round(socket.assigns.game)

    socket =
      socket
      |> assign(:game, game)
      |> assign(:game_message, nil)

    # Broadcast updated game state
    if socket.assigns.game_id do
      BlogWeb.BlackjackLive.PubSub.broadcast_game_updated(socket.assigns.game_id, game)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("return_to_lobby", _, socket) do
    # Unsubscribe from the game-specific PubSub topic
    if connected?(socket) && socket.assigns.game_id do
      BlogWeb.BlackjackLive.PubSub.unsubscribe_from_game(socket.assigns.game_id)
    end

    socket =
      socket
      |> assign(:view, :lobby)
      |> assign(:game, nil)
      |> assign(:game_id, nil)
      |> assign(:game_message, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("set_player_name", %{"name" => name}, socket) do
    player_id = socket.assigns.player_id
    players_in_lobby = socket.assigns.players_in_lobby

    # Update player name
    updated_players =
      Map.update!(players_in_lobby, player_id, fn player ->
        Map.put(player, :name, name)
      end)

    socket = assign(socket, :players_in_lobby, updated_players)

    # Broadcast player name change
    BlogWeb.BlackjackLive.PubSub.broadcast_player_updated(player_id, name)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:player_joined, player_id}, socket) do
    # If this is a new player, add them to the lobby
    if !Map.has_key?(socket.assigns.players_in_lobby, player_id) do
      socket =
        update(socket, :players_in_lobby, fn players ->
          Map.put(players, player_id, %{name: "Player #{random_name_suffix()}"})
        end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:player_updated, player_id, name}, socket) do
    # Update the player's name in our local state
    socket =
      update(socket, :players_in_lobby, fn players ->
        if Map.has_key?(players, player_id) do
          Map.update!(players, player_id, fn player -> Map.put(player, :name, name) end)
        else
          players
        end
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:game_started, game_id, game, players_lobby}, socket) do
    # Only update if we're part of the game
    if Map.has_key?(game.players, socket.assigns.player_id) do
      socket =
        socket
        |> assign(:game_id, game_id)
        |> assign(:game, game)
        |> assign(:view, :game)
        |> assign(:players_in_lobby, Map.merge(socket.assigns.players_in_lobby, players_lobby))

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:game_updated, game}, socket) do
    # Check if we're already participating in this game
    if socket.assigns.view == :game do
      socket =
        socket
        |> assign(:game, game)
        |> maybe_show_game_over_flash(game)

      {:noreply, socket}
    else
      # Check if we're referenced in the updated game
      if Map.has_key?(game.players, socket.assigns.player_id) do
        socket =
          socket
          |> assign(:game, game)
          |> assign(:view, :game)
          |> maybe_show_game_over_flash(game)

        {:noreply, socket}
      else
        {:noreply, socket}
      end
    end
  end

  @impl true
  def handle_info({:request_games, requesting_player_id}, socket) do
    # Respond if we're hosting a game - even if we're already playing it
    if socket.assigns.game_id && socket.assigns.game do
      # Send game info to the requesting player
      BlogWeb.BlackjackLive.PubSub.broadcast_game_info(
        requesting_player_id,
        socket.assigns.game_id,
        socket.assigns.game,
        socket.assigns.player_id
      )
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:game_info, game_id, game, host_id, players_lobby}, socket) do
    # Use the new format with players_lobby
    process_game_info(game_id, game, host_id, players_lobby, socket)
  end

  @impl true
  def handle_info({:game_info, game_id, game, host_id}, socket) do
    # Handle the old format for backward compatibility
    process_game_info(game_id, game, host_id, %{}, socket)
  end

  # Helper to process game info in a consistent way
  defp process_game_info(game_id, game, host_id, players_lobby, socket) do
    # Don't add our own game to the list
    if host_id != socket.assigns.player_id do
      # Get host name from provided players_lobby or current lobby
      host_name =
        if Map.has_key?(players_lobby, host_id) do
          players_lobby[host_id].name
        else
          get_player_name(socket.assigns.players_in_lobby, host_id)
        end

      # Merge any provided player names into our lobby
      updated_players_lobby = Map.merge(socket.assigns.players_in_lobby, players_lobby)

      # Add game to active games list
      socket =
        socket
        |> assign(:players_in_lobby, updated_players_lobby)
        |> update(:active_games, fn games ->
          Map.put(games, game_id, %{
            host_id: host_id,
            host_name: host_name,
            player_count: map_size(game.players),
            created_at: System.system_time(:second)
          })
        end)

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:player_joined_game, player_id, player_name}, socket) do
    # Only process if we have a game
    if socket.assigns.game do
      # Always update the player's name in our players_in_lobby
      socket =
        update(socket, :players_in_lobby, fn players ->
          Map.put(players, player_id, %{name: player_name})
        end)

      # Only the host should handle adding players to the game
      if socket.assigns.game && socket.assigns.view == :game &&
           socket.assigns.player_id in Map.keys(socket.assigns.game.players) do
        # Add the player to the game if they're not already in it
        updated_game =
          if !Map.has_key?(socket.assigns.game.players, player_id) do
            # Add player to the game
            updated_game =
              try do
                Blackjack.add_player(socket.assigns.game, player_id)
              rescue
                e ->
                  # If there's an error adding the player, log it and return the original game
                  IO.puts("Error adding player to game: #{inspect(e)}")
                  socket.assigns.game
              end

            # Broadcast the updated game state to all players
            if socket.assigns.game_id do
              BlogWeb.BlackjackLive.PubSub.broadcast_game_updated(
                socket.assigns.game_id,
                updated_game
              )
            end

            updated_game
          else
            socket.assigns.game
          end

        {:noreply, assign(socket, :game, updated_game)}
      else
        {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(:republish_game_info, socket) do
    # Only republish if we're hosting a game
    if socket.assigns.game_id && socket.assigns.game do
      BlogWeb.BlackjackLive.PubSub.broadcast_game_info_to_lobby(
        socket.assigns.game_id,
        socket.assigns.game,
        socket.assigns.player_id,
        socket.assigns.players_in_lobby
      )
    end

    {:noreply, socket}
  end

  # Add a fallback handler for unexpected messages
  @impl true
  def handle_info(_message, socket) do
    # Silently ignore unknown messages
    {:noreply, socket}
  end

  # Helper functions

  defp maybe_show_game_over_flash(socket, %{status: :game_over} = game) do
    player = game.players[socket.assigns.player_id]

    message =
      cond do
        # Handle case when player has busted and result isn't set yet
        player.status == :bust ->
          "Bust! You lose #{player.bet} chips."

        # For cases where we have a result
        Map.has_key?(player, :result) ->
          case player.result do
            :blackjack -> "Blackjack! You win #{trunc(player.bet * 1.5)} chips!"
            :win -> "You win #{player.bet} chips!"
            :push -> "Push - your bet is returned."
            :lose -> "You lose #{player.bet} chips."
            _ -> "Game over!"
          end

        # Default case if neither is true
        true ->
          "Game over!"
      end

    assign(socket, :game_message, message)
  end

  defp maybe_show_game_over_flash(socket, _game), do: socket

  defp random_name_suffix do
    ~w(Ace King Queen Jack Diamond Heart Spade Club)
    |> Enum.random()
  end

  # Render functions

  defp render_player_hand(hand, status, score, hide_second_card \\ false) do
    # Make sure we're working with the correct hand for this player
    cards =
      case {hand, hide_second_card} do
        {[first | rest], true} ->
          [Blackjack.render_card(first) | Enum.map(rest, fn _ -> "🂠" end)]

        {cards, false} ->
          Enum.map(cards, &Blackjack.render_card/1)
      end

    # Verify the score matches what we calculate (for debugging)
    actual_score = Blackjack.calculate_score(hand)

    if !hide_second_card && actual_score != score do
      IO.puts("WARNING: Score mismatch! Displayed: #{score}, Calculated: #{actual_score}")
      IO.puts("Hand: #{inspect(hand)}")
    end

    status_text =
      case status do
        :bust -> " (Bust!)"
        :blackjack -> " (Blackjack!)"
        _ -> ""
      end

    # Use the calculated score directly for better accuracy
    score_to_display = if hide_second_card, do: score, else: actual_score

    # Use the provided score directly - don't recalculate it here
    score_text =
      cond do
        # When it's another player's hand, don't show score
        hide_second_card && status not in [:bust, :blackjack] -> ""
        # When it's the dealer with hidden cards
        hide_second_card -> ""
        # Otherwise show the score
        true -> " - Score: #{score_to_display}"
      end

    {cards, "#{status_text}#{score_text}"}
  end

  defp is_players_turn?(game, player_id) do
    game.active_player_id == player_id
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id="blackjack-game" class="min-h-screen bg-green-800 p-4 text-white" phx-hook="Blackjack">
      <div class="max-w-4xl mx-auto">
        <h1 class="text-4xl font-bold mb-6 text-center">Blackjack</h1>

        <%= if @view == :lobby do %>
          <div class="bg-green-900 rounded-lg p-6 mb-8">
            <h2 class="text-2xl font-bold mb-4">Game Lobby</h2>

            <div class="mb-6">
              <label class="block mb-2">Your Name:</label>
              <form phx-submit="set_player_name" class="flex gap-2">
                <input
                  type="text"
                  name="name"
                  value={@players_in_lobby[@player_id].name}
                  class="px-3 py-2 rounded text-black flex-grow"
                />
                <button type="submit" class="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded">
                  Update
                </button>
              </form>
            </div>

            <div class="mb-6">
              <h3 class="text-xl font-bold mb-2">Players in Lobby:</h3>
              <ul class="list-disc pl-6">
                <%= for {id, player} <- @players_in_lobby do %>
                  <li class={if id == @player_id, do: "font-bold", else: ""}>
                    {player.name} {if id == @player_id, do: "(You)"}
                  </li>
                <% end %>
              </ul>
            </div>

            <%= if map_size(@active_games) > 0 do %>
              <div class="mb-6">
                <h3 class="text-xl font-bold mb-2">Active Games:</h3>
                <div class="grid grid-cols-1 gap-4">
                  <%= for {game_id, game_info} <- @active_games do %>
                    <div class="bg-green-800 p-4 rounded-lg">
                      <p class="mb-2">
                        <strong>Host:</strong> {game_info.host_name}
                        <span class="ml-4"><strong>Players:</strong> {game_info.player_count}</span>
                      </p>
                      <div class="flex justify-end">
                        <button
                          phx-click="join_game"
                          phx-value-game_id={game_id}
                          class="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded action-button"
                        >
                          Join Game
                        </button>
                      </div>
                    </div>
                  <% end %>
                </div>
              </div>
            <% end %>

            <div class="flex justify-center">
              <button
                phx-click="create_game"
                class="bg-yellow-600 hover:bg-yellow-700 px-6 py-3 rounded-lg text-lg font-bold action-button"
              >
                Start New Game
              </button>
            </div>
          </div>
        <% else %>
          <div class="bg-green-900 rounded-lg p-6 mb-4 blackjack-table">
            <%= if @game_message do %>
              <div class="bg-yellow-600 text-white p-3 rounded mb-4 text-center font-bold result-message">
                {@game_message}
              </div>
            <% end %>

            <div class="mb-8 dealer-area p-4">
              <h2 class="text-xl font-bold mb-4 player-name">Dealer's Hand</h2>
              <div class="flex flex-wrap gap-2 mb-2">
                <% # Calculate dealer score if it's not in the map
                dealer_score =
                  Map.get(@game.dealer, :score) || Blackjack.calculate_score(@game.dealer.hand)

                {dealer_cards, dealer_status} =
                  render_player_hand(
                    @game.dealer.hand,
                    @game.dealer.status,
                    dealer_score,
                    @game.status != :game_over
                  ) %>

                <%= for card <- dealer_cards do %>
                  <div class="text-4xl bg-white text-black p-2 rounded shadow-md card card-emoji">
                    {card}
                  </div>
                <% end %>
              </div>
              <div>{dealer_status}</div>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
              <%= for {player_id, player} <- @game.players do %>
                <div class={
                  "bg-green-800 p-4 rounded-lg border-2 #{
                    cond do
                      is_players_turn?(@game, player_id) -> "border-yellow-400 player-active"
                      player.status == :bust -> "border-red-500"
                      player.status == :stand -> "border-gray-500"
                      true -> "border-green-800"
                    end
                  }"
                }>
                  <h3 class="text-lg font-bold mb-2 player-name">
                    {get_player_name(@players_in_lobby, player_id)}
                    {if player_id == @player_id, do: "(You)"} - Balance:
                    <span class={"chip chip-#{min(100, player.balance)}"}>
                      {player.balance}
                    </span>
                  </h3>

                  <div class="flex flex-wrap gap-2 mb-2 card-container">
                    <% # Show all cards for current player, only first card for others
                    should_hide_cards = player_id != @player_id

                    # Debug the hand and score (only for current player)
                    if player_id == @player_id do
                      debug_player_hand(player_id, player.hand, player.score)
                    end

                    {player_cards, player_status} =
                      render_player_hand(
                        player.hand,
                        player.status,
                        player.score,
                        should_hide_cards
                      ) %>

                    <%= for card <- player_cards do %>
                      <div class="text-4xl bg-white text-black p-2 rounded shadow-md card card-emoji">
                        {card}
                      </div>
                    <% end %>
                  </div>
                  <div>{player_status}</div>

                  <%= if player_id == @player_id && is_players_turn?(@game, player_id) do %>
                    <div class="mt-4 flex gap-3">
                      <button
                        phx-click="hit"
                        class="bg-blue-600 hover:bg-blue-700 px-4 py-2 rounded action-button"
                      >
                        Hit
                      </button>
                      <button
                        phx-click="stand"
                        class="bg-red-600 hover:bg-red-700 px-4 py-2 rounded action-button"
                      >
                        Stand
                      </button>
                    </div>
                  <% end %>
                </div>
              <% end %>
            </div>

            <%= if @game.status == :game_over do %>
              <div class="flex justify-center gap-4">
                <button
                  phx-click="new_round"
                  class="bg-yellow-600 hover:bg-yellow-700 px-6 py-3 rounded-lg text-lg font-bold action-button"
                >
                  Play Again
                </button>
                <button
                  phx-click="return_to_lobby"
                  class="bg-gray-600 hover:bg-gray-700 px-6 py-3 rounded-lg text-lg font-bold action-button"
                >
                  Return to Lobby
                </button>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Safe accessor for player name (in case player left/disconnected)
  defp get_player_name(players_in_lobby, player_id) do
    case Map.get(players_in_lobby, player_id) do
      nil -> "Unknown Player"
      player -> player.name
    end
  end

  # Helper function to debug card values and scores
  defp debug_player_hand(player_id, hand, score) do
    # Only log if there's a discrepancy between calculated and stored score
    calculated_score = Blackjack.calculate_score(hand)

    if calculated_score != score do
      hand_values = Enum.map(hand, fn {value, suit} -> "#{value}#{suit}" end)

      IO.puts(
        "SCORE DISCREPANCY: Player #{player_id}: Hand: #{inspect(hand_values)}, Stored: #{score}, Calculated: #{calculated_score}"
      )
    end
  end
end

# PubSub helper module for Blackjack
defmodule BlogWeb.BlackjackLive.PubSub do
  @moduledoc """
  Handles PubSub communications for the Blackjack game.
  """

  @topic "blackjack"

  def subscribe do
    Phoenix.PubSub.subscribe(Blog.PubSub, @topic)
  end

  def subscribe_to_game(game_id) do
    Phoenix.PubSub.subscribe(Blog.PubSub, "#{@topic}:#{game_id}")
  end

  def unsubscribe_from_game(game_id) do
    Phoenix.PubSub.unsubscribe(Blog.PubSub, "#{@topic}:#{game_id}")
  end

  def broadcast_player_joined(player_id) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:player_joined, player_id})
  end

  def broadcast_player_updated(player_id, name) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:player_updated, player_id, name})
  end

  def broadcast_player_left(player_id) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:player_left, player_id})
  end

  def broadcast_request_games(player_id) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:request_games, player_id})
  end

  def broadcast_game_info(_to_player_id, game_id, game, host_id) do
    # Direct message to the player who requested game info
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:game_info, game_id, game, host_id})
  end

  def broadcast_game_info_to_lobby(game_id, game, host_id, players_lobby \\ %{}) do
    # Broadcast game info to the main lobby topic for all players to see
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:game_info, game_id, game, host_id, players_lobby}
    )
  end

  def broadcast_game_started(_player_ids, game_id, game, players_lobby \\ %{}) do
    # Broadcast to the main lobby that a game has started
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:game_started, game_id, game, players_lobby})

    # Also broadcast to the game-specific topic
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "#{@topic}:#{game_id}",
      {:game_started, game_id, game, players_lobby}
    )
  end

  def broadcast_game_updated(game_id, game) do
    # Update both the main topic and game-specific topic
    Phoenix.PubSub.broadcast(Blog.PubSub, "#{@topic}:#{game_id}", {:game_updated, game})
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:game_updated, game})
  end

  def broadcast_game_ended(game_id) do
    Phoenix.PubSub.broadcast(Blog.PubSub, "#{@topic}:#{game_id}", {:game_ended, game_id})
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:game_ended, game_id})
  end

  def broadcast_player_joined_game(game_id, player_id, player_name) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "#{@topic}:#{game_id}",
      {:player_joined_game, player_id, player_name}
    )
  end
end
