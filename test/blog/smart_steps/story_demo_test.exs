defmodule Blog.SmartSteps.StoryDemoTest do
  use ExUnit.Case, async: true

  alias Blog.SmartSteps.StoryDemo
  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario, Choice}

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

  defp make_tree(overrides \\ %{}) do
    default = %ScenarioTree{
      id: "tree-1",
      title: "Test Tree",
      description: "A test scenario tree",
      theme: :sensory_overload,
      age_range: "6-10",
      estimated_minutes: 15,
      start_scenario_id: "scenario-1",
      scenarios: %{
        "scenario-1" => make_scenario(%{
          id: "scenario-1",
          choices: [
            make_choice(%{id: "c1", next_scenario_id: "scenario-2", risk_level: :low}),
            make_choice(%{id: "c2", next_scenario_id: "GAME_OVER", risk_level: :high})
          ]
        }),
        "scenario-2" => make_scenario(%{
          id: "scenario-2",
          level: 2,
          title: "The Hallway",
          choices: [
            make_choice(%{id: "c3", next_scenario_id: "GAME_OVER", risk_level: :medium})
          ]
        })
      }
    }
    Map.merge(default, overrides)
  end

  # ============================================
  # pick_weighted_choice/2
  # ============================================

  describe "pick_weighted_choice/2" do
    test "returns the only choice when there is one" do
      choice = make_choice(%{id: "only"})
      assert StoryDemo.pick_weighted_choice([choice]) == choice
    end

    test "returns a valid choice from the list" do
      choices = [
        make_choice(%{id: "a", risk_level: :low}),
        make_choice(%{id: "b", risk_level: :high})
      ]
      picked = StoryDemo.pick_weighted_choice(choices, 0.5)
      assert picked in choices
    end

    test "raises when given empty list" do
      assert_raise ArgumentError, ~r/Cannot pick from empty choices/, fn ->
        StoryDemo.pick_weighted_choice([])
      end
    end

    test "picks the first choice when random is 0" do
      choices = [
        make_choice(%{id: "a", risk_level: :low}),
        make_choice(%{id: "b", risk_level: :critical})
      ]
      # low weight=1, critical weight=5, total=6
      # random=0 should be less than 1/6 = 0.167, so picks first
      picked = StoryDemo.pick_weighted_choice(choices, 0)
      assert picked.id == "a"
    end

    test "biases toward higher risk levels" do
      choices = [
        make_choice(%{id: "safe", risk_level: :low}),
        make_choice(%{id: "risky", risk_level: :critical})
      ]
      # low weight=1, critical weight=5, total=6
      # Probability of "risky" = 5/6 ~= 0.833
      samples = [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9]
      risky_count =
        Enum.count(samples, fn r ->
          StoryDemo.pick_weighted_choice(choices, r).id == "risky"
        end)
      # With threshold at ~0.167, values >= 0.167 should pick "risky"
      # That's 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9 = 8 of 10
      assert risky_count > 5
    end

    test "handles all same risk levels equally" do
      choices = [
        make_choice(%{id: "a", risk_level: :medium}),
        make_choice(%{id: "b", risk_level: :medium})
      ]
      # Equal weights, so threshold at 0.5
      picked_low = StoryDemo.pick_weighted_choice(choices, 0.1)
      picked_high = StoryDemo.pick_weighted_choice(choices, 0.6)
      assert picked_low.id == "a"
      assert picked_high.id == "b"
    end

    test "returns last choice when random is very close to 1" do
      choices = [
        make_choice(%{id: "a", risk_level: :low}),
        make_choice(%{id: "b", risk_level: :low})
      ]
      picked = StoryDemo.pick_weighted_choice(choices, 0.9999)
      assert picked.id == "b"
    end
  end

  # ============================================
  # generate_random_path/2
  # ============================================

  describe "generate_random_path/2" do
    test "starts with the start scenario" do
      tree = make_tree()
      path = StoryDemo.generate_random_path(tree, fn -> 0 end)
      assert hd(path) == "scenario-1"
    end

    test "terminates at game-over" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            choices: [
              make_choice(%{id: "c1", next_scenario_id: "GAME_OVER", risk_level: :low})
            ]
          })
        }
      })
      path = StoryDemo.generate_random_path(tree, fn -> 0 end)
      assert path == ["s1"]
    end

    test "follows the path through multiple scenarios" do
      tree = make_tree()
      # random=0 picks first choice (low weight), which goes to scenario-2
      path = StoryDemo.generate_random_path(tree, fn -> 0 end)
      assert "scenario-1" in path
      assert "scenario-2" in path
    end

    test "stops at max 30 steps to prevent infinite loops" do
      # Build a cycle that never terminates
      scenarios =
        for i <- 0..49, into: %{} do
          next_id = "s#{rem(i + 1, 50)}"
          {"s#{i}", make_scenario(%{
            id: "s#{i}",
            choices: [make_choice(%{id: "c#{i}", next_scenario_id: next_id})]
          })}
        end

      tree = make_tree(%{start_scenario_id: "s0", scenarios: scenarios})
      path = StoryDemo.generate_random_path(tree, fn -> 0 end)
      assert length(path) <= 30
    end

    test "stops when encountering a game-over scenario" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            choices: [make_choice(%{id: "c1", next_scenario_id: "s-end"})]
          }),
          "s-end" => make_scenario(%{
            id: "s-end",
            is_game_over: true,
            choices: []
          })
        }
      })
      path = StoryDemo.generate_random_path(tree, fn -> 0 end)
      assert path == ["s1", "s-end"]
    end

    test "returns empty path for non-existent start scenario" do
      tree = make_tree(%{start_scenario_id: "nonexistent"})
      path = StoryDemo.generate_random_path(tree, fn -> 0 end)
      assert path == []
    end

    test "uses the provided random function for deterministic output" do
      tree = make_tree()
      path1 = StoryDemo.generate_random_path(tree, fn -> 0 end)
      path2 = StoryDemo.generate_random_path(tree, fn -> 0 end)
      assert path1 == path2
    end

    test "different random values can produce different paths" do
      tree = make_tree()
      # random=0 picks first choice (low risk -> scenario-2)
      path_low = StoryDemo.generate_random_path(tree, fn -> 0 end)
      # random=0.99 picks second choice (high risk -> GAME_OVER)
      path_high = StoryDemo.generate_random_path(tree, fn -> 0.99 end)
      # The paths should differ: one goes through scenario-2, the other ends at scenario-1
      refute path_low == path_high
    end
  end

  # ============================================
  # transition_text/1
  # ============================================

  describe "transition_text/1" do
    test "returns correct text for low risk" do
      assert StoryDemo.transition_text(:low) == "Playing it safe..."
    end

    test "returns correct text for medium risk" do
      assert StoryDemo.transition_text(:medium) == "Trying to figure it out..."
    end

    test "returns correct text for high risk" do
      assert StoryDemo.transition_text(:high) == "Things get harder..."
    end

    test "returns correct text for critical risk" do
      assert StoryDemo.transition_text(:critical) == "Everything feels overwhelming..."
    end
  end
end
