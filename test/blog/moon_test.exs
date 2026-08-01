defmodule Blog.MoonTest do
  use ExUnit.Case, async: true

  alias Blog.Moon

  # Reference instants from published almanac data (UTC). The computation
  # ignores ΔT (~1 minute in this era), so allow a small tolerance.
  @tolerance_seconds 180

  test "full moon instants match almanac values" do
    fulls = Moon.full_moons(2023, 2024)

    for expected <- [~U[2023-08-01 18:31:00Z], ~U[2023-08-31 01:35:00Z], ~U[2024-04-23 23:49:00Z]] do
      closest = Enum.min_by(fulls, &abs(DateTime.diff(&1, expected)))
      assert abs(DateTime.diff(closest, expected)) <= @tolerance_seconds
    end
  end

  test "new moon instant matches the 2024 total solar eclipse" do
    news = Moon.new_moons(2024, 2024)
    expected = ~U[2024-04-08 18:21:00Z]
    closest = Enum.min_by(news, &abs(DateTime.diff(&1, expected)))
    assert abs(DateTime.diff(closest, expected)) <= @tolerance_seconds
  end

  test "every year has 12 or 13 full moons" do
    counts =
      Moon.full_moons(1983, 2026)
      |> Enum.group_by(& &1.year)
      |> Map.new(fn {year, list} -> {year, length(list)} end)

    assert map_size(counts) == 44
    assert Enum.all?(counts, fn {_year, n} -> n in [12, 13] end)
  end

  test "phase_info flags full moon dates and stays consistent with buckets" do
    news = Moon.new_moons(2023, 2024)
    fulls = Moon.full_moons(2023, 2024)

    full_day = Moon.phase_info(~D[2023-08-01], news, fulls)
    assert full_day.full_moon?
    assert full_day.phase_name == "Full Moon"
    assert full_day.illumination > 0.95

    day_before = Moon.phase_info(~D[2023-07-31], news, fulls)
    refute day_before.full_moon?
    refute day_before.phase_name == "Full Moon"
    assert day_before.days_from_full < 0

    new_day = Moon.phase_info(~D[2023-08-16], news, fulls)
    refute new_day.full_moon?
    assert new_day.illumination < 0.05
  end
end
