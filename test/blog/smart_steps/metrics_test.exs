defmodule Blog.SmartSteps.MetricsTest do
  use ExUnit.Case, async: true

  alias Blog.SmartSteps.Metrics, as: MetricsModule
  alias Blog.SmartSteps.Types.{Metrics, LevelData}

  # ============================================
  # Fixtures
  # ============================================

  defp make_metrics(overrides \\ %{}) do
    Map.merge(%Metrics{}, overrides)
  end

  defp make_level_data(metrics, level \\ 1) do
    %LevelData{
      level: level,
      scenario_id: "scenario-#{level}",
      scenario_title: "Scenario #{level}",
      selected_choice_id: "choice-1",
      selected_choice_text: "Some choice",
      risk_level: :low,
      notes: "",
      metrics: metrics,
      timestamp: DateTime.utc_now()
    }
  end

  # ============================================
  # default_metrics/0
  # ============================================

  describe "default_metrics/0" do
    test "returns a Metrics struct with all values at 5" do
      m = MetricsModule.default_metrics()
      assert %Metrics{} = m
      assert m.self_awareness == 5
      assert m.self_management == 5
      assert m.social_awareness == 5
      assert m.relationship_skills == 5
      assert m.decision_making == 5
      assert m.self_advocacy == 5
    end
  end

  # ============================================
  # calculate_average/1
  # ============================================

  describe "calculate_average/1" do
    test "returns defaults for empty list" do
      result = MetricsModule.calculate_average([])
      default = MetricsModule.default_metrics()
      assert result == default
    end

    test "returns the same values for a single entry" do
      metrics = make_metrics(%{self_awareness: 8, self_advocacy: 3})
      result = MetricsModule.calculate_average([make_level_data(metrics)])
      assert result.self_awareness == 8.0
      assert result.self_advocacy == 3.0
    end

    test "computes correct averages for multiple entries" do
      m1 = make_metrics(%{self_awareness: 4, decision_making: 8})
      m2 = make_metrics(%{self_awareness: 6, decision_making: 6})
      result = MetricsModule.calculate_average([
        make_level_data(m1, 1),
        make_level_data(m2, 2)
      ])
      assert result.self_awareness == 5.0
      assert result.decision_making == 7.0
    end

    test "rounds to 1 decimal place" do
      m1 = make_metrics(%{self_awareness: 3})
      m2 = make_metrics(%{self_awareness: 7})
      m3 = make_metrics(%{self_awareness: 4})
      result = MetricsModule.calculate_average([
        make_level_data(m1, 1),
        make_level_data(m2, 2),
        make_level_data(m3, 3)
      ])
      # (3 + 7 + 4) / 3 = 4.666... -> 4.7
      assert_in_delta result.self_awareness, 4.7, 0.01
    end

    test "averages all 6 metrics correctly" do
      m1 = %Metrics{
        self_awareness: 2,
        self_management: 4,
        social_awareness: 6,
        relationship_skills: 8,
        decision_making: 10,
        self_advocacy: 1
      }
      m2 = %Metrics{
        self_awareness: 8,
        self_management: 6,
        social_awareness: 4,
        relationship_skills: 2,
        decision_making: 0,
        self_advocacy: 9
      }
      result = MetricsModule.calculate_average([
        make_level_data(m1, 1),
        make_level_data(m2, 2)
      ])
      assert result.self_awareness == 5.0
      assert result.self_management == 5.0
      assert result.social_awareness == 5.0
      assert result.relationship_skills == 5.0
      assert result.decision_making == 5.0
      assert result.self_advocacy == 5.0
    end

    test "does not mutate input list" do
      data = [make_level_data(make_metrics(), 1)]
      original = Enum.map(data, & &1)
      MetricsModule.calculate_average(data)
      assert data == original
    end

    test "handles high values correctly" do
      m1 = make_metrics(%{self_awareness: 10})
      m2 = make_metrics(%{self_awareness: 10})
      result = MetricsModule.calculate_average([
        make_level_data(m1, 1),
        make_level_data(m2, 2)
      ])
      assert result.self_awareness == 10.0
    end

    test "handles zero values correctly" do
      m1 = make_metrics(%{self_advocacy: 0})
      m2 = make_metrics(%{self_advocacy: 0})
      result = MetricsModule.calculate_average([
        make_level_data(m1, 1),
        make_level_data(m2, 2)
      ])
      assert result.self_advocacy == 0.0
    end

    test "handles three entries with uneven division" do
      m1 = make_metrics(%{relationship_skills: 1})
      m2 = make_metrics(%{relationship_skills: 2})
      m3 = make_metrics(%{relationship_skills: 3})
      result = MetricsModule.calculate_average([
        make_level_data(m1, 1),
        make_level_data(m2, 2),
        make_level_data(m3, 3)
      ])
      assert result.relationship_skills == 2.0
    end

    test "preserves non-overridden defaults in average" do
      # self_management defaults to 5 in both entries
      m1 = make_metrics(%{self_awareness: 10})
      m2 = make_metrics(%{self_awareness: 0})
      result = MetricsModule.calculate_average([
        make_level_data(m1, 1),
        make_level_data(m2, 2)
      ])
      assert result.self_management == 5.0
      assert result.self_awareness == 5.0
    end
  end
end
