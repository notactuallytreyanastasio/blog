defmodule BlogWeb.WarLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  require Logger

  @topic "war:lobby"
  @ping_interval 5000
  @ets_table :war_players

  @impl true
  def mount(_params, session, socket) do
    # For testing purposes, generate a unique random ID for each tab
    # Use the timestamp + random number to ensure uniqueness
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    random_suffix = :rand.uniform(1000)
    tab_unique_id = "user_#{timestamp}_#{random_suffix}"

    # Either use existing user_id from session or create a new unique one
    user_id = session["user_id"] || tab_unique_id

    # Generate a random display name for this user as default
    display_name = generate_display_name()

    if connected?(socket) do
      # Subscribe to presence updates and ping topic
      Phoenix.PubSub.subscribe(Blog.PubSub, @topic)

      # Track user in presence with a unique mnemonic name for easier testing
      {:ok, _} = Presence.track(self(), @topic, user_id, %{
        online_at: timestamp,
        status: "available",
        display_name: display_name
      })

      # Also store in ETS for persistence across all sessions
      store_player_in_ets(user_id, %{
        online_at: timestamp,
        status: "available",
        display_name: display_name
      })

      # Broadcast player joined to ensure all clients update
      Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:player_joined, user_id})

      # Set up ping interval to keep presence fresh
      :timer.send_interval(@ping_interval, :ping)
    end

    # Get ALL players from ETS
    all_players = get_all_players_from_ets()

    socket = socket
      |> assign(:user_id, user_id)
      |> assign(:players, all_players)
      |> assign(:game_state, nil)
      |> assign(:invitations, %{})
      |> assign(:sent_invitations, %{})
      |> assign(:card_deck, nil)
      |> assign(:edit_name, false)
      |> assign(:name_form, %{"display_name" => display_name})

    {:ok, socket}
  end

  # Generate a random display name for easier identification during testing
  defp generate_display_name do
    # Lists of adjectives and animals to create a readable identifier
    adjectives = ~w(Red Blue Green Yellow Purple Orange Tiny Big Fast Slow Happy Silly Smart Brave Wild Calm)
    animals = ~w(Lion Tiger Bear Wolf Fox Panda Koala Eagle Shark Dolphin Rabbit Turtle Elephant Giraffe Kangaroo)

    adjective = Enum.random(adjectives)
    animal = Enum.random(animals)

    "#{adjective}#{animal}"
  end

  # Helper function to get the display name for a player
  def player_display_name(nil), do: "Unknown Player"
  def player_display_name(player) when is_map(player) do
    Map.get(player, :display_name, "Player")
  end

  # View helper functions for card display
  def card_color("hearts"), do: "text-red-600"
  def card_color("diamonds"), do: "text-red-600"
  def card_color("clubs"), do: "text-gray-800"
  def card_color("spades"), do: "text-gray-800"

  def display_card_value("jack"), do: "J"
  def display_card_value("queen"), do: "Q"
  def display_card_value("king"), do: "K"
  def display_card_value("ace"), do: "A"
  def display_card_value(value), do: value

  def display_card_suit("hearts"), do: "♥️"
  def display_card_suit("diamonds"), do: "♦️"
  def display_card_suit("clubs"), do: "♣️"
  def display_card_suit("spades"), do: "♠️"

  def time_ago(timestamp) do
    now = DateTime.utc_now() |> DateTime.to_unix()
    diff = now - timestamp

    cond do
      diff < 60 -> "#{diff} seconds"
      diff < 3600 -> "#{div(diff, 60)} minutes"
      diff < 86400 -> "#{div(diff, 3600)} hours"
      true -> "#{div(diff, 86400)} days"
    end
  end

  # Store player in ETS for persistence across all sessions
  defp store_player_in_ets(user_id, player_data) do
    :ets.insert(@ets_table, {user_id, player_data})
  end

  # Remove player from ETS
  defp remove_player_from_ets(user_id) do
    :ets.delete(@ets_table, user_id)
  end

  # Get all players from ETS
  defp get_all_players_from_ets do
    case :ets.tab2list(@ets_table) do
      [] -> %{}
      players ->
        players
        |> Enum.map(fn {user_id, data} -> {user_id, data} end)
        |> Map.new()
    end
  end

  # Handle name editing
  @impl true
  def handle_event("toggle_edit_name", _, socket) do
    {:noreply, assign(socket, :edit_name, !socket.assigns.edit_name)}
  end

  @impl true
  def handle_event("change_name_form", %{"display_name" => display_name}, socket) do
    {:noreply, assign(socket, :name_form, %{"display_name" => display_name})}
  end

  @impl true
  def handle_event("save_display_name", %{"display_name" => display_name}, socket) do
    # Validate name is not empty
    display_name = String.trim(display_name)
    display_name = if display_name == "", do: generate_display_name(), else: display_name

    # Update presence with new name
    user_id = socket.assigns.user_id
    current_meta = Map.get(socket.assigns.players, user_id, %{})

    updated_meta = Map.put(current_meta, :display_name, display_name)

    # Update in Presence
    {:ok, _} = Presence.update(self(), @topic, user_id, updated_meta)

    # Update in ETS
    store_player_in_ets(user_id, updated_meta)

    # Broadcast name change to all clients
    Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:name_changed, user_id, display_name})

    # Update local assigns
    all_players = get_all_players_from_ets()

    socket = socket
      |> assign(:players, all_players)
      |> assign(:edit_name, false)

    {:noreply, socket}
  end

  @impl true
  def handle_event("invite_player", %{"id" => player_id}, socket) do
    invitation = %{
      from: socket.assigns.user_id,
      to: player_id,
      timestamp: DateTime.utc_now() |> DateTime.to_unix()
    }

    # Broadcast invitation - only the recipient will store it
    Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:invitation, invitation})

    # Add a sent_invitations list to track outgoing invitations for UI feedback
    sent_invitations = Map.get(socket.assigns, :sent_invitations, %{})
    socket = socket
      |> assign(:sent_invitations, Map.put(sent_invitations, player_id, invitation))

    {:noreply, socket}
  end

  @impl true
  def handle_event("accept_invitation", %{"from" => from_id}, socket) do
    # Get invitation
    invitation = socket.assigns.invitations[from_id]

    if invitation do
      # Start new game
      game_state = start_new_game(from_id, socket.assigns.user_id)

      # Broadcast game start
      Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:game_started, game_state})

      # Update socket
      socket = socket
        |> assign(:game_state, game_state)
        |> assign(:invitations, Map.drop(socket.assigns.invitations, [from_id]))

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("decline_invitation", %{"from" => from_id}, socket) do
    # Remove invitation
    socket = socket
      |> assign(:invitations, Map.drop(socket.assigns.invitations, [from_id]))

    # Broadcast decline
    Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:invitation_declined, %{
      from: from_id,
      to: socket.assigns.user_id
    }})

    {:noreply, socket}
  end

  @impl true
  def handle_event("play_card", _params, socket) do
    game_state = socket.assigns.game_state

    if game_state do
      # Update game state based on card play
      updated_game = play_round(game_state, socket.assigns.user_id)

      # Broadcast game update
      Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:game_updated, updated_game})

      # Push card played animation if a card was played
      if game_state.player1_card != updated_game.player1_card ||
         game_state.player2_card != updated_game.player2_card do
        player = if game_state.player1 == socket.assigns.user_id, do: "player1", else: "player2"
        if connected?(socket), do: push_event(socket, "card_played", %{player: player})
      end

      socket = socket |> assign(:game_state, updated_game)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("continue_round", _params, socket) do
    game_state = socket.assigns.game_state

    if game_state && game_state.scoring_phase do
      # Now resolve the round
      updated_game = resolve_round(game_state)

      # Determine if war was triggered or who won
      cond do
        # War was triggered
        updated_game.war_in_progress ->
          if connected?(socket), do: push_event(socket, "war_triggered", %{})

        # Player 1 won the round
        game_state.player1_card && game_state.player2_card && game_state.player1_card.rank > game_state.player2_card.rank ->
          if connected?(socket), do: push_event(socket, "round_won", %{winner: "player1"})

        # Player 2 won the round
        game_state.player1_card && game_state.player2_card && game_state.player2_card.rank > game_state.player1_card.rank ->
          if connected?(socket), do: push_event(socket, "round_won", %{winner: "player2"})

        # No clear winner (should not happen, but handle it)
        true ->
          nil
      end

      # Broadcast game update
      Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:game_updated, updated_game})

      socket = socket |> assign(:game_state, updated_game)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:name_changed, user_id, _display_name}, socket) do
    # When any player changes their name, refresh the player list
    all_players = get_all_players_from_ets()

    socket = socket |> assign(:players, all_players)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:player_joined, _user_id}, socket) do
    # When any player joins, refresh the complete player list from ETS
    all_players = get_all_players_from_ets()
    socket = socket |> assign(:players, all_players)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:player_left, _user_id}, socket) do
    # When any player leaves, refresh the complete player list from ETS
    all_players = get_all_players_from_ets()
    socket = socket |> assign(:players, all_players)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:invitation, invitation}, socket) do
    # Only process invitations sent to this user
    if invitation.to == socket.assigns.user_id do
      socket = socket
        |> assign(:invitations, Map.put(socket.assigns.invitations, invitation.from, invitation))

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:invitation_declined, invitation}, socket) do
    # Only process invitations sent by this user
    if invitation.from == socket.assigns.user_id do
      socket = socket
        |> assign(:sent_invitations, Map.drop(socket.assigns.sent_invitations, [invitation.to]))

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:game_started, game_state}, socket) do
    # Only process game starts that involve this user
    if game_state.player1 == socket.assigns.user_id || game_state.player2 == socket.assigns.user_id do
      socket = socket
        |> assign(:game_state, game_state)
        |> assign(:invitations, %{})
        |> assign(:sent_invitations, %{})

      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:game_updated, game_state}, socket) do
    # Only process game updates for the current game
    if socket.assigns.game_state && game_state.id == socket.assigns.game_state.id do
      socket = socket |> assign(:game_state, game_state)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: diff}, socket) do
    # Handle leaves first - remove from ETS
    if map_size(diff.leaves) > 0 do
      for {user_id, _} <- diff.leaves do
        # Remove from ETS
        remove_player_from_ets(user_id)
        # Broadcast player left
        Phoenix.PubSub.broadcast!(Blog.PubSub, @topic, {:player_left, user_id})
      end

      # Clean up invitations for players who left
      socket = update_invitations_after_players_left(socket, Map.keys(diff.leaves))
    end

    # Handle joins - update ETS with new player data
    if map_size(diff.joins) > 0 do
      for {user_id, %{metas: [meta | _]}} <- diff.joins do
        # Add to ETS
        store_player_in_ets(user_id, meta)
      end
    end

    # Update socket with fresh player list
    all_players = get_all_players_from_ets()
    socket = socket |> assign(:players, all_players)

    # Also update game state if needed - if a player in the game left
    socket = check_game_state_for_disconnects(socket, diff.leaves)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:ping, socket) do
    {:noreply, socket}
  end

  # Check if any player who left was in the current game
  defp check_game_state_for_disconnects(socket, leaves) do
    game_state = socket.assigns.game_state

    if game_state do
      player_left = Enum.any?(Map.keys(leaves), fn user_id ->
        user_id == game_state.player1 || user_id == game_state.player2
      end)

      if player_left do
        assign(socket, :game_state, nil)
      else
        socket
      end
    else
      socket
    end
  end

  # Remove invitations for players who left
  defp update_invitations_after_players_left(socket, left_user_ids) do
    # Remove invitations TO users who left
    # Remove invitations FROM users who left
    updated_invitations = socket.assigns.invitations
      |> Map.drop(left_user_ids)
      |> Enum.reject(fn {_, inv} -> Enum.member?(left_user_ids, inv.from) end)
      |> Map.new()

    # Also clean up sent invitations to users who left
    updated_sent_invitations = socket.assigns.sent_invitations
      |> Map.drop(left_user_ids)

    socket
      |> assign(:invitations, updated_invitations)
      |> assign(:sent_invitations, updated_sent_invitations)
  end

  # Private functions

  defp start_new_game(player1, player2) do
    deck = create_deck() |> shuffle_deck()
    {player1_cards, player2_cards} = deal_cards(deck)

    %{
      id: "game_#{:rand.uniform(1000000)}",
      player1: player1,
      player2: player2,
      player1_cards: player1_cards,
      player2_cards: player2_cards,
      player1_card: nil,
      player2_card: nil,
      war_pile: [],
      war_in_progress: false,
      scoring_phase: false,
      winner: nil,
      status: "playing"
    }
  end

  defp create_deck do
    suits = ["hearts", "diamonds", "clubs", "spades"]
    values = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king", "ace"]

    for suit <- suits, value <- values do
      %{
        suit: suit,
        value: value,
        rank: card_rank(value)
      }
    end
  end

  defp card_rank(value) do
    case value do
      "2" -> 2
      "3" -> 3
      "4" -> 4
      "5" -> 5
      "6" -> 6
      "7" -> 7
      "8" -> 8
      "9" -> 9
      "10" -> 10
      "jack" -> 11
      "queen" -> 12
      "king" -> 13
      "ace" -> 14
    end
  end

  defp shuffle_deck(deck) do
    Enum.shuffle(deck)
  end

  defp deal_cards(deck) do
    {player1_cards, player2_cards} = Enum.split(deck, div(length(deck), 2))
    {player1_cards, player2_cards}
  end

  defp play_round(game, user_id) do
    # If a war is in progress, explain that cards have already been played automatically
    if game.war_in_progress do
      game  # Return game unchanged - war is handled automatically
    else
      # If we're in scoring phase, don't allow additional card plays
      if game.scoring_phase do
        game
      else
        # Only proceed if it's this player's turn or if waiting for both cards
        if game.player1_card == nil || game.player2_card == nil do
          cond do
            user_id == game.player1 && game.player1_card == nil && length(game.player1_cards) > 0 ->
              [card | rest] = game.player1_cards
              game = %{game | player1_card: card, player1_cards: rest}
              check_round_completion(game)

            user_id == game.player2 && game.player2_card == nil && length(game.player2_cards) > 0 ->
              [card | rest] = game.player2_cards
              game = %{game | player2_card: card, player2_cards: rest}
              check_round_completion(game)

            true ->
              game
          end
        else
          game
        end
      end
    end
  end

  defp check_round_completion(game) do
    if game.player1_card != nil && game.player2_card != nil do
      # When both cards are played, enter scoring phase rather than
      # immediately resolving
      %{game | scoring_phase: true}
    else
      game
    end
  end

  defp resolve_round(game) do
    player1_rank = game.player1_card.rank
    player2_rank = game.player2_card.rank

    war_pile = [game.player1_card, game.player2_card | game.war_pile]

    cond do
      # Player 1 wins the round
      player1_rank > player2_rank ->
        player1_cards = game.player1_cards ++ war_pile
        %{game |
          player1_cards: player1_cards,
          player2_cards: game.player2_cards,
          player1_card: nil,
          player2_card: nil,
          war_pile: [],
          war_in_progress: false,
          scoring_phase: false,
          winner: check_for_winner(player1_cards, game.player2_cards)
        }

      # Player 2 wins the round
      player2_rank > player1_rank ->
        player2_cards = game.player2_cards ++ war_pile
        %{game |
          player1_cards: game.player1_cards,
          player2_cards: player2_cards,
          player1_card: nil,
          player2_card: nil,
          war_pile: [],
          war_in_progress: false,
          scoring_phase: false,
          winner: check_for_winner(game.player1_cards, player2_cards)
        }

      # War! (equal cards)
      true ->
        handle_war(game, war_pile)
    end
  end

  defp handle_war(game, war_pile) do
    # Check if either player doesn't have enough cards for war
    cond do
      # If player 1 has fewer than 2 cards, they lose (need 1 face down, 1 face up)
      length(game.player1_cards) < 2 ->
        %{game |
          player1_cards: [],
          player2_cards: game.player2_cards ++ war_pile,
          player1_card: nil,
          player2_card: nil,
          war_pile: [],
          war_in_progress: false,
          scoring_phase: false,
          winner: "player2"
        }

      # If player 2 has fewer than 2 cards, they lose (need 1 face down, 1 face up)
      length(game.player2_cards) < 2 ->
        %{game |
          player1_cards: game.player1_cards ++ war_pile,
          player2_cards: [],
          player1_card: nil,
          player2_card: nil,
          war_pile: [],
          war_in_progress: false,
          scoring_phase: false,
          winner: "player1"
        }

      true ->
        # Each player places one card face down
        [face_down_1 | rest_1] = game.player1_cards
        [face_down_2 | rest_2] = game.player2_cards

        # Each player places one card face up (automated)
        [face_up_1 | new_rest_1] = rest_1
        [face_up_2 | new_rest_2] = rest_2

        # Add face down cards to war pile
        updated_war_pile = [face_down_1, face_down_2 | war_pile]

        # Compare the face up cards
        face_up_1_rank = face_up_1.rank
        face_up_2_rank = face_up_2.rank

        cond do
          # Player 1 wins the war
          face_up_1_rank > face_up_2_rank ->
            # Player 1 gets all cards including face up cards
            player1_cards = new_rest_1 ++ [face_up_1, face_up_2 | updated_war_pile]
            %{game |
              player1_cards: player1_cards,
              player2_cards: new_rest_2,
              player1_card: nil,
              player2_card: nil,
              war_pile: [],
              war_in_progress: false,
              scoring_phase: false,
              winner: check_for_winner(player1_cards, new_rest_2)
            }

          # Player 2 wins the war
          face_up_2_rank > face_up_1_rank ->
            # Player 2 gets all cards including face up cards
            player2_cards = new_rest_2 ++ [face_up_1, face_up_2 | updated_war_pile]
            %{game |
              player1_cards: new_rest_1,
              player2_cards: player2_cards,
              player1_card: nil,
              player2_card: nil,
              war_pile: [],
              war_in_progress: false,
              scoring_phase: false,
              winner: check_for_winner(new_rest_1, player2_cards)
            }

          # Another war! (face up cards are equal)
          true ->
            # Add the face up cards to the war pile and continue
            new_war_pile = [face_up_1, face_up_2 | updated_war_pile]
            # Recursive call to handle the next war
            handle_war(
              %{game |
                player1_cards: new_rest_1,
                player2_cards: new_rest_2,
                war_pile: new_war_pile,
                war_in_progress: true
              },
              []
            )
        end
    end
  end

  defp check_for_winner(player1_cards, player2_cards) do
    cond do
      Enum.empty?(player1_cards) -> "player2"
      Enum.empty?(player2_cards) -> "player1"
      true -> nil
    end
  end
end
