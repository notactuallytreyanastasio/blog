defmodule Blog.SmartSteps.SessionServer do
  @moduledoc """
  GenServer that holds the authoritative game state for one active session.
  One SessionServer per active session, registered via Registry.
  """

  use GenServer

  alias Blog.SmartSteps.{GameLogic, Trees, Types}
  alias Blog.SmartSteps.Types.{GameState, Metrics}

  # ============================================
  # Client API
  # ============================================

  def start_link({session_id, tree_id, role}) do
    GenServer.start_link(__MODULE__, {session_id, tree_id, role}, name: via(session_id))
  end

  def get_state(session_id) do
    GenServer.call(via(session_id), :get_state)
  end

  def select_choice(session_id, index) do
    GenServer.call(via(session_id), {:select_choice, index})
  end

  def continue_to_discussion(session_id) do
    GenServer.call(via(session_id), :continue_to_discussion)
  end

  def proceed_from_discussion(session_id, notes, %Metrics{} = metrics) do
    GenServer.call(via(session_id), {:proceed_from_discussion, notes, metrics})
  end

  def session_exists?(session_id) do
    case Registry.lookup(Blog.SmartSteps.SessionRegistry, session_id) do
      [{_pid, _}] -> true
      [] -> false
    end
  end

  # ============================================
  # Server Callbacks
  # ============================================

  @impl true
  def init({session_id, tree_id, role}) do
    tree = Trees.get_tree(tree_id)

    if tree do
      game_state = %GameState{
        role: role,
        phase: :game,
        session_id: session_id,
        current_tree_id: tree_id,
        current_scenario_id: tree.start_scenario_id,
        current_level: 1,
        selected_choice_index: -1,
        history: [tree.start_scenario_id],
        level_data: [],
        messages: [Types.create_message(:system, "Session #{session_id} started with \"#{tree.title}\".")],
        is_game_over: false
      }

      {:ok, %{game_state: game_state, tree: tree}}
    else
      {:stop, :tree_not_found}
    end
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state.game_state, state}
  end

  @impl true
  def handle_call({:select_choice, index}, _from, state) do
    game_state = %{state.game_state | selected_choice_index: index}
    new_state = %{state | game_state: game_state}
    broadcast(game_state.session_id, {:state_update, game_state})
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_call(:continue_to_discussion, _from, state) do
    gs = state.game_state
    scenario = Map.get(state.tree.scenarios, gs.current_scenario_id)

    if scenario && gs.selected_choice_index >= 0 do
      choice = Enum.at(scenario.choices, gs.selected_choice_index)
      msg = Types.create_message(:system, "Selected: \"#{choice.text}\"")

      game_state = %{gs |
        messages: gs.messages ++ [msg],
        phase: :discussion
      }

      new_state = %{state | game_state: game_state}
      broadcast(game_state.session_id, {:state_update, game_state})
      {:reply, :ok, new_state}
    else
      {:reply, {:error, :invalid_state}, state}
    end
  end

  @impl true
  def handle_call({:proceed_from_discussion, notes, metrics}, _from, state) do
    gs = state.game_state
    scenario = Map.get(state.tree.scenarios, gs.current_scenario_id)

    if scenario do
      get_next = fn id -> Map.get(state.tree.scenarios, id) end

      case GameLogic.process_choice(gs, scenario, gs.selected_choice_index, notes, metrics, get_next) do
        {:ok, result} ->
          game_state =
            if result.is_game_over do
              %{gs |
                level_data: gs.level_data ++ [result.level_data],
                is_game_over: true,
                game_over_reason: result.game_over_reason,
                phase: :results,
                messages: gs.messages ++ result.messages
              }
            else
              %{gs |
                current_scenario_id: result.next_scenario_id,
                current_level: gs.current_level + 1,
                selected_choice_index: -1,
                history: gs.history ++ [result.next_scenario_id],
                level_data: gs.level_data ++ [result.level_data],
                phase: :game,
                messages: gs.messages ++ result.messages
              }
            end

          new_state = %{state | game_state: game_state}
          broadcast(game_state.session_id, {:state_update, game_state})
          {:reply, {:ok, game_state}, new_state}

        {:error, reason} ->
          {:reply, {:error, reason}, state}
      end
    else
      {:reply, {:error, :scenario_not_found}, state}
    end
  end

  # ============================================
  # Helpers
  # ============================================

  defp via(session_id) do
    {:via, Registry, {Blog.SmartSteps.SessionRegistry, session_id}}
  end

  defp broadcast(session_id, message) do
    Phoenix.PubSub.broadcast(Blog.PubSub, "smart_steps:#{session_id}", message)
  end
end
