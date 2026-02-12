defmodule Blog.SmartSteps.GameLogicTest do
  use ExUnit.Case, async: true

  alias Blog.SmartSteps.GameLogic
  alias Blog.SmartSteps.Types.{GameState, Choice, Scenario, Metrics, LevelData}

  # ============================================
  # Fixtures
  # ============================================

  defp make_choice(overrides \\ %{}) do
    Map.merge(
      %Choice{
        id: "choice-1",
        text: "Ask for help",
        next_scenario_id: "scenario-2",
        risk_level: :low
      },
      overrides
    )
  end

  defp make_scenario(overrides \\ %{}) do
    Map.merge(
      %Scenario{
        id: "scenario-1",
        tree_id: "tree-1",
        location: "Classroom",
        location_category: :classroom,
        theme: :sensory_overload,
        level: 1,
        title: "The Loud Room",
        description: "The classroom is very noisy.",
        choices: [make_choice()],
        image_color: "#3498db"
      },
      overrides
    )
  end

  defp make_metrics(overrides \\ %{}) do
    Map.merge(%Metrics{}, overrides)
  end

  defp make_game_state(overrides \\ %{}) do
    Map.merge(
      %GameState{
        current_tree_id: "tree-1",
        current_scenario_id: "scenario-1",
        history: ["scenario-1"],
        phase: :game,
        role: :facilitator
      },
      overrides
    )
  end

  # ============================================
  # create_initial_state/0
  # ============================================

  describe "create_initial_state/0" do
    test "returns default state with expected values" do
      state = GameLogic.create_initial_state()
      assert state.role == nil
      assert state.session_id == ""
      assert state.current_level == 1
      assert state.max_levels == 10
      assert state.selected_choice_index == -1
      assert state.history == []
      assert state.level_data == []
      assert state.messages == []
      assert state.is_game_over == false
      assert state.phase == :menu
    end

    test "returns a new struct each time" do
      a = GameLogic.create_initial_state()
      b = GameLogic.create_initial_state()
      assert a == b
      # Lists should be separate references (push to one shouldn't affect other)
      refute :erlang.phash2(a) != :erlang.phash2(b)
    end

    test "game_over_reason defaults to nil" do
      state = GameLogic.create_initial_state()
      assert state.game_over_reason == nil
    end

    test "current_scenario_id defaults to start" do
      state = GameLogic.create_initial_state()
      assert state.current_scenario_id == "start"
    end
  end

  # ============================================
  # build_level_data/6
  # ============================================

  describe "build_level_data/6" do
    test "creates level data from inputs" do
      choice = make_choice()
      metrics = make_metrics()
      result = GameLogic.build_level_data(1, "s1", "Scene 1", choice, "notes", metrics)

      assert %LevelData{} = result
      assert result.level == 1
      assert result.scenario_id == "s1"
      assert result.scenario_title == "Scene 1"
      assert result.selected_choice_id == "choice-1"
      assert result.selected_choice_text == "Ask for help"
      assert result.risk_level == :low
      assert result.notes == "notes"
      assert result.metrics == metrics
      assert %DateTime{} = result.timestamp
    end

    test "preserves the risk level from the choice" do
      choice = make_choice(%{risk_level: :critical})
      result = GameLogic.build_level_data(2, "s2", "Scene 2", choice, "", make_metrics())
      assert result.risk_level == :critical
    end

    test "preserves the choice text" do
      choice = make_choice(%{text: "Run away"})
      result = GameLogic.build_level_data(1, "s1", "Scene 1", choice, "", make_metrics())
      assert result.selected_choice_text == "Run away"
    end
  end

  # ============================================
  # game_over?/4
  # ============================================

  describe "game_over?/4" do
    test "returns true when next_scenario_id is GAME_OVER" do
      assert GameLogic.game_over?("GAME_OVER", nil, 1, 10) == true
    end

    test "returns true when next scenario has is_game_over flag" do
      scenario = make_scenario(%{is_game_over: true})
      assert GameLogic.game_over?("scenario-end", scenario, 1, 10) == true
    end

    test "returns true when current level equals max levels" do
      scenario = make_scenario()
      assert GameLogic.game_over?("scenario-2", scenario, 10, 10) == true
    end

    test "returns true when next scenario is nil" do
      assert GameLogic.game_over?("nonexistent", nil, 1, 10) == true
    end

    test "returns false for normal scenario with remaining levels" do
      scenario = make_scenario()
      assert GameLogic.game_over?("scenario-2", scenario, 1, 10) == false
    end

    test "returns false at level 9 of 10" do
      scenario = make_scenario()
      assert GameLogic.game_over?("scenario-2", scenario, 9, 10) == false
    end
  end

  # ============================================
  # process_choice/6
  # ============================================

  describe "process_choice/6" do
    setup do
      next_scenario = make_scenario(%{id: "scenario-2", title: "Next Scene", level: 2})

      get_next_scenario = fn
        "scenario-2" -> next_scenario
        _ -> nil
      end

      {:ok, next_scenario: next_scenario, get_next: get_next_scenario}
    end

    test "returns level data for valid choice", %{get_next: get_next} do
      scenario = make_scenario()
      state = make_game_state()
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "my notes", make_metrics(), get_next)

      assert result.level_data.level == 1
      assert result.level_data.notes == "my notes"
      assert result.level_data.selected_choice_id == "choice-1"
    end

    test "returns is_game_over=false when next scenario exists", %{get_next: get_next} do
      scenario = make_scenario()
      state = make_game_state()
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_next)

      assert result.is_game_over == false
      assert result.next_scenario_id == "scenario-2"
    end

    test "returns is_game_over=true when choice leads to GAME_OVER", %{get_next: get_next} do
      scenario = make_scenario(%{
        choices: [make_choice(%{next_scenario_id: "GAME_OVER"})]
      })
      state = make_game_state()
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_next)

      assert result.is_game_over == true
    end

    test "returns is_game_over=true when at max levels", %{get_next: get_next} do
      scenario = make_scenario()
      state = make_game_state(%{current_level: 10})
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_next)

      assert result.is_game_over == true
    end

    test "returns error for invalid choice index", %{get_next: get_next} do
      scenario = make_scenario()
      state = make_game_state()
      assert {:error, "Invalid choice index: 5"} =
               GameLogic.process_choice(state, scenario, 5, "", make_metrics(), get_next)
    end

    test "includes game over message when game ends", %{get_next: get_next} do
      scenario = make_scenario(%{
        choices: [make_choice(%{next_scenario_id: "GAME_OVER"})]
      })
      state = make_game_state()
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_next)

      assert length(result.messages) == 1
      assert hd(result.messages).content == "Session complete."
    end

    test "includes level transition message when continuing", %{get_next: get_next} do
      scenario = make_scenario()
      state = make_game_state()
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_next)

      assert length(result.messages) == 1
      assert result.messages |> hd() |> Map.get(:content) |> String.contains?("Moved to Level 2")
    end

    test "sets game_over_reason to scenario title when ending at game-over scenario" do
      end_scenario = make_scenario(%{id: "scenario-end", is_game_over: true, title: "You Made It"})
      scenario = make_scenario(%{
        choices: [make_choice(%{next_scenario_id: "scenario-end"})]
      })
      state = make_game_state()

      get_end = fn
        "scenario-end" -> end_scenario
        _ -> nil
      end

      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_end)
      assert result.game_over_reason == "You Made It"
    end

    test "sets game_over_reason to 'Max levels reached' when at max", %{get_next: get_next} do
      scenario = make_scenario()
      state = make_game_state(%{current_level: 10})
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_next)

      assert result.game_over_reason == "Max levels reached"
    end

    test "does not set game_over_reason when not game over", %{get_next: get_next} do
      scenario = make_scenario()
      state = make_game_state()
      {:ok, result} = GameLogic.process_choice(state, scenario, 0, "", make_metrics(), get_next)

      assert result.game_over_reason == nil
    end
  end

  # ============================================
  # generate_session_id/0
  # ============================================

  describe "generate_session_id/0" do
    test "generates a 6-digit string" do
      id = GameLogic.generate_session_id()
      assert String.length(id) == 6
      assert String.match?(id, ~r/^\d{6}$/)
    end

    test "generates different IDs on successive calls" do
      ids = for _ <- 1..10, do: GameLogic.generate_session_id()
      # At least some should differ (extremely unlikely all 10 are the same)
      assert length(Enum.uniq(ids)) > 1
    end
  end
end
