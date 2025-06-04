defmodule Blog.Games.BlackjackTest do
  use ExUnit.Case, async: true
  alias Blog.Games.Blackjack

  describe "new_shuffled_deck/0" do
    test "creates a full deck of 52 cards" do
      deck = Blackjack.new_shuffled_deck()
      assert length(deck) == 52

      # Check that all cards are unique
      assert length(Enum.uniq(deck)) == 52
    end

    test "deck contains all expected cards" do
      deck = Blackjack.new_shuffled_deck()

      # Check suits
      suits = Enum.map(deck, fn {_, suit} -> suit end) |> Enum.uniq()
      assert "♥️" in suits
      assert "♦️" in suits
      assert "♣️" in suits
      assert "♠️" in suits

      # Check values
      values = Enum.map(deck, fn {value, _} -> value end) |> Enum.uniq() |> Enum.sort()
      expected_values = ["10", "2", "3", "4", "5", "6", "7", "8", "9", "A", "J", "K", "Q"]
      assert Enum.sort(expected_values) == values
    end

    test "deck is shuffled (not in order)" do
      deck1 = Blackjack.new_shuffled_deck()
      deck2 = Blackjack.new_shuffled_deck()

      # Very unlikely that two shuffled decks are identical
      refute deck1 == deck2
    end
  end

  describe "create_players/1" do
    test "creates player map with correct initial values" do
      players = Blackjack.create_players(["player1", "player2"])

      assert Map.has_key?(players, "player1")
      assert Map.has_key?(players, "player2")

      player1 = players["player1"]
      assert player1.hand == []
      assert player1.status == :playing
      assert player1.bet == 10
      assert player1.score == 0
      assert player1.balance == 100
    end

    test "handles empty player list" do
      players = Blackjack.create_players([])
      assert players == %{}
    end

    test "creates unique players for each ID" do
      players = Blackjack.create_players(["a", "b", "c"])
      assert map_size(players) == 3
      assert Map.keys(players) |> Enum.sort() == ["a", "b", "c"]
    end
  end

  describe "calculate_score/1" do
    test "calculates simple numeric cards correctly" do
      hand = [{"2", "♥️"}, {"5", "♦️"}, {"8", "♣️"}]
      assert Blackjack.calculate_score(hand) == 15
    end

    test "calculates face cards as 10" do
      hand = [{"J", "♥️"}, {"Q", "♦️"}, {"K", "♣️"}]
      assert Blackjack.calculate_score(hand) == 30
    end

    test "calculates 10 cards correctly" do
      hand = [{"10", "♥️"}, {"10", "♦️"}]
      assert Blackjack.calculate_score(hand) == 20
    end

    test "calculates aces as 11 when possible" do
      hand = [{"A", "♥️"}, {"5", "♦️"}]
      assert Blackjack.calculate_score(hand) == 16
    end

    test "calculates aces as 1 when 11 would bust" do
      hand = [{"A", "♥️"}, {"K", "♦️"}, {"5", "♣️"}]
      # A=1, K=10, 5=5
      assert Blackjack.calculate_score(hand) == 16
    end

    test "handles multiple aces optimally" do
      hand = [{"A", "♥️"}, {"A", "♦️"}, {"5", "♣️"}]
      # A=11, A=1, 5=5
      assert Blackjack.calculate_score(hand) == 17

      hand2 = [{"A", "♥️"}, {"A", "♦️"}, {"A", "♣️"}, {"8", "♠️"}]
      # A=11, A=1, A=1, 8=8
      assert Blackjack.calculate_score(hand2) == 21
    end

    test "blackjack hands score 21" do
      hand = [{"A", "♥️"}, {"K", "♦️"}]
      assert Blackjack.calculate_score(hand) == 21

      hand2 = [{"A", "♣️"}, {"Q", "♠️"}]
      assert Blackjack.calculate_score(hand2) == 21
    end

    test "handles empty hand" do
      assert Blackjack.calculate_score([]) == 0
      assert Blackjack.calculate_score(nil) == 0
    end
  end

  describe "deal_cards/3" do
    test "deals specified number of cards from deck" do
      deck = [{"A", "♥️"}, {"K", "♦️"}, {"Q", "♣️"}, {"J", "♠️"}]
      player = %{hand: []}

      {updated_player, remaining_deck} = Blackjack.deal_cards(player, deck, 2)

      assert length(updated_player.hand) == 2
      assert length(remaining_deck) == 2
      assert updated_player.hand == [{"A", "♥️"}, {"K", "♦️"}]
    end

    test "adds cards to existing hand" do
      deck = [{"5", "♥️"}, {"6", "♦️"}]
      player = %{hand: [{"A", "♣️"}, {"K", "♠️"}]}

      {updated_player, remaining_deck} = Blackjack.deal_cards(player, deck, 1)

      assert length(updated_player.hand) == 3
      assert updated_player.hand == [{"A", "♣️"}, {"K", "♠️"}, {"5", "♥️"}]
      assert remaining_deck == [{"6", "♦️"}]
    end

    test "handles player with no existing hand" do
      deck = [{"A", "♥️"}, {"K", "♦️"}]
      player = %{}

      {updated_player, remaining_deck} = Blackjack.deal_cards(player, deck, 1)

      assert updated_player.hand == [{"A", "♥️"}]
      assert remaining_deck == [{"K", "♦️"}]
    end
  end

  describe "check_naturals/1" do
    test "identifies natural blackjacks" do
      players = %{
        "player1" => %{hand: [{"A", "♥️"}, {"K", "♦️"}], status: :playing},
        "player2" => %{hand: [{"5", "♣️"}, {"6", "♠️"}], status: :playing}
      }

      updated_players = Blackjack.check_naturals(players)

      # Player1 should have blackjack
      assert updated_players["player1"].status == :stand
      assert updated_players["player1"].result == :blackjack

      # Player2 should remain unchanged
      assert updated_players["player2"].status == :playing
      refute Map.has_key?(updated_players["player2"], :result)
    end

    test "doesn't mark non-blackjack 21s as natural" do
      players = %{
        "player1" => %{hand: [{"7", "♥️"}, {"7", "♦️"}, {"7", "♣️"}], status: :playing}
      }

      updated_players = Blackjack.check_naturals(players)

      # Should not be marked as blackjack (3 cards)
      assert updated_players["player1"].status == :playing
      refute Map.has_key?(updated_players["player1"], :result)
    end
  end

  describe "activate_next_player/1" do
    test "finds first player with :playing status" do
      players = %{
        "player1" => %{status: :bust},
        "player2" => %{status: :playing},
        "player3" => %{status: :playing}
      }

      {active_id, _} = Blackjack.activate_next_player(players)
      assert active_id == "player2"
    end

    test "returns nil when no players are playing" do
      players = %{
        "player1" => %{status: :bust},
        "player2" => %{status: :stand}
      }

      {active_id, _} = Blackjack.activate_next_player(players)
      assert active_id == nil
    end

    test "handles empty players map" do
      {active_id, _} = Blackjack.activate_next_player(%{})
      assert active_id == nil
    end
  end

  describe "new_game/1" do
    test "creates new game with correct structure" do
      game = Blackjack.new_game(["player1", "player2"])

      assert Map.has_key?(game, :deck)
      assert Map.has_key?(game, :players)
      assert Map.has_key?(game, :dealer)
      assert Map.has_key?(game, :active_player_id)
      assert Map.has_key?(game, :status)
      assert Map.has_key?(game, :winner)

      # Deck should be smaller after dealing
      assert length(game.deck) < 52

      # Players should have 2 cards each
      assert length(game.players["player1"].hand) == 2
      assert length(game.players["player2"].hand) == 2

      # Dealer should have 2 cards
      assert length(game.dealer.hand) == 2
    end

    test "handles single player" do
      game = Blackjack.new_game(["solo_player"])

      assert map_size(game.players) == 1
      assert Map.has_key?(game.players, "solo_player")
    end

    test "sets active player or moves to dealer turn if all have blackjack" do
      # Test multiple times to catch the case where all players get blackjack
      game = Blackjack.new_game(["player1"])

      assert game.status in [:playing, :dealer_turn]

      if game.status == :playing do
        assert game.active_player_id != nil
      else
        assert game.active_player_id == nil
      end
    end
  end

  describe "hit/2" do
    setup do
      # Create a predictable deck for testing
      deck = [{"5", "♥️"}, {"K", "♦️"}, {"A", "♣️"}, {"2", "♠️"}]

      game = %{
        deck: deck,
        players: %{
          "player1" => %{
            hand: [{"7", "♥️"}, {"8", "♦️"}],
            status: :playing,
            score: 15,
            bet: 10,
            balance: 100
          }
        },
        dealer: %{hand: [{"A", "♠️"}, {"6", "♣️"}], status: :waiting, score: 17},
        active_player_id: "player1",
        status: :playing,
        winner: nil
      }

      {:ok, game: game}
    end

    test "adds card to active player and updates score", %{game: game} do
      updated_game = Blackjack.hit(game, "player1")

      player = updated_game.players["player1"]
      assert length(player.hand) == 3
      assert List.last(player.hand) == {"5", "♥️"}
      # 7 + 8 + 5
      assert player.score == 20
    end

    test "doesn't allow hit from non-active player", %{game: game} do
      result = Blackjack.hit(game, "wrong_player")
      # Should be unchanged
      assert result == game
    end

    test "handles player bust", %{game: game} do
      # Set up a hand that will bust with next card
      bust_game = put_in(game.players["player1"].hand, [{"K", "♠️"}, {"Q", "♥️"}])
      bust_game = put_in(bust_game.players["player1"].score, 20)

      updated_game = Blackjack.hit(bust_game, "player1")

      player = updated_game.players["player1"]
      assert player.status == :bust
      assert player.result == :lose
      # Lost bet of 10
      assert player.balance == 90
    end

    test "moves to next player after current player busts", %{game: game} do
      # Add another player
      game =
        put_in(game.players["player2"], %{
          hand: [{"2", "♣️"}, {"3", "♦️"}],
          status: :playing,
          score: 5,
          bet: 10,
          balance: 100
        })

      # Make player1 bust
      bust_game = put_in(game.players["player1"].hand, [{"K", "♠️"}, {"Q", "♥️"}])
      bust_game = put_in(bust_game.players["player1"].score, 20)

      updated_game = Blackjack.hit(bust_game, "player1")

      assert updated_game.active_player_id == "player2"
      assert updated_game.status == :playing
    end

    test "moves to dealer turn when all players finish", %{game: game} do
      # Set up player to bust (only player in game)
      bust_game = put_in(game.players["player1"].hand, [{"K", "♠️"}, {"Q", "♥️"}])
      bust_game = put_in(bust_game.players["player1"].score, 20)

      updated_game = Blackjack.hit(bust_game, "player1")

      assert updated_game.active_player_id == nil
      # Should process dealer turn and finish
      assert updated_game.status == :game_over
    end
  end

  describe "stand/2" do
    setup do
      game = %{
        deck: [{"5", "♥️"}, {"K", "♦️"}],
        players: %{
          "player1" => %{hand: [{"7", "♥️"}, {"8", "♦️"}], status: :playing, score: 15},
          "player2" => %{hand: [{"9", "♣️"}, {"A", "♠️"}], status: :playing, score: 20}
        },
        dealer: %{hand: [{"A", "♠️"}, {"6", "♣️"}], status: :waiting, score: 17},
        active_player_id: "player1",
        status: :playing,
        winner: nil
      }

      {:ok, game: game}
    end

    test "sets player status to stand and moves to next player", %{game: game} do
      updated_game = Blackjack.stand(game, "player1")

      assert updated_game.players["player1"].status == :stand
      assert updated_game.active_player_id == "player2"
      assert updated_game.status == :playing
    end

    test "doesn't allow stand from non-active player", %{game: game} do
      result = Blackjack.stand(game, "player2")
      # Should be unchanged
      assert result == game
    end

    test "moves to dealer turn when all players have stood", %{game: game} do
      # Make player2 already standing
      game = put_in(game.players["player2"].status, :stand)

      updated_game = Blackjack.stand(game, "player1")

      assert updated_game.active_player_id == nil
      # Should process dealer and finish
      assert updated_game.status == :game_over
    end
  end

  describe "determine_winners/1" do
    test "player wins when dealer busts" do
      game = %{
        players: %{
          "player1" => %{
            hand: [{"7", "♥️"}, {"8", "♦️"}],
            status: :stand,
            score: 15,
            bet: 10,
            balance: 100
          }
        },
        dealer: %{hand: [{"K", "♠️"}, {"Q", "♥️"}, {"5", "♣️"}], status: :bust, score: 25},
        status: :game_over
      }

      updated_game = Blackjack.determine_winners(game)

      player = updated_game.players["player1"]
      assert player.result == :win
      # Won bet
      assert player.balance == 110
      assert "player1" in updated_game.winners
    end

    test "player loses when dealer has higher score" do
      game = %{
        players: %{
          "player1" => %{
            hand: [{"7", "♥️"}, {"8", "♦️"}],
            status: :stand,
            score: 15,
            bet: 10,
            balance: 100
          }
        },
        dealer: %{hand: [{"K", "♠️"}, {"9", "♥️"}], status: :stand, score: 19},
        status: :game_over
      }

      updated_game = Blackjack.determine_winners(game)

      player = updated_game.players["player1"]
      assert player.result == :lose
      # Lost bet
      assert player.balance == 90
      assert updated_game.winners == []
    end

    test "push when scores are equal" do
      game = %{
        players: %{
          "player1" => %{
            hand: [{"K", "♥️"}, {"8", "♦️"}],
            status: :stand,
            score: 18,
            bet: 10,
            balance: 100
          }
        },
        dealer: %{hand: [{"9", "♠️"}, {"9", "♥️"}], status: :stand, score: 18},
        status: :game_over
      }

      updated_game = Blackjack.determine_winners(game)

      player = updated_game.players["player1"]
      assert player.result == :push
      # No change
      assert player.balance == 100
      assert updated_game.winners == []
    end

    test "blackjack pays 3:2" do
      game = %{
        players: %{
          "player1" => %{
            hand: [{"A", "♥️"}, {"K", "♦️"}],
            status: :stand,
            score: 21,
            bet: 10,
            balance: 100,
            result: :blackjack
          }
        },
        dealer: %{hand: [{"K", "♠️"}, {"9", "♥️"}], status: :stand, score: 19},
        status: :game_over
      }

      updated_game = Blackjack.determine_winners(game)

      player = updated_game.players["player1"]
      # 100 + (10 * 1.5)
      assert player.balance == 115
      assert "player1" in updated_game.winners
    end

    test "blackjack pushes against dealer blackjack" do
      game = %{
        players: %{
          "player1" => %{
            hand: [{"A", "♥️"}, {"K", "♦️"}],
            status: :stand,
            score: 21,
            bet: 10,
            balance: 100,
            result: :blackjack
          }
        },
        dealer: %{hand: [{"A", "♠️"}, {"Q", "♥️"}], status: :stand, score: 21},
        status: :game_over
      }

      updated_game = Blackjack.determine_winners(game)

      player = updated_game.players["player1"]
      # No change
      assert player.balance == 100
      assert updated_game.winners == []
    end
  end

  describe "render_card/1" do
    test "renders card with value and suit" do
      assert Blackjack.render_card({"A", "♥️"}) == "A♥️"
      assert Blackjack.render_card({"K", "♠️"}) == "K♠️"
      assert Blackjack.render_card({"10", "♦️"}) == "10♦️"
    end
  end

  describe "new_round/1" do
    test "creates new game preserving player balances" do
      old_game = %{
        players: %{
          "player1" => %{balance: 150, bet: 10},
          "player2" => %{balance: 75, bet: 10}
        }
      }

      new_game = Blackjack.new_round(old_game)

      # Should have fresh hands but preserved balances
      assert new_game.players["player1"].balance == 150
      assert new_game.players["player2"].balance == 75
      assert length(new_game.players["player1"].hand) == 2
      assert length(new_game.players["player2"].hand) == 2
    end
  end

  describe "add_player/2" do
    setup do
      game = %{
        deck: [{"5", "♥️"}, {"K", "♦️"}, {"A", "♣️"}, {"2", "♠️"}],
        players: %{
          "existing" => %{hand: [{"7", "♥️"}, {"8", "♦️"}], status: :playing, score: 15}
        },
        dealer: %{hand: [{"A", "♠️"}, {"6", "♣️"}]},
        active_player_id: "existing",
        status: :playing
      }

      {:ok, game: game}
    end

    test "adds new player to active game", %{game: game} do
      updated_game = Blackjack.add_player(game, "new_player")

      assert Map.has_key?(updated_game.players, "new_player")
      new_player = updated_game.players["new_player"]
      assert length(new_player.hand) == 2
      assert new_player.status == :playing
      assert new_player.balance == 100
    end

    test "doesn't add player if they already exist", %{game: game} do
      updated_game = Blackjack.add_player(game, "existing")
      assert updated_game == game
    end

    test "doesn't add player if game is not in playing state", %{game: game} do
      finished_game = %{game | status: :game_over}
      updated_game = Blackjack.add_player(finished_game, "new_player")
      assert updated_game == finished_game
    end

    test "handles new player with blackjack", %{game: game} do
      # Set up deck so new player gets blackjack
      blackjack_deck = [{"A", "♥️"}, {"K", "♦️"} | game.deck]
      game = %{game | deck: blackjack_deck}

      updated_game = Blackjack.add_player(game, "lucky_player")

      lucky_player = updated_game.players["lucky_player"]
      # Should auto-stand on blackjack
      assert lucky_player.status == :stand
      assert lucky_player.score == 21
    end
  end
end
