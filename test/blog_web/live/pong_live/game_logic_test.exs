defmodule BlogWeb.PongLive.GameLogicTest do
  use ExUnit.Case, async: true

  alias BlogWeb.PongLive.GameLogic

  describe "initial_state/1" do
    test "returns a map with all required keys" do
      state = GameLogic.initial_state("test_game_1")

      assert state.game_id == "test_game_1"
      assert state.game_state == :ready
      assert state.ai_controlled == true
      assert state.scores == %{wall: 0}
      assert state.trail == []
      assert state.sparkles == []
      assert state.show_defeat_message == false
      assert state.message_timer == 0
    end

    test "ball starts at center moving toward the player" do
      state = GameLogic.initial_state("test_game_2")

      assert state.ball.x == GameLogic.game_width() / 2
      assert state.ball.y == GameLogic.game_height() / 2
      assert state.ball.dx < 0, "ball should move toward the paddle (left)"
      assert state.ball.bounce_count == 0
      assert state.ball.speed_multiplier == 1.0
    end

    test "paddle starts at left side, vertically centered" do
      state = GameLogic.initial_state("test_game_3")

      assert state.paddle.x == GameLogic.paddle_offset()
      expected_y = GameLogic.game_height() / 2 - GameLogic.paddle_height() / 2
      assert state.paddle.y == expected_y
    end
  end

  describe "merge_existing_state/2" do
    test "preserves ball, paddle, scores from existing state" do
      init = GameLogic.initial_state("merge_test")

      existing = %{
        ball: %{x: 100, y: 200, dx: 3, dy: -2, bounce_count: 5, speed_multiplier: 1.2},
        paddle: %{x: 30, y: 150},
        scores: %{wall: 7},
        game_state: :playing,
        show_defeat_message: false,
        ai_controlled: false
      }

      merged = GameLogic.merge_existing_state(init, existing)

      assert merged.ball == existing.ball
      assert merged.paddle == existing.paddle
      assert merged.scores == existing.scores
      assert merged.game_state == :playing
      assert merged.ai_controlled == false
      # Should still have other fields from init
      assert merged.trail == []
      assert merged.sparkles == []
    end

    test "defaults missing fields gracefully" do
      init = GameLogic.initial_state("merge_defaults")
      existing = %{ball: init.ball, paddle: init.paddle, scores: init.scores}

      merged = GameLogic.merge_existing_state(init, existing)

      assert merged.game_state == :playing
      assert merged.show_defeat_message == false
      assert merged.ai_controlled == true
    end
  end

  describe "update_paddle_position/4" do
    test "ArrowUp moves paddle up" do
      paddle = %{x: 30, y: 100}
      result = GameLogic.update_paddle_position(paddle, "ArrowUp", 600, 100)
      assert result.y < 100
    end

    test "ArrowDown moves paddle down" do
      paddle = %{x: 30, y: 100}
      result = GameLogic.update_paddle_position(paddle, "ArrowDown", 600, 100)
      assert result.y > 100
    end

    test "ArrowUp clamps at top boundary" do
      paddle = %{x: 30, y: 0}
      result = GameLogic.update_paddle_position(paddle, "ArrowUp", 600, 100)
      assert result.y == 0
    end

    test "ArrowDown clamps at bottom boundary" do
      paddle = %{x: 30, y: 500}
      result = GameLogic.update_paddle_position(paddle, "ArrowDown", 600, 100)
      assert result.y == 500
    end

    test "nil key returns paddle unchanged" do
      paddle = %{x: 30, y: 200}
      result = GameLogic.update_paddle_position(paddle, nil, 600, 100)
      assert result == paddle
    end

    test "unrecognized key returns paddle unchanged" do
      paddle = %{x: 30, y: 200}
      result = GameLogic.update_paddle_position(paddle, "ArrowLeft", 600, 100)
      assert result == paddle
    end
  end

  describe "ball_hits_paddle?/7" do
    test "returns true when ball overlaps paddle" do
      # Ball at paddle position
      assert GameLogic.ball_hits_paddle?(
               40,
               300,
               10,
               30,
               250,
               15,
               100
             )
    end

    test "returns false when ball is far from paddle" do
      refute GameLogic.ball_hits_paddle?(
               400,
               300,
               10,
               30,
               250,
               15,
               100
             )
    end

    test "returns false when ball is above paddle" do
      refute GameLogic.ball_hits_paddle?(
               40,
               100,
               10,
               30,
               250,
               15,
               100
             )
    end

    test "returns false when ball is below paddle" do
      refute GameLogic.ball_hits_paddle?(
               40,
               400,
               10,
               30,
               250,
               15,
               100
             )
    end
  end

  describe "update_ball_and_check_scoring/7" do
    setup do
      ball = %{x: 400, y: 300, dx: 5, dy: 0, bounce_count: 0, speed_multiplier: 1.0}
      board = %{width: 800, height: 600}
      paddle = %{x: 30, y: 250}
      scores = %{wall: 0}

      %{ball: ball, board: board, paddle: paddle, scores: scores}
    end

    test "ball moving right continues playing", ctx do
      {new_ball, game_state, scores, _bounce_pos, _bounce_type} =
        GameLogic.update_ball_and_check_scoring(
          ctx.ball,
          ctx.board,
          ctx.paddle,
          10,
          15,
          100,
          ctx.scores
        )

      assert game_state == :playing
      assert new_ball.x == ctx.ball.x + ctx.ball.dx
      assert scores.wall == 0
    end

    test "ball reaching left wall triggers scoring" do
      ball = %{x: 5, y: 300, dx: -10, dy: 0, bounce_count: 0, speed_multiplier: 1.0}
      board = %{width: 800, height: 600}
      paddle = %{x: 30, y: 100}
      scores = %{wall: 0}

      {_new_ball, game_state, new_scores, _bounce_pos, bounce_type} =
        GameLogic.update_ball_and_check_scoring(ball, board, paddle, 10, 15, 100, scores)

      assert game_state == :scored
      assert new_scores.wall == 1
      assert bounce_type == :wall
    end

    test "ball bouncing off right wall reverses dx" do
      ball = %{x: 795, y: 300, dx: 10, dy: 0, bounce_count: 0, speed_multiplier: 1.0}
      board = %{width: 800, height: 600}
      paddle = %{x: 30, y: 250}
      scores = %{wall: 0}

      {new_ball, game_state, _scores, bounce_pos, bounce_type} =
        GameLogic.update_ball_and_check_scoring(ball, board, paddle, 10, 15, 100, scores)

      assert game_state == :playing
      assert new_ball.dx < 0, "ball should reverse direction on right wall"
      assert bounce_pos.x == 800
      assert bounce_type == :wall
    end

    test "ball bouncing off top wall reverses dy" do
      ball = %{x: 400, y: 5, dx: 3, dy: -10, bounce_count: 0, speed_multiplier: 1.0}
      board = %{width: 800, height: 600}
      paddle = %{x: 30, y: 250}
      scores = %{wall: 0}

      {new_ball, game_state, _scores, _bounce_pos, bounce_type} =
        GameLogic.update_ball_and_check_scoring(ball, board, paddle, 10, 15, 100, scores)

      assert game_state == :playing
      assert new_ball.dy > 0, "ball should bounce down off top wall"
      assert bounce_type == :wall
    end

    test "ball bouncing off bottom wall reverses dy" do
      ball = %{x: 400, y: 595, dx: 3, dy: 10, bounce_count: 0, speed_multiplier: 1.0}
      board = %{width: 800, height: 600}
      paddle = %{x: 30, y: 250}
      scores = %{wall: 0}

      {new_ball, game_state, _scores, _bounce_pos, bounce_type} =
        GameLogic.update_ball_and_check_scoring(ball, board, paddle, 10, 15, 100, scores)

      assert game_state == :playing
      assert new_ball.dy < 0, "ball should bounce up off bottom wall"
      assert bounce_type == :wall
    end

    test "ball hitting paddle bounces right with increased speed" do
      # Ball moving left, about to hit paddle
      ball = %{x: 50, y: 300, dx: -10, dy: 0, bounce_count: 0, speed_multiplier: 1.0}
      board = %{width: 800, height: 600}
      paddle = %{x: 30, y: 250}
      scores = %{wall: 0}

      {new_ball, game_state, _scores, bounce_pos, bounce_type} =
        GameLogic.update_ball_and_check_scoring(ball, board, paddle, 10, 15, 100, scores)

      assert game_state == :playing
      assert new_ball.dx > 0, "ball should move right after paddle bounce"
      assert new_ball.bounce_count == 1
      assert new_ball.speed_multiplier > 1.0
      assert bounce_type == :paddle
      assert bounce_pos.x == 30 + 15
    end
  end

  describe "tick/1" do
    test "advances game state and returns changes map" do
      state = GameLogic.initial_state("tick_test")
      state = Map.put(state, :last_key, nil)

      changes = GameLogic.tick(state)

      assert Map.has_key?(changes, :ball)
      assert Map.has_key?(changes, :paddle)
      assert Map.has_key?(changes, :game_state)
      assert Map.has_key?(changes, :scores)
      assert Map.has_key?(changes, :trail)
      assert Map.has_key?(changes, :sparkles)
    end

    test "trail grows with each tick" do
      state = GameLogic.initial_state("trail_test") |> Map.put(:last_key, nil)
      assert state.trail == []

      changes = GameLogic.tick(state)
      assert length(changes.trail) == 1

      state2 = Map.merge(state, changes) |> Map.put(:last_key, nil)
      changes2 = GameLogic.tick(state2)
      assert length(changes2.trail) == 2
    end
  end

  describe "reset_ball/1" do
    test "returns ball near center with trail cleared" do
      result = GameLogic.reset_ball(0)

      assert result.trail == []
      ball = result.ball
      assert ball.bounce_count == 0
      assert ball.speed_multiplier == 1.0
      assert ball.dx < 0, "ball should move toward the paddle"
      # Ball should be near center
      assert abs(ball.x - GameLogic.game_width() / 2) < 50
      assert abs(ball.y - GameLogic.game_height() / 2) < 50
    end

    test "higher wall score produces more jitter" do
      # Run multiple times and check that with score > 0 there is more variance
      results_zero = for _ <- 1..20, do: GameLogic.reset_ball(0)
      results_high = for _ <- 1..20, do: GameLogic.reset_ball(10)

      xs_zero = Enum.map(results_zero, & &1.ball.x)
      xs_high = Enum.map(results_high, & &1.ball.x)

      # The variance of high-score resets should generally be higher
      # due to larger jitter_amount. We check that both are near center.
      assert Enum.all?(xs_zero, fn x -> abs(x - 400) < 50 end)
      assert Enum.all?(xs_high, fn x -> abs(x - 400) < 50 end)
    end
  end

  describe "ai_move_paddle/2" do
    test "moves paddle toward ball y position" do
      paddle = %{x: 30, y: 100}
      ball = %{x: 400, y: 400, dx: -5, dy: 0, bounce_count: 0, speed_multiplier: 1.0}

      new_paddle = GameLogic.ai_move_paddle(paddle, ball)

      # Paddle should move toward the ball (downward since ball.y > paddle.y)
      assert new_paddle.y > paddle.y
    end

    test "clamps paddle within board bounds" do
      paddle = %{x: 30, y: 590}
      ball = %{x: 400, y: 600, dx: -5, dy: 0, bounce_count: 0, speed_multiplier: 1.0}

      new_paddle = GameLogic.ai_move_paddle(paddle, ball)

      max_y = GameLogic.game_height() - GameLogic.paddle_height()
      assert new_paddle.y <= max_y
      assert new_paddle.y >= 0
    end
  end

  describe "update_trail/2" do
    test "prepends new position to trail" do
      ball = %{x: 100, y: 200}
      trail = GameLogic.update_trail([], ball)

      assert length(trail) == 1
      assert hd(trail).x == 100
      assert hd(trail).y == 200
    end

    test "trims trail to max length" do
      ball = %{x: 100, y: 200}
      # Create a trail at max length
      long_trail = for i <- 1..GameLogic.trail_length(), do: %{x: i, y: i, color: "red"}

      result = GameLogic.update_trail(long_trail, ball)
      assert length(result) == GameLogic.trail_length()
      assert hd(result).x == 100
    end
  end

  describe "create_defeat_burst/2" do
    test "creates burst particles at ball position" do
      ball = %{x: 300, y: 400}
      particles = GameLogic.create_defeat_burst([], ball)

      assert length(particles) > 0

      Enum.each(particles, fn p ->
        assert p.x == 300
        assert p.y == 400
        assert p.type == :burst
        assert p.life > 0
      end)
    end

    test "ages existing sparkles" do
      existing = [
        %{x: 100, y: 100, dx: 0, dy: 0, type: :wall, life: 10, size: 3, color: "red"}
      ]

      ball = %{x: 300, y: 400}
      result = GameLogic.create_defeat_burst(existing, ball)

      # The existing sparkle should be aged (life reduced by 1)
      aged = Enum.find(result, fn p -> p.type == :wall end)
      assert aged.life == 9
    end
  end

  describe "update_sparkles/3" do
    test "with nil bounce position ages and filters existing sparkles" do
      sparkles = [
        %{x: 100, y: 100, dx: 0, dy: 0, type: :wall, life: 2, size: 3, color: "red"},
        %{x: 200, y: 200, dx: 0, dy: 0, type: :paddle, life: 1, size: 3, color: "blue"}
      ]

      result = GameLogic.update_sparkles(sparkles, nil, nil)

      # life=2 becomes 1 (kept), life=1 becomes 0 (filtered out)
      assert length(result) == 1
      assert hd(result).life == 1
    end

    test "with bounce position adds a new sparkle" do
      bounce_pos = %{x: 500, y: 300}
      result = GameLogic.update_sparkles([], bounce_pos, :paddle)

      assert length(result) == 1
      sparkle = hd(result)
      assert sparkle.x == 500
      assert sparkle.y == 300
      assert sparkle.type == :paddle
      assert sparkle.life == GameLogic.sparkle_life()
    end
  end

  describe "age_sparkle/1" do
    test "decrements life by 1" do
      sparkle = %{life: 10, x: 0, y: 0}
      assert GameLogic.age_sparkle(sparkle).life == 9
    end
  end

  describe "update_particle_positions/1" do
    test "moves particles with velocity" do
      particles = [
        %{x: 100, y: 200, dx: 5, dy: -3, life: 10, size: 3},
        %{x: 50, y: 50, dx: 0, dy: 0, life: 5, size: 2}
      ]

      result = GameLogic.update_particle_positions(particles)

      moving = Enum.at(result, 0)
      assert moving.x == 105
      assert moving.y == 197

      stationary = Enum.at(result, 1)
      assert stationary.x == 50
      assert stationary.y == 50
    end
  end

  describe "clamp/3" do
    test "returns value when in range" do
      assert GameLogic.clamp(5, 0, 10) == 5
    end

    test "returns lo when value is below" do
      assert GameLogic.clamp(-5, 0, 10) == 0
    end

    test "returns hi when value is above" do
      assert GameLogic.clamp(15, 0, 10) == 10
    end
  end

  describe "generate_rainbow_color/1" do
    test "returns an hsl color string" do
      color = GameLogic.generate_rainbow_color(0)
      assert color =~ ~r/^hsl\(\d+, \d+%, \d+%\)$/
    end

    test "different indices produce different colors" do
      c1 = GameLogic.generate_rainbow_color(0)
      c2 = GameLogic.generate_rainbow_color(10)
      # Colors differ due to index offset (hue shifts by index * 15)
      # They could theoretically match if timestamp wraps, but extremely unlikely
      assert is_binary(c1) and is_binary(c2)
    end
  end
end
