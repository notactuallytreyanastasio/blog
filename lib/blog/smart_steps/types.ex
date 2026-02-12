defmodule Blog.SmartSteps.Types do
  @moduledoc """
  Core types for the Smart Steps scenario system.
  """

  # ============================================
  # Structs
  # ============================================

  defmodule Choice do
    @moduledoc false
    @enforce_keys [:id, :text, :next_scenario_id, :risk_level]
    defstruct [:id, :text, :next_scenario_id, :risk_level, :consequence_hint]

    @type t :: %__MODULE__{
            id: String.t(),
            text: String.t(),
            next_scenario_id: String.t(),
            risk_level: Blog.SmartSteps.Types.risk_level(),
            consequence_hint: String.t() | nil
          }
  end

  defmodule Scenario do
    @moduledoc false
    @enforce_keys [:id, :tree_id, :location, :location_category, :theme, :level, :title, :description, :choices, :image_color]
    defstruct [
      :id, :tree_id, :location, :location_category, :theme, :level,
      :title, :description, :choices, :image_color,
      is_game_over: false,
      outcome_type: nil,
      discussion_prompt: nil,
      learning_points: nil
    ]

    @type t :: %__MODULE__{
            id: String.t(),
            tree_id: String.t(),
            location: String.t(),
            location_category: Blog.SmartSteps.Types.location_category(),
            theme: Blog.SmartSteps.Types.scenario_theme(),
            level: non_neg_integer(),
            title: String.t(),
            description: String.t(),
            choices: [Blog.SmartSteps.Types.Choice.t()],
            image_color: String.t(),
            is_game_over: boolean(),
            outcome_type: Blog.SmartSteps.Types.outcome_type() | nil,
            discussion_prompt: String.t() | nil,
            learning_points: [String.t()] | nil
          }
  end

  defmodule ScenarioTree do
    @moduledoc false
    @enforce_keys [:id, :title, :description, :theme, :age_range, :estimated_minutes, :start_scenario_id, :scenarios]
    defstruct [:id, :title, :description, :theme, :age_range, :estimated_minutes, :start_scenario_id, :scenarios]

    @type t :: %__MODULE__{
            id: String.t(),
            title: String.t(),
            description: String.t(),
            theme: Blog.SmartSteps.Types.scenario_theme(),
            age_range: String.t(),
            estimated_minutes: pos_integer(),
            start_scenario_id: String.t(),
            scenarios: %{String.t() => Blog.SmartSteps.Types.Scenario.t()}
          }
  end

  defmodule Metrics do
    @moduledoc false
    defstruct self_awareness: 5, self_management: 5, social_awareness: 5,
              relationship_skills: 5, decision_making: 5, self_advocacy: 5

    @type t :: %__MODULE__{
            self_awareness: number(),
            self_management: number(),
            social_awareness: number(),
            relationship_skills: number(),
            decision_making: number(),
            self_advocacy: number()
          }
  end

  defmodule LevelData do
    @moduledoc false
    @enforce_keys [:level, :scenario_id, :scenario_title, :selected_choice_id, :selected_choice_text, :risk_level, :notes, :metrics]
    defstruct [:level, :scenario_id, :scenario_title, :selected_choice_id,
               :selected_choice_text, :risk_level, :notes, :metrics, :timestamp]

    @type t :: %__MODULE__{
            level: pos_integer(),
            scenario_id: String.t(),
            scenario_title: String.t(),
            selected_choice_id: String.t(),
            selected_choice_text: String.t(),
            risk_level: Blog.SmartSteps.Types.risk_level(),
            notes: String.t(),
            metrics: Blog.SmartSteps.Types.Metrics.t(),
            timestamp: DateTime.t() | nil
          }
  end

  defmodule Message do
    @moduledoc false
    @enforce_keys [:id, :type, :content]
    defstruct [:id, :type, :content, :timestamp]

    @type t :: %__MODULE__{
            id: String.t(),
            type: Blog.SmartSteps.Types.message_type(),
            content: String.t(),
            timestamp: DateTime.t() | nil
          }
  end

  defmodule GameState do
    @moduledoc false
    defstruct role: nil,
              phase: :menu,
              session_id: "",
              current_tree_id: "",
              current_scenario_id: "start",
              current_level: 1,
              max_levels: 10,
              selected_choice_index: -1,
              history: [],
              level_data: [],
              messages: [],
              is_game_over: false,
              game_over_reason: nil

    @type t :: %__MODULE__{
            role: Blog.SmartSteps.Types.scenario_role(),
            phase: Blog.SmartSteps.Types.game_phase(),
            session_id: String.t(),
            current_tree_id: String.t(),
            current_scenario_id: String.t(),
            current_level: pos_integer(),
            max_levels: pos_integer(),
            selected_choice_index: integer(),
            history: [String.t()],
            level_data: [Blog.SmartSteps.Types.LevelData.t()],
            messages: [Blog.SmartSteps.Types.Message.t()],
            is_game_over: boolean(),
            game_over_reason: String.t() | nil
          }
  end

  # ============================================
  # Type definitions
  # ============================================

  @type scenario_role :: :facilitator | :participant | nil
  @type risk_level :: :low | :medium | :high | :critical
  @type outcome_type :: :positive | :neutral | :negative | :severe
  @type game_phase :: :menu | :dashboard | :connect | :game | :discussion | :results
  @type message_type :: :system | :user | :facilitator

  @type location_category ::
          :start | :home | :classroom | :hallway | :cafeteria | :playground |
          :gym | :library | :school_bus | :store | :park | :friends_house |
          :birthday_party | :doctors_office | :car

  @type scenario_theme ::
          :sensory_overload | :routine_change | :social_misunderstanding |
          :friendship | :bullying | :self_advocacy | :emotional_regulation |
          :transitions | :group_participation | :conflict_resolution

  # ============================================
  # Constants
  # ============================================

  @metric_labels %{
    self_awareness: "Self-awareness",
    self_management: "Self-management",
    social_awareness: "Social awareness",
    relationship_skills: "Relationship skills",
    decision_making: "Responsible decision making",
    self_advocacy: "Self-advocacy"
  }

  def metric_labels, do: @metric_labels
  def default_metrics, do: %Metrics{}

  # ============================================
  # Utility Functions
  # ============================================

  @doc "Create a new message with a random UUID and current timestamp."
  def create_message(type, content) when type in [:system, :user, :facilitator] do
    %Message{
      id: Ecto.UUID.generate(),
      type: type,
      content: content,
      timestamp: DateTime.utc_now()
    }
  end

  @doc "Generate a random 6-digit session ID."
  def generate_session_id do
    (100_000 + :rand.uniform(900_000) - 1)
    |> Integer.to_string()
  end
end
