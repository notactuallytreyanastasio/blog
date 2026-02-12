defmodule Blog.SmartSteps.DesignerLogicTest do
  use ExUnit.Case, async: true

  alias Blog.SmartSteps.DesignerLogic
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
            make_choice(%{id: "c1", next_scenario_id: "scenario-2"}),
            make_choice(%{id: "c2", next_scenario_id: "GAME_OVER", risk_level: :high})
          ]
        }),
        "scenario-2" => make_scenario(%{
          id: "scenario-2",
          level: 2,
          title: "The Hallway",
          choices: [
            make_choice(%{id: "c3", next_scenario_id: "GAME_OVER"})
          ]
        })
      }
    }
    Map.merge(default, overrides)
  end

  # ============================================
  # validate_tree/1
  # ============================================

  describe "validate_tree/1" do
    test "accepts a valid tree" do
      assert {:ok, []} = DesignerLogic.validate_tree(make_tree())
    end

    test "rejects a tree with empty title" do
      {:error, errors} = DesignerLogic.validate_tree(make_tree(%{title: ""}))
      assert "Tree must have a title" in errors
    end

    test "rejects a tree with whitespace-only title" do
      {:error, errors} = DesignerLogic.validate_tree(make_tree(%{title: "   "}))
      assert "Tree must have a title" in errors
    end

    test "rejects a tree with no scenarios" do
      {:error, errors} = DesignerLogic.validate_tree(make_tree(%{scenarios: %{}}))
      assert "Tree must have at least one scenario" in errors
    end

    test "rejects a tree with non-existent start_scenario_id" do
      {:error, errors} = DesignerLogic.validate_tree(make_tree(%{start_scenario_id: "nonexistent"}))
      assert Enum.any?(errors, &String.contains?(&1, "nonexistent"))
    end

    test "rejects a tree with dead-end choices" do
      tree = make_tree(%{
        scenarios: %{
          "scenario-1" => make_scenario(%{
            id: "scenario-1",
            choices: [
              make_choice(%{id: "c1", next_scenario_id: "missing-scenario"})
            ]
          })
        }
      })
      {:error, errors} = DesignerLogic.validate_tree(tree)
      assert Enum.any?(errors, &String.contains?(&1, "missing-scenario"))
    end

    test "allows choices pointing to GAME_OVER" do
      tree = make_tree(%{
        scenarios: %{
          "scenario-1" => make_scenario(%{
            id: "scenario-1",
            choices: [
              make_choice(%{id: "c1", next_scenario_id: "GAME_OVER"})
            ]
          })
        }
      })
      assert {:ok, []} = DesignerLogic.validate_tree(tree)
    end

    test "rejects a tree with no game-over path from start" do
      tree = make_tree(%{
        scenarios: %{
          "scenario-1" => make_scenario(%{
            id: "scenario-1",
            choices: [
              make_choice(%{id: "c1", next_scenario_id: "scenario-2"})
            ]
          }),
          "scenario-2" => make_scenario(%{
            id: "scenario-2",
            choices: [
              make_choice(%{id: "c2", next_scenario_id: "scenario-1"})
            ]
          })
        }
      })
      {:error, errors} = DesignerLogic.validate_tree(tree)
      assert Enum.any?(errors, &String.contains?(&1, "game-over path"))
    end

    test "accepts a tree where game-over is reached via is_game_over flag" do
      tree = make_tree(%{
        scenarios: %{
          "scenario-1" => make_scenario(%{
            id: "scenario-1",
            choices: [
              make_choice(%{id: "c1", next_scenario_id: "scenario-end"})
            ]
          }),
          "scenario-end" => make_scenario(%{
            id: "scenario-end",
            is_game_over: true,
            choices: []
          })
        }
      })
      assert {:ok, []} = DesignerLogic.validate_tree(tree)
    end

    test "collects multiple errors at once" do
      tree = make_tree(%{
        title: "",
        start_scenario_id: "nonexistent",
        scenarios: %{}
      })
      {:error, errors} = DesignerLogic.validate_tree(tree)
      assert length(errors) >= 2
    end
  end

  # ============================================
  # find_orphans/2
  # ============================================

  describe "find_orphans/2" do
    test "returns empty list when all scenarios are reachable" do
      tree = make_tree()
      orphans = DesignerLogic.find_orphans(tree.scenarios, tree.start_scenario_id)
      assert orphans == []
    end

    test "finds unreachable scenarios" do
      scenarios = %{
        "scenario-1" => make_scenario(%{
          id: "scenario-1",
          choices: [make_choice(%{id: "c1", next_scenario_id: "GAME_OVER"})]
        }),
        "scenario-orphan" => make_scenario(%{
          id: "scenario-orphan",
          title: "Orphaned",
          choices: []
        })
      }
      orphans = DesignerLogic.find_orphans(scenarios, "scenario-1")
      assert length(orphans) == 1
      assert hd(orphans).id == "scenario-orphan"
    end

    test "finds multiple orphan scenarios" do
      scenarios = %{
        "scenario-1" => make_scenario(%{
          id: "scenario-1",
          choices: [make_choice(%{id: "c1", next_scenario_id: "GAME_OVER"})]
        }),
        "orphan-a" => make_scenario(%{id: "orphan-a", choices: []}),
        "orphan-b" => make_scenario(%{id: "orphan-b", choices: []})
      }
      orphans = DesignerLogic.find_orphans(scenarios, "scenario-1")
      assert length(orphans) == 2
      orphan_ids = orphans |> Enum.map(& &1.id) |> Enum.sort()
      assert orphan_ids == ["orphan-a", "orphan-b"]
    end

    test "handles chain of reachable scenarios" do
      scenarios = %{
        "s1" => make_scenario(%{
          id: "s1",
          choices: [make_choice(%{id: "c1", next_scenario_id: "s2"})]
        }),
        "s2" => make_scenario(%{
          id: "s2",
          choices: [make_choice(%{id: "c2", next_scenario_id: "s3"})]
        }),
        "s3" => make_scenario(%{
          id: "s3",
          choices: [make_choice(%{id: "c3", next_scenario_id: "GAME_OVER"})]
        })
      }
      orphans = DesignerLogic.find_orphans(scenarios, "s1")
      assert orphans == []
    end

    test "handles non-existent start ID gracefully" do
      scenarios = %{
        "s1" => make_scenario(%{id: "s1", choices: []})
      }
      orphans = DesignerLogic.find_orphans(scenarios, "nonexistent")
      assert length(orphans) == 1
      assert hd(orphans).id == "s1"
    end
  end

  # ============================================
  # find_dead_ends/1
  # ============================================

  describe "find_dead_ends/1" do
    test "returns empty list when all choices point to valid scenarios" do
      tree = make_tree()
      dead_ends = DesignerLogic.find_dead_ends(tree.scenarios)
      assert dead_ends == []
    end

    test "finds choices pointing to non-existent scenarios" do
      scenarios = %{
        "s1" => make_scenario(%{
          id: "s1",
          choices: [
            make_choice(%{id: "c1", next_scenario_id: "missing"})
          ]
        })
      }
      dead_ends = DesignerLogic.find_dead_ends(scenarios)
      assert length(dead_ends) == 1
      assert hd(dead_ends).choice.id == "c1"
      assert hd(dead_ends).scenario.id == "s1"
    end

    test "does not flag choices pointing to GAME_OVER" do
      scenarios = %{
        "s1" => make_scenario(%{
          id: "s1",
          choices: [
            make_choice(%{id: "c1", next_scenario_id: "GAME_OVER"})
          ]
        })
      }
      dead_ends = DesignerLogic.find_dead_ends(scenarios)
      assert dead_ends == []
    end

    test "finds dead ends across multiple scenarios" do
      scenarios = %{
        "s1" => make_scenario(%{
          id: "s1",
          choices: [
            make_choice(%{id: "c1", next_scenario_id: "missing-a"})
          ]
        }),
        "s2" => make_scenario(%{
          id: "s2",
          choices: [
            make_choice(%{id: "c2", next_scenario_id: "missing-b"})
          ]
        })
      }
      dead_ends = DesignerLogic.find_dead_ends(scenarios)
      assert length(dead_ends) == 2
    end

    test "handles scenarios with no choices" do
      scenarios = %{
        "s1" => make_scenario(%{id: "s1", choices: []})
      }
      dead_ends = DesignerLogic.find_dead_ends(scenarios)
      assert dead_ends == []
    end
  end

  # ============================================
  # compute_depth/1
  # ============================================

  describe "compute_depth/1" do
    test "returns 0 for non-existent start scenario" do
      tree = make_tree(%{start_scenario_id: "nonexistent"})
      assert DesignerLogic.compute_depth(tree) == 0
    end

    test "returns 1 for a single scenario with GAME_OVER" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            choices: [make_choice(%{id: "c1", next_scenario_id: "GAME_OVER"})]
          })
        }
      })
      assert DesignerLogic.compute_depth(tree) == 1
    end

    test "returns 0 for a game-over start scenario" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            is_game_over: true,
            choices: []
          })
        }
      })
      assert DesignerLogic.compute_depth(tree) == 0
    end

    test "returns correct depth for a linear chain" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            choices: [make_choice(%{id: "c1", next_scenario_id: "s2"})]
          }),
          "s2" => make_scenario(%{
            id: "s2",
            choices: [make_choice(%{id: "c2", next_scenario_id: "s3"})]
          }),
          "s3" => make_scenario(%{
            id: "s3",
            choices: [make_choice(%{id: "c3", next_scenario_id: "GAME_OVER"})]
          })
        }
      })
      assert DesignerLogic.compute_depth(tree) == 3
    end

    test "returns max depth for branching tree" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            choices: [
              make_choice(%{id: "c1", next_scenario_id: "GAME_OVER"}),
              make_choice(%{id: "c2", next_scenario_id: "s2"})
            ]
          }),
          "s2" => make_scenario(%{
            id: "s2",
            choices: [make_choice(%{id: "c3", next_scenario_id: "GAME_OVER"})]
          })
        }
      })
      # Longest path: s1 -> s2 -> GAME_OVER = depth 2
      assert DesignerLogic.compute_depth(tree) == 2
    end
  end

  # ============================================
  # compute_all_paths/1
  # ============================================

  describe "compute_all_paths/1" do
    test "returns empty list for non-existent start" do
      tree = make_tree(%{start_scenario_id: "nonexistent"})
      assert DesignerLogic.compute_all_paths(tree) == []
    end

    test "returns single path for linear tree" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            choices: [make_choice(%{id: "c1", next_scenario_id: "s2"})]
          }),
          "s2" => make_scenario(%{
            id: "s2",
            choices: [make_choice(%{id: "c2", next_scenario_id: "GAME_OVER"})]
          })
        }
      })
      paths = DesignerLogic.compute_all_paths(tree)
      assert length(paths) == 1
      assert ["s1", "s2"] in paths
    end

    test "returns multiple paths for branching tree" do
      tree = make_tree()
      paths = DesignerLogic.compute_all_paths(tree)
      # Default tree: s1->GAME_OVER and s1->s2->GAME_OVER
      assert length(paths) >= 2
    end

    test "handles game-over scenario via is_game_over flag" do
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
      paths = DesignerLogic.compute_all_paths(tree)
      assert length(paths) == 1
      assert ["s1", "s-end"] in paths
    end

    test "does not include cycles (avoids infinite loops)" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            choices: [
              make_choice(%{id: "c1", next_scenario_id: "s2"}),
              make_choice(%{id: "c2", next_scenario_id: "GAME_OVER"})
            ]
          }),
          "s2" => make_scenario(%{
            id: "s2",
            choices: [
              make_choice(%{id: "c3", next_scenario_id: "s1"}),
              make_choice(%{id: "c4", next_scenario_id: "GAME_OVER"})
            ]
          })
        }
      })
      paths = DesignerLogic.compute_all_paths(tree)
      # Should find paths but not loop infinitely
      assert length(paths) > 0
      assert length(paths) <= 100
    end

    test "limits to 100 paths maximum" do
      # Build a wide tree that would produce many paths
      mid_scenarios =
        for i <- 0..14, into: %{} do
          mid_id = "mid-#{i}"
          mid_choices =
            for j <- 0..14 do
              make_choice(%{
                id: "mc-#{i}-#{j}",
                next_scenario_id: "GAME_OVER",
                risk_level: :low
              })
            end
          {mid_id, make_scenario(%{id: mid_id, choices: mid_choices})}
        end

      start_choices =
        for i <- 0..14 do
          make_choice(%{
            id: "sc-#{i}",
            next_scenario_id: "mid-#{i}",
            risk_level: :low
          })
        end

      scenarios = Map.put(mid_scenarios, "start", make_scenario(%{id: "start", choices: start_choices}))

      tree = make_tree(%{start_scenario_id: "start", scenarios: scenarios})
      paths = DesignerLogic.compute_all_paths(tree)
      assert length(paths) <= 100
    end

    test "returns path with single scenario when start is game-over" do
      tree = make_tree(%{
        start_scenario_id: "s1",
        scenarios: %{
          "s1" => make_scenario(%{
            id: "s1",
            is_game_over: true,
            choices: []
          })
        }
      })
      paths = DesignerLogic.compute_all_paths(tree)
      assert length(paths) == 1
      assert ["s1"] in paths
    end
  end
end
