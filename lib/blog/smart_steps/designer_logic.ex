defmodule Blog.SmartSteps.DesignerLogic do
  @moduledoc """
  Pure validation and analysis functions for scenario trees.
  Used by the designer to check tree integrity.
  """

  alias Blog.SmartSteps.Types.{ScenarioTree, Scenario}

  @doc """
  Validate a scenario tree. Returns `{:ok, []}` if valid,
  or `{:error, errors}` with a list of error strings.
  """
  def validate_tree(%ScenarioTree{} = tree) do
    errors =
      []
      |> check_title(tree)
      |> check_has_scenarios(tree)
      |> check_start_exists(tree)
      |> check_choice_targets(tree)
      |> check_game_over_path(tree)

    case errors do
      [] -> {:ok, []}
      errors -> {:error, Enum.reverse(errors)}
    end
  end

  defp check_title(errors, %{title: nil}), do: ["Tree must have a title" | errors]
  defp check_title(errors, %{title: t}) when is_binary(t) do
    if String.trim(t) == "", do: ["Tree must have a title" | errors], else: errors
  end
  defp check_title(errors, _), do: ["Tree must have a title" | errors]

  defp check_has_scenarios(errors, %{scenarios: s}) when map_size(s) == 0,
    do: ["Tree must have at least one scenario" | errors]
  defp check_has_scenarios(errors, _), do: errors

  defp check_start_exists(errors, %{start_scenario_id: sid, scenarios: scenarios}) do
    if Map.has_key?(scenarios, sid),
      do: errors,
      else: ["Start scenario ID \"#{sid}\" does not exist in scenarios" | errors]
  end

  defp check_choice_targets(errors, %{scenarios: scenarios}) do
    Enum.reduce(scenarios, errors, fn {_id, scenario}, acc ->
      Enum.reduce(scenario.choices, acc, fn choice, inner_acc ->
        if choice.next_scenario_id != "GAME_OVER" && !Map.has_key?(scenarios, choice.next_scenario_id) do
          ["Choice \"#{choice.id}\" in scenario \"#{scenario.id}\" points to non-existent scenario \"#{choice.next_scenario_id}\"" | inner_acc]
        else
          inner_acc
        end
      end)
    end)
  end

  defp check_game_over_path(errors, %{start_scenario_id: sid, scenarios: scenarios}) do
    if Map.has_key?(scenarios, sid) do
      if has_game_over_path?(scenarios, sid, MapSet.new()),
        do: errors,
        else: ["Tree must have at least one reachable game-over path from start" | errors]
    else
      errors
    end
  end

  defp has_game_over_path?(scenarios, scenario_id, visited) do
    if MapSet.member?(visited, scenario_id), do: false, else: do_check_path(scenarios, scenario_id, MapSet.put(visited, scenario_id))
  end

  defp do_check_path(scenarios, scenario_id, visited) do
    case Map.get(scenarios, scenario_id) do
      nil -> false
      %{is_game_over: true} -> true
      scenario ->
        Enum.any?(scenario.choices, fn choice ->
          choice.next_scenario_id == "GAME_OVER" ||
            has_game_over_path?(scenarios, choice.next_scenario_id, visited)
        end)
    end
  end

  @doc "Find scenarios not reachable from start_id via BFS."
  def find_orphans(scenarios, start_id) when is_map(scenarios) do
    reachable = bfs_reachable(scenarios, start_id)
    scenarios
    |> Map.values()
    |> Enum.filter(fn s -> !MapSet.member?(reachable, s.id) end)
  end

  defp bfs_reachable(scenarios, start_id) do
    do_bfs(scenarios, [start_id], MapSet.new())
  end

  defp do_bfs(_scenarios, [], visited), do: visited
  defp do_bfs(scenarios, [current | rest], visited) do
    if MapSet.member?(visited, current) do
      do_bfs(scenarios, rest, visited)
    else
      visited = MapSet.put(visited, current)
      case Map.get(scenarios, current) do
        nil ->
          do_bfs(scenarios, rest, visited)
        scenario ->
          next_ids =
            scenario.choices
            |> Enum.map(& &1.next_scenario_id)
            |> Enum.filter(& &1 != "GAME_OVER")
            |> Enum.reject(&MapSet.member?(visited, &1))
          do_bfs(scenarios, rest ++ next_ids, visited)
      end
    end
  end

  @doc "Find choices that point to non-existent scenario IDs (not GAME_OVER)."
  def find_dead_ends(scenarios) when is_map(scenarios) do
    Enum.flat_map(scenarios, fn {_id, scenario} ->
      scenario.choices
      |> Enum.filter(fn choice ->
        choice.next_scenario_id != "GAME_OVER" &&
          !Map.has_key?(scenarios, choice.next_scenario_id)
      end)
      |> Enum.map(fn choice -> %{scenario: scenario, choice: choice} end)
    end)
  end

  @doc "Compute the maximum depth from start to any game-over or leaf."
  def compute_depth(%ScenarioTree{} = tree) do
    if !Map.has_key?(tree.scenarios, tree.start_scenario_id) do
      0
    else
      {depth, _} = dfs_depth(tree.scenarios, tree.start_scenario_id, 0, MapSet.new())
      depth
    end
  end

  defp dfs_depth(scenarios, scenario_id, depth, visited) do
    if MapSet.member?(visited, scenario_id) do
      {depth, visited}
    else
      case Map.get(scenarios, scenario_id) do
        nil ->
          {depth, visited}

        %{choices: choices, is_game_over: is_game_over} when choices == [] or is_game_over == true ->
          {depth, visited}

        scenario ->
          visited = MapSet.put(visited, scenario_id)

          {max_d, visited} =
            Enum.reduce(scenario.choices, {depth, visited}, fn choice, {max_so_far, vis} ->
              if choice.next_scenario_id == "GAME_OVER" do
                {max(max_so_far, depth + 1), vis}
              else
                {child_depth, vis} = dfs_depth(scenarios, choice.next_scenario_id, depth + 1, vis)
                {max(max_so_far, child_depth), vis}
              end
            end)

          visited = MapSet.delete(visited, scenario_id)
          {max_d, visited}
      end
    end
  end

  @max_paths 100

  @doc "Compute all unique paths from start to game-over. Capped at #{@max_paths}."
  def compute_all_paths(%ScenarioTree{} = tree) do
    if !Map.has_key?(tree.scenarios, tree.start_scenario_id) do
      []
    else
      visited = MapSet.new([tree.start_scenario_id])
      {paths, _} = dfs_paths(tree.scenarios, tree.start_scenario_id, [], visited, [], 0)
      paths
    end
  end

  defp dfs_paths(_scenarios, _scenario_id, _current_path, _visited, paths, count) when count >= @max_paths do
    {paths, count}
  end

  defp dfs_paths(scenarios, scenario_id, current_path, visited, paths, count) do
    case Map.get(scenarios, scenario_id) do
      nil ->
        {paths, count}

      scenario ->
        path = current_path ++ [scenario_id]

        if scenario.is_game_over || scenario.choices == [] do
          {[path | paths], count + 1}
        else
          Enum.reduce(scenario.choices, {paths, count}, fn choice, {p, c} ->
            if c >= @max_paths do
              {p, c}
            else
              if choice.next_scenario_id == "GAME_OVER" do
                {[path | p], c + 1}
              else
                if MapSet.member?(visited, choice.next_scenario_id) do
                  {p, c}
                else
                  new_visited = MapSet.put(visited, choice.next_scenario_id)
                  dfs_paths(scenarios, choice.next_scenario_id, path, new_visited, p, c)
                end
              end
            end
          end)
        end
    end
  end
end
