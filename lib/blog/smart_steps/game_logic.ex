defmodule Blog.SmartSteps.GameLogic do
  @moduledoc """
  Pure game logic functions for the Smart Steps scenario system.
  No side effects — takes data in, returns data out.
  """

  alias Blog.SmartSteps.Types.{GameState, LevelData, Metrics, Message, Choice, Scenario}

  @doc "Create a fresh initial game state."
  @spec create_initial_state() :: GameState.t()
  def create_initial_state do
    %GameState{}
  end

  @doc "Build a LevelData record for one round of play."
  @spec build_level_data(integer(), String.t(), String.t(), Choice.t(), String.t(), Metrics.t()) ::
          LevelData.t()
  def build_level_data(level, scenario_id, scenario_title, %Choice{} = choice, notes, %Metrics{} = metrics) do
    %LevelData{
      level: level,
      scenario_id: scenario_id,
      scenario_title: scenario_title,
      selected_choice_id: choice.id,
      selected_choice_text: choice.text,
      risk_level: choice.risk_level,
      notes: notes,
      metrics: metrics,
      timestamp: DateTime.utc_now()
    }
  end

  @doc "Check if the game should end."
  @spec game_over?(String.t(), Scenario.t() | nil, integer(), integer()) :: boolean()
  def game_over?(next_scenario_id, next_scenario, current_level, max_levels) do
    next_scenario_id == "GAME_OVER" ||
      (next_scenario != nil && next_scenario.is_game_over == true) ||
      current_level >= max_levels ||
      next_scenario == nil
  end

  @doc """
  Process a choice selection and return the result.
  `get_next_scenario` is a function that looks up a scenario by ID.
  Returns `{:ok, result}` or `{:error, reason}`.
  """
  @spec process_choice(
          GameState.t(),
          Scenario.t(),
          integer(),
          String.t(),
          Metrics.t(),
          (String.t() -> Scenario.t() | nil)
        ) ::
          {:ok,
           %{
             level_data: LevelData.t(),
             is_game_over: boolean(),
             next_scenario_id: String.t(),
             game_over_reason: String.t() | nil,
             messages: [Message.t()]
           }}
          | {:error, String.t()}
  def process_choice(%GameState{} = state, %Scenario{} = scenario, choice_index, notes, %Metrics{} = metrics, get_next_scenario)
      when is_integer(choice_index) and is_function(get_next_scenario, 1) do
    case Enum.at(scenario.choices, choice_index) do
      nil ->
        {:error, "Invalid choice index: #{choice_index}"}

      choice ->
        next_scenario_id = choice.next_scenario_id

        next_scenario =
          if next_scenario_id != "GAME_OVER",
            do: get_next_scenario.(next_scenario_id),
            else: nil

        level_data = build_level_data(
          state.current_level,
          state.current_scenario_id,
          scenario.title,
          choice,
          notes,
          metrics
        )

        is_game_over = game_over?(next_scenario_id, next_scenario, state.current_level, state.max_levels)

        messages =
          cond do
            is_game_over ->
              [%Message{id: Ecto.UUID.generate(), type: :system, content: "Session complete.", timestamp: DateTime.utc_now()}]

            next_scenario != nil ->
              [%Message{
                id: Ecto.UUID.generate(),
                type: :system,
                content: "Moved to Level #{state.current_level + 1}: #{next_scenario.title}",
                timestamp: DateTime.utc_now()
              }]

            true ->
              []
          end

        game_over_reason =
          cond do
            !is_game_over -> nil
            next_scenario != nil && next_scenario.is_game_over -> next_scenario.title
            true -> "Max levels reached"
          end

        {:ok, %{
          level_data: level_data,
          is_game_over: is_game_over,
          next_scenario_id: next_scenario_id,
          game_over_reason: game_over_reason,
          messages: messages
        }}
    end
  end

  @doc "Generate a random 6-digit session ID."
  @spec generate_session_id() :: String.t()
  def generate_session_id do
    (100_000 + :rand.uniform(900_000) - 1)
    |> Integer.to_string()
  end
end
