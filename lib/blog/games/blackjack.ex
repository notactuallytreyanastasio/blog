defmodule Blog.Games.Blackjack do
  @moduledoc """
  Handles the core logic for a Blackjack game, independent of the UI.
  """

  @card_suits ["♥️", "♦️", "♣️", "♠️"]
  @card_values ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

  @doc """
  Creates and initializes a new game of Blackjack.
  """
  def new_game(player_ids) do
    deck = new_shuffled_deck()
    players = create_players(player_ids)
    dealer = %{hand: [], status: :waiting}

    # Initial deal - 2 cards to each player and dealer
    {players, deck} = deal_initial_cards(players, deck)
    {dealer, deck} = deal_cards(dealer, deck, 2)

    # Calculate dealer's score (but don't store it yet)
    dealer_score = calculate_score(dealer.hand)
    dealer = Map.put(dealer, :score, dealer_score)

    # Check for naturals
    players = check_naturals(players)

    # Set active player
    {active_player, players} = activate_next_player(players)

    # Determine game status - if no active player (all blackjacks or no players),
    # proceed directly to dealer's turn
    initial_status =
      if active_player == nil do
        :dealer_turn
      else
        :playing
      end

    game = %{
      deck: deck,
      players: players,
      dealer: dealer,
      active_player_id: active_player,
      status: initial_status,
      winner: nil
    }

    # If game should proceed directly to dealer's turn, do it now
    if initial_status == :dealer_turn do
      maybe_play_dealer_turn(game)
    else
      game
    end
  end

  @doc """
  Creates a new, shuffled deck of cards.
  """
  def new_shuffled_deck do
    for suit <- @card_suits, value <- @card_values do
      {value, suit}
    end
    |> Enum.shuffle()
  end

  @doc """
  Initialize player data structures.
  """
  def create_players(player_ids) do
    player_ids
    |> Enum.map(fn id ->
      {id, %{
        hand: [],
        status: :playing,
        bet: 10,  # Default bet amount
        score: calculate_score([]),
        balance: 100  # Starting balance
      }}
    end)
    |> Enum.into(%{})
  end

  @doc """
  Deal initial cards to all players (2 cards each).
  """
  def deal_initial_cards(players, deck) do
    Enum.reduce(Map.keys(players), {players, deck}, fn player_id, {acc_players, acc_deck} ->
      # Deal cards
      {updated_player, new_deck} = deal_cards(acc_players[player_id], acc_deck, 2)

      # Calculate and update score
      updated_player = Map.put(updated_player, :score, calculate_score(updated_player.hand))

      {
        Map.put(acc_players, player_id, updated_player),
        new_deck
      }
    end)
  end

  @doc """
  Deal a specified number of cards to a player or dealer.
  """
  def deal_cards(recipient, deck, count) do
    # Start with the recipient's existing hand or an empty list
    initial_hand = Map.get(recipient, :hand, [])

    Enum.reduce(1..count, {recipient, deck}, fn _, {current_recipient, current_deck} ->
      [card | rest_deck] = current_deck

      # Get the current hand and add the new card to it
      current_hand = Map.get(current_recipient, :hand, [])
      # Add to the end of the list to maintain proper order (newest card last)
      updated_hand = current_hand ++ [card]

      # Update the recipient with the new hand
      {
        Map.put(current_recipient, :hand, updated_hand),
        rest_deck
      }
    end)
  end

  @doc """
  Calculate the score of a hand, handling Aces appropriately.
  """
  def calculate_score(hand) do
    # Make sure hand is a list
    hand = case hand do
      nil -> []
      hand when is_list(hand) -> hand
      _ -> []
    end

    # First pass - count non-Aces with proper scores
    {score, aces} = Enum.reduce(hand, {0, 0}, fn {value, _suit}, {acc_score, acc_aces} ->
      case value do
        "A" ->
          {acc_score, acc_aces + 1}
        v when v in ["J", "Q", "K"] ->
          {acc_score + 10, acc_aces}
        "10" ->
          {acc_score + 10, acc_aces}
        v ->
          # Properly add the numeric value
          {num, _} = Integer.parse("#{v}")
          {acc_score + num, acc_aces}
      end
    end)

    # Only process aces if we actually have any
    if aces > 0 do
      # Second pass - add Aces with optimal values
      Enum.reduce(1..aces, score, fn _, acc ->
        if acc + 11 <= 21, do: acc + 11, else: acc + 1
      end)
    else
      # No aces to process
      score
    end
  end

  @doc """
  Handle player hit action - draw a card and update game state.
  """
  def hit(game, player_id) do
    if game.active_player_id != player_id do
      game
    else
      {player, deck} = deal_cards(game.players[player_id], game.deck, 1)
      player = Map.put(player, :score, calculate_score(player.hand))

      # Check if player busts
      player =
        if player.score > 21 do
          player
          |> Map.put(:status, :bust)
          |> Map.put(:result, :lose)
          |> Map.update(:balance, 0, fn balance -> balance - player.bet end)
        else
          player
        end

      players = Map.put(game.players, player_id, player)

      # Determine next active player if current player busted
      {active_player_id, updated_players} =
        if player.status == :bust do
          activate_next_player(players)
        else
          {player_id, players}
        end

      # Check if game should move to dealer phase
      {status, active_id} =
        if active_player_id == nil do
          # All players have played, move to dealer's turn
          {:dealer_turn, nil}
        else
          {:playing, active_player_id}
        end

      game
      |> Map.put(:deck, deck)
      |> Map.put(:players, updated_players)
      |> Map.put(:active_player_id, active_id)
      |> Map.put(:status, status)
      |> maybe_play_dealer_turn()
    end
  end

  @doc """
  Handle player stand action - end their turn and move to next player.
  """
  def stand(game, player_id) do
    if game.active_player_id != player_id do
      game
    else
      player = Map.put(game.players[player_id], :status, :stand)
      players = Map.put(game.players, player_id, player)

      # Find next active player
      {active_player_id, updated_players} = activate_next_player(players)

      # Check if game should move to dealer phase
      {status, active_id} =
        if active_player_id == nil do
          # All players have played, move to dealer's turn
          {:dealer_turn, nil}
        else
          {:playing, active_player_id}
        end

      game
      |> Map.put(:players, updated_players)
      |> Map.put(:active_player_id, active_id)
      |> Map.put(:status, status)
      |> maybe_play_dealer_turn()
    end
  end

  @doc """
  Execute dealer's turn if the game status is :dealer_turn.
  """
  def maybe_play_dealer_turn(%{status: :dealer_turn} = game) do
    # Check if anyone is still in the game
    has_active_players = Enum.any?(game.players, fn {_, player} ->
      player.status in [:stand, :playing]
    end)

    has_blackjack_players = Enum.any?(game.players, fn {_, player} ->
      Map.get(player, :result) == :blackjack
    end)

    cond do
      has_active_players ->
        # Normal case - proceed to dealer's turn
        play_dealer_turn(game)
      has_blackjack_players ->
        # All players have blackjack or have finished - resolve blackjacks
        determine_winners(game)
      true ->
        # All players busted, dealer automatically wins
        determine_winners(game)
    end
  end

  def maybe_play_dealer_turn(game), do: game

  @doc """
  Play the dealer's turn according to Blackjack rules.
  """
  def play_dealer_turn(game) do
    dealer = game.dealer
    dealer_score = calculate_score(dealer.hand)
    dealer = Map.put(dealer, :score, dealer_score)

    # Dealer hits until score is at least 17
    {updated_dealer, updated_deck} =
      if dealer_score < 17 do
        deal_and_recalculate_dealer(dealer, game.deck)
      else
        {Map.put(dealer, :status, :stand), game.deck}
      end

    updated_game =
      game
      |> Map.put(:dealer, updated_dealer)
      |> Map.put(:deck, updated_deck)
      |> Map.put(:status, :game_over)

    determine_winners(updated_game)
  end

  @doc """
  Deal cards to dealer and recalculate score (recursive).
  """
  def deal_and_recalculate_dealer(dealer, deck) do
    {updated_dealer, updated_deck} = deal_cards(dealer, deck, 1)
    score = calculate_score(updated_dealer.hand)
    updated_dealer = Map.put(updated_dealer, :score, score)

    if score < 17 do
      # Dealer needs to hit again
      deal_and_recalculate_dealer(updated_dealer, updated_deck)
    else
      # Dealer stands
      {Map.put(updated_dealer, :status, :stand), updated_deck}
    end
  end

  @doc """
  Determine the winners and update player balances.
  """
  def determine_winners(game) do
    dealer_score = calculate_score(game.dealer.hand)
    dealer_busted = dealer_score > 21
    dealer_blackjack = dealer_score == 21 && length(game.dealer.hand) == 2

    # Process each player's result
    {winners, updated_players} =
      Enum.reduce(game.players, {[], game.players}, fn {player_id, player}, {winners_acc, players_acc} ->
        # Skip already busted players
        if player.status == :bust do
          {winners_acc, players_acc}
        else
          # If player already has a result (like natural blackjack), use that
          if Map.get(player, :result) == :blackjack do
            # Player has blackjack - pay 3:2 unless dealer also has blackjack
            balance_change = if dealer_blackjack, do: 0, else: trunc(player.bet * 1.5)

            # Update player balance
            updated_player = Map.put(player, :balance, player.balance + balance_change)

            # Add to winners list
            new_winners = if !dealer_blackjack, do: [player_id | winners_acc], else: winners_acc

            {new_winners, Map.put(players_acc, player_id, updated_player)}
          else
            # Normal case - evaluate player's hand
            player_score = calculate_score(player.hand)
            player_blackjack = player_score == 21 && length(player.hand) == 2

            # Determine result
            {result, balance_change} =
              cond do
                player_blackjack && !dealer_blackjack ->
                  # Player has blackjack, pays 3:2
                  {:blackjack, trunc(player.bet * 1.5)}
                dealer_busted ->
                  # Dealer busted, player wins
                  {:win, player.bet}
                player_score > dealer_score ->
                  # Player score higher than dealer
                  {:win, player.bet}
                player_score == dealer_score ->
                  # Push (tie)
                  {:push, 0}
                true ->
                  # Player loses
                  {:lose, -player.bet}
              end

            # Update player balance and status
            updated_player =
              player
              |> Map.put(:balance, player.balance + balance_change)
              |> Map.put(:result, result)

            # Add to winners list if appropriate
            new_winners =
              if result in [:blackjack, :win], do: [player_id | winners_acc], else: winners_acc

            {new_winners, Map.put(players_acc, player_id, updated_player)}
          end
        end
      end)

    # Set final game state
    game
    |> Map.put(:players, updated_players)
    |> Map.put(:winners, winners)
    |> Map.put(:status, :game_over)
  end

  @doc """
  Find and activate the next eligible player.
  """
  def activate_next_player(players) do
    next_player =
      players
      |> Enum.find(fn {_, player} -> player.status == :playing end)

    case next_player do
      {id, _} ->
        {id, players}
      nil ->
        {nil, players}
    end
  end

  @doc """
  Check for natural blackjacks in initial deal.
  """
  def check_naturals(players) do
    Enum.reduce(players, players, fn {id, player}, acc ->
      if length(player.hand) == 2 && calculate_score(player.hand) == 21 do
        # Natural blackjack - automatically stand and mark as blackjack
        updated_player = player
          |> Map.put(:status, :stand)
          |> Map.put(:result, :blackjack)

        Map.put(acc, id, updated_player)
      else
        acc
      end
    end)
  end

  @doc """
  Render a card as an emoji string.
  """
  def render_card({value, suit}) do
    "#{value}#{suit}"
  end

  @doc """
  Start a new round.
  """
  def new_round(game) do
    # Keep player IDs and balances
    player_ids_with_balance = Enum.map(game.players, fn {id, player} ->
      {id, player.balance}
    end)

    # Create new game with same players
    new_game = new_game(Enum.map(player_ids_with_balance, fn {id, _} -> id end))

    # Restore previous balances
    players = Enum.reduce(player_ids_with_balance, new_game.players, fn {id, balance}, acc ->
      player = Map.get(acc, id)
      updated_player = Map.put(player, :balance, balance)
      Map.put(acc, id, updated_player)
    end)

    %{new_game | players: players}
  end

  @doc """
  Add a new player to an existing game.
  """
  def add_player(%{status: :playing} = game, player_id) do
    # Only add the player if they're not already in the game
    if !Map.has_key?(game.players, player_id) do
      # Create a new player with initial cards
      {player, deck} =
        %{
          hand: [],
          status: :playing,
          bet: 10,  # Default bet amount
          score: 0,
          balance: 100  # Starting balance
        }
        |> deal_cards(game.deck, 2)

      # Calculate score after dealing
      player = Map.put(player, :score, calculate_score(player.hand))

      # Check for natural blackjack
      player =
        if length(player.hand) == 2 && player.score == 21 do
          Map.put(player, :status, :stand)
        else
          player
        end

      # Add player to the game
      players = Map.put(game.players, player_id, player)

      # Determine the next active player, but keep the current one if it exists
      # and is still valid
      {active_player_id, updated_players} =
        if game.active_player_id && Map.has_key?(players, game.active_player_id) &&
           players[game.active_player_id].status == :playing do
          {game.active_player_id, players}
        else
          activate_next_player(players)
        end

      %{game | players: updated_players, deck: deck, active_player_id: active_player_id}
    else
      game
    end
  end

  def add_player(game, _player_id), do: game  # Don't modify if game is not in playing state
end
