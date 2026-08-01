defmodule BlogWeb.MoonPhishLive.PureFunctionTest do
  @moduledoc """
  Unit tests for the filtering/grouping helpers in MoonPhishLive.
  These tests require no database or LiveView connection.
  """
  use ExUnit.Case, async: true

  alias BlogWeb.MoonPhishLive

  defp show(date, opts \\ []) do
    %{
      date: date,
      venue: Keyword.get(opts, :venue, "Some Venue"),
      location: Keyword.get(opts, :location, "Burlington, VT"),
      tour_name: Keyword.get(opts, :tour_name, ""),
      moon: %{
        age: 14.7,
        illumination: Keyword.get(opts, :illumination, 1.0),
        phase_name: Keyword.get(opts, :phase_name, "Full Moon"),
        emoji: "🌕",
        full_moon?: Keyword.get(opts, :full_moon?, false),
        days_from_full: Keyword.get(opts, :days_from_full, 0.0)
      }
    }
  end

  defp assigns(shows, opts) do
    %{
      shows: shows,
      view: Keyword.get(opts, :view, "all"),
      era: Keyword.get(opts, :era, "all"),
      phase: Keyword.get(opts, :phase),
      q: Keyword.get(opts, :q, "")
    }
  end

  describe "filtered_shows/1" do
    test "full view keeps only full-moon shows" do
      shows = [
        show(~D[1997-11-22], full_moon?: true),
        show(~D[1997-11-23], full_moon?: false, phase_name: "Waning Gibbous")
      ]

      assert [%{date: ~D[1997-11-22]}] =
               MoonPhishLive.filtered_shows(assigns(shows, view: "full"))
    end

    test "era filter uses Phish era year ranges" do
      shows = [
        show(~D[1994-06-01]),
        show(~D[2003-02-01]),
        show(~D[2015-08-01]),
        show(~D[2023-08-01])
      ]

      assert [%{date: ~D[1994-06-01]}] =
               MoonPhishLive.filtered_shows(assigns(shows, era: "1.0"))

      assert [%{date: ~D[2003-02-01]}] =
               MoonPhishLive.filtered_shows(assigns(shows, era: "2.0"))

      assert [%{date: ~D[2015-08-01]}] =
               MoonPhishLive.filtered_shows(assigns(shows, era: "3.0"))

      assert [%{date: ~D[2023-08-01]}] =
               MoonPhishLive.filtered_shows(assigns(shows, era: "4.0"))
    end

    test "search matches venue, location, and tour case-insensitively" do
      shows = [
        show(~D[1995-12-31], venue: "Madison Square Garden", location: "New York, NY"),
        show(~D[1996-08-16], venue: "The Clifford Ball", tour_name: "Summer Tour 1996")
      ]

      assert [%{venue: "Madison Square Garden"}] =
               MoonPhishLive.filtered_shows(assigns(shows, q: "madison"))

      assert [%{venue: "The Clifford Ball"}] =
               MoonPhishLive.filtered_shows(assigns(shows, q: "SUMMER"))

      assert [] = MoonPhishLive.filtered_shows(assigns(shows, q: "gamehendge"))
    end

    test "phase filter selects by phase name" do
      shows = [
        show(~D[1999-12-31], phase_name: "Waning Crescent"),
        show(~D[2000-01-01], phase_name: "New Moon")
      ]

      assert [%{date: ~D[2000-01-01]}] =
               MoonPhishLive.filtered_shows(assigns(shows, phase: "New Moon"))
    end
  end

  describe "group_by_year/1" do
    test "groups newest year first, shows descending within year" do
      shows = [
        show(~D[1997-11-22]),
        show(~D[1997-12-31]),
        show(~D[2023-08-01])
      ]

      assert [{2023, [_]}, {1997, [%{date: ~D[1997-12-31]}, %{date: ~D[1997-11-22]}]}] =
               MoonPhishLive.group_by_year(shows)
    end
  end

  describe "near_full_label/1" do
    test "labels nights within a day and a half of full" do
      assert MoonPhishLive.near_full_label(%{full_moon?: false, days_from_full: -1.0}) ==
               "1d before full"

      assert MoonPhishLive.near_full_label(%{full_moon?: false, days_from_full: 1.4}) ==
               "1d after full"
    end

    test "is nil on the full moon itself and far from it" do
      assert MoonPhishLive.near_full_label(%{full_moon?: true}) == nil
      assert MoonPhishLive.near_full_label(%{full_moon?: false, days_from_full: 6.0}) == nil
    end
  end
end
