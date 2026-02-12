defmodule Blog.SmartSteps.Trees do
  @moduledoc """
  Registry for all scenario trees.
  Each tree module defines a tree/0 function returning a %ScenarioTree{}.
  """

  alias Blog.SmartSteps.Trees.{
    FireDrill,
    BirthdayParty,
    NewKid,
    GroupProject,
    Cafeteria,
    SubstituteTeacher,
    Playground
  }

  @tree_modules [
    FireDrill,
    BirthdayParty,
    NewKid,
    GroupProject,
    Cafeteria,
    SubstituteTeacher,
    Playground
  ]

  @doc "Return all scenario trees."
  def all_trees do
    Enum.map(@tree_modules, & &1.tree())
  end

  @doc "Get a scenario tree by ID."
  def get_tree(id) do
    Enum.find(all_trees(), fn tree -> tree.id == id end)
  end

  @doc "Get a specific scenario by ID, optionally within a specific tree."
  def get_scenario(scenario_id, tree_id \\ nil) do
    trees =
      if tree_id do
        case get_tree(tree_id) do
          nil -> []
          tree -> [tree]
        end
      else
        all_trees()
      end

    Enum.find_value(trees, fn tree ->
      Map.get(tree.scenarios, scenario_id)
    end)
  end

  @doc "Get the start scenario for a given tree."
  def get_start_scenario(tree_id) do
    case get_tree(tree_id) do
      nil -> nil
      tree -> Map.get(tree.scenarios, tree.start_scenario_id)
    end
  end
end
