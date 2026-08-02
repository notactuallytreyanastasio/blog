defmodule Blog.PhishLabTest do
  use ExUnit.Case, async: true

  alias Blog.PhishLab

  describe "metrics/1" do
    test "each dataset exposes its base metrics" do
      assert {"d", "Show date", :date} in PhishLab.metrics("shows")
      assert {"plays", "Times played", :num} in PhishLab.metrics("songs")
      assert {"z", "Length vs song avg", :sigma} in PhishLab.metrics("perfs")
    end

    test "shows and songs carry the 15 PJJ style metrics, perfs do not" do
      style_keys = fn ds ->
        PhishLab.metrics(ds)
        |> Enum.filter(fn {k, _, _} -> String.starts_with?(k, "style:") end)
      end

      assert length(style_keys.("shows")) == 15
      assert length(style_keys.("songs")) == 15
      assert style_keys.("perfs") == []
    end
  end

  describe "formatting" do
    test "fmt_sec renders m:ss" do
      assert PhishLab.fmt_sec(442) == "7:22"
      assert PhishLab.fmt_sec(60) == "1:00"
      assert PhishLab.fmt_sec(nil) == "—"
    end

    test "fmt_days uses years past 365 days" do
      assert PhishLab.fmt_days(30) == "30d"
      assert PhishLab.fmt_days(9399) == "25.8y"
      assert PhishLab.fmt_days(nil) == "—"
    end

    test "fmt_val dispatches on format" do
      assert PhishLab.fmt_val(90, :sec) == "1:30"
      assert PhishLab.fmt_val(4.2, :sigma) == "4.2σ"
      assert PhishLab.fmt_val(nil, :num) == "—"
      assert PhishLab.fmt_val(17, :num) == "17"
    end
  end

  describe "data loading (real priv/static/data files)" do
    test "meta has corpus counts" do
      meta = PhishLab.meta()
      assert meta["n_shows"] > 1000
      assert meta["n_perfs"] > 20_000
      assert meta["date_min"] =~ ~r/^\d{4}-\d{2}-\d{2}$/
    end

    test "leaderboard_order only names boards that exist" do
      lbs = PhishLab.leaderboards()

      for key <- PhishLab.leaderboard_order() do
        assert Map.has_key?(lbs, key), "missing leaderboard #{key}"
        assert is_list(lbs[key]["entries"])
        assert lbs[key]["entries"] != []
      end
    end

    test "find_show returns a full record for a known date" do
      show = PhishLab.find_show("1997-11-17")
      assert show["venue"] =~ "McNichols"
      assert is_number(show["rating"])
      assert show["era"] == "1.0"
    end

    test "find_song and find_perf look up by key" do
      song = PhishLab.find_song("Tweezer")
      assert song["plays"] > 100

      perf = PhishLab.find_perf(0)
      assert is_binary(perf["s"])
      assert PhishLab.find_perf(nil) == nil
    end
  end
end
