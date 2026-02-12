defmodule Blog.SmartSteps do
  @moduledoc """
  Context module for the Smart Steps scenario system.
  Autism-appropriate behavioral learning through interactive scenarios.
  """

  alias Blog.SmartSteps.{GameLogic, Metrics, DesignerLogic, StoryDemo, Trees, Types}

  # Trees
  defdelegate all_trees(), to: Trees
  defdelegate get_tree(id), to: Trees
  defdelegate get_scenario(id, tree_id \\ nil), to: Trees
  defdelegate get_start_scenario(tree_id), to: Trees

  # Game logic
  defdelegate create_initial_state(), to: GameLogic
  defdelegate generate_session_id(), to: GameLogic

  # Metrics
  defdelegate calculate_average_metrics(level_data), to: Metrics, as: :calculate_average
  defdelegate default_metrics(), to: Types

  # Story demo
  defdelegate generate_random_path(tree, random_fn \\ nil), to: StoryDemo
  defdelegate transition_text(risk_level), to: StoryDemo

  # Designer
  defdelegate validate_tree(tree), to: DesignerLogic
end
