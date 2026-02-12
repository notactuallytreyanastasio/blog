defmodule Blog.SmartSteps.Metrics do
  @moduledoc """
  Pure functions for calculating SEL metrics.
  """

  alias Blog.SmartSteps.Types.{Metrics, LevelData}

  @metric_keys [:self_awareness, :self_management, :social_awareness,
                :relationship_skills, :decision_making, :self_advocacy]

  @doc "Return default metrics struct."
  def default_metrics, do: %Metrics{}

  @doc """
  Calculate the average of each metric across a list of LevelData entries.
  Returns default metrics for an empty list.
  Rounds to 1 decimal place.
  """
  def calculate_average([]), do: %Metrics{}

  def calculate_average(level_data) when is_list(level_data) do
    count = length(level_data)

    totals =
      Enum.reduce(level_data, %Metrics{
        self_awareness: 0, self_management: 0, social_awareness: 0,
        relationship_skills: 0, decision_making: 0, self_advocacy: 0
      }, fn %LevelData{metrics: m}, acc ->
        %Metrics{
          self_awareness: acc.self_awareness + m.self_awareness,
          self_management: acc.self_management + m.self_management,
          social_awareness: acc.social_awareness + m.social_awareness,
          relationship_skills: acc.relationship_skills + m.relationship_skills,
          decision_making: acc.decision_making + m.decision_making,
          self_advocacy: acc.self_advocacy + m.self_advocacy
        }
      end)

    @metric_keys
    |> Enum.reduce(%Metrics{}, fn key, acc ->
      raw = Map.get(totals, key) / count
      rounded = Float.round(raw * 1.0, 1)
      Map.put(acc, key, rounded)
    end)
  end
end
