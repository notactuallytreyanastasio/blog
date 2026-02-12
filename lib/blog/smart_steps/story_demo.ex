defmodule Blog.SmartSteps.StoryDemo do
  @moduledoc """
  Pure functions for the automated story demo.
  Generates weighted random paths through scenario trees.
  """

  alias Blog.SmartSteps.Types.{Choice, ScenarioTree}

  @risk_weights %{
    low: 1,
    medium: 2,
    high: 4,
    critical: 5
  }

  @max_steps 30

  @doc """
  Pick a choice weighted by risk level.
  Weights: critical=5, high=4, medium=2, low=1.
  Optional `random` parameter should be in [0, 1).
  """
  def pick_weighted_choice([], _random \\ nil),
    do: raise(ArgumentError, "Cannot pick from empty choices list")

  def pick_weighted_choice([choice], _random), do: choice

  def pick_weighted_choice(choices, random) when is_list(choices) do
    r = random || :rand.uniform()

    total_weight =
      Enum.reduce(choices, 0, fn %Choice{risk_level: rl}, acc ->
        acc + Map.fetch!(@risk_weights, rl)
      end)

    {_cumulative, result} =
      Enum.reduce_while(choices, {0.0, nil}, fn choice, {cumulative, _} ->
        weight = Map.fetch!(@risk_weights, choice.risk_level)
        new_cumulative = cumulative + weight / total_weight

        if r < new_cumulative do
          {:halt, {new_cumulative, choice}}
        else
          {:cont, {new_cumulative, nil}}
        end
      end)

    result || List.last(choices)
  end

  @doc """
  Generate a random path through a tree using weighted random selection.
  Returns list of scenario IDs from start to game-over (max #{@max_steps} steps).
  Optional `random_fn` is a 0-arity function returning a float in [0, 1).
  """
  def generate_random_path(%ScenarioTree{} = tree, random_fn \\ nil) do
    rng = random_fn || fn -> :rand.uniform() end
    do_walk(tree.scenarios, tree.start_scenario_id, rng, [], 0)
  end

  defp do_walk(_scenarios, _current_id, _rng, path, step) when step >= @max_steps do
    Enum.reverse(path)
  end

  defp do_walk(scenarios, current_id, rng, path, step) do
    case Map.get(scenarios, current_id) do
      nil ->
        Enum.reverse(path)

      scenario ->
        path = [current_id | path]

        if scenario.is_game_over || scenario.choices == [] do
          Enum.reverse(path)
        else
          choice = pick_weighted_choice(scenario.choices, rng.())

          if choice.next_scenario_id == "GAME_OVER" do
            Enum.reverse(path)
          else
            do_walk(scenarios, choice.next_scenario_id, rng, path, step + 1)
          end
        end
    end
  end

  @doc "Get narrative transition text based on risk level."
  def transition_text(:low), do: "Playing it safe..."
  def transition_text(:medium), do: "Trying to figure it out..."
  def transition_text(:high), do: "Things get harder..."
  def transition_text(:critical), do: "Everything feels overwhelming..."
end
