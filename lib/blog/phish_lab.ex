defmodule Blog.PhishLab do
  @moduledoc """
  Data access for /phish_lab — the Phish anomaly laboratory.

  Loads the precomputed datasets in priv/static/data/phish_lab.json
  (built by scripts/build_phish_lab_data.py) into :persistent_term.
  Shows and performances are indexed for the click-to-inspect panel;
  leaderboards are rendered server-side.
  """

  @styles ~w(Ambient Bliss CowFunk DanceGroove Dark-Evil Hose LoveAndLight
             MachineGunTrey OutOfTheBlue Psychedelic QuickHits Space
             StopStart TensionAndRelease Weird)

  # {key, label, format} — format: :date | :sec | :num | :sigma | :days | :score
  @show_metrics [
    {"d", "Show date", :date},
    {"dur", "Show length", :sec},
    {"nsongs", "Songs played", :num},
    {"nsets", "Sets", :num},
    {"avg_song", "Avg song length", :sec},
    {"max_song", "Longest song", :sec},
    {"rarity", "Setlist rarity index", :num},
    {"rating", "Fan rating (relisten)", :num},
    {"nrat", "# of ratings", :num},
    {"rating_z", "Rating vs year", :sigma},
    {"jam_z", "Jamminess vs era", :sigma},
    {"uniq", "Anomaly score", :num},
    {"jc_ct", "Jamchart entries", :num},
    {"likes", "Track likes (total)", :num},
    {"njams", "PJJ jams", :num}
  ]

  @song_metrics [
    {"plays", "Times played", :num},
    {"first", "First played", :date},
    {"last", "Last played", :date},
    {"avg", "Avg duration", :sec},
    {"med", "Median duration", :sec},
    {"max", "Longest version", :sec},
    {"sd", "Duration std dev", :sec},
    {"cv", "Unpredictability (CV)", :num},
    {"maxgap", "Longest shelf gap", :days},
    {"jc_ct", "Jamchart entries", :num},
    {"jc_rate", "Jamchart rate", :num},
    {"likes_avg", "Avg likes", :num},
    {"njams", "PJJ jams", :num}
  ]

  @perf_metrics [
    {"d", "Show date", :date},
    {"dur", "Duration", :sec},
    {"z", "Length vs song avg", :sigma},
    {"pct", "× song average", :num},
    {"gap", "Days since last played", :days},
    {"pos", "Setlist position", :num},
    {"likes", "Likes", :num}
  ]

  def styles, do: @styles

  def metrics("shows"), do: @show_metrics ++ style_metrics("(show max)")
  def metrics("songs"), do: @song_metrics ++ style_metrics("(song avg)")
  def metrics("perfs"), do: @perf_metrics

  defp style_metrics(suffix) do
    Enum.map(@styles, fn s -> {"style:" <> s, "#{s} #{suffix}", :score} end)
  end

  def datasets, do: [{"shows", "Shows"}, {"songs", "Songs"}, {"perfs", "Performances"}]

  def meta, do: data().meta
  def leaderboards, do: data().leaderboards
  def leaderboard_order do
    ~w(perfs_outliers shows_jammiest shows_rarest songs_bustouts songs_variable
       shows_overachievers shows_most_unique songs_jam_vehicles perfs_longest
       shows_longest style_definers)
  end

  def find_show(date), do: Map.get(data().shows_by_date, date)
  def find_song(name), do: Map.get(data().songs_by_name, name)
  def find_perf(i) when is_integer(i), do: Enum.at(data().perfs, i)
  def find_perf(_), do: nil

  # ---------------------------------------------------------------- formatting

  def fmt_sec(nil), do: "—"
  def fmt_sec(s) when is_number(s) do
    s = round(s)
    "#{div(s, 60)}:#{String.pad_leading(to_string(rem(s, 60)), 2, "0")}"
  end

  def fmt_days(nil), do: "—"
  def fmt_days(d) when d >= 365, do: "#{Float.round(d / 365, 1)}y"
  def fmt_days(d), do: "#{d}d"

  def fmt_val(nil, _), do: "—"
  def fmt_val(v, :sec), do: fmt_sec(v)
  def fmt_val(v, :days), do: fmt_days(v)
  def fmt_val(v, :sigma), do: "#{v}σ"
  def fmt_val(v, _), do: to_string(v)

  # ------------------------------------------------------------------- loading

  defp data do
    case :persistent_term.get({__MODULE__, :data}, nil) do
      nil ->
        d = load()
        :persistent_term.put({__MODULE__, :data}, d)
        d

      d ->
        d
    end
  end

  defp load do
    main = read_json("phish_lab.json")
    perfs = read_json("phish_lab_perfs.json")["perfs"] || []

    %{
      meta: main["meta"] || %{},
      leaderboards: main["leaderboards"] || %{},
      shows_by_date: Map.new(main["shows"] || [], fn s -> {s["d"], s} end),
      songs_by_name: Map.new(main["songs"] || [], fn s -> {s["s"], s} end),
      perfs: perfs
    }
  end

  defp read_json(name) do
    path = Path.join([:code.priv_dir(:blog), "static", "data", name])

    case File.read(path) do
      {:ok, body} -> Jason.decode!(body)
      _ -> %{}
    end
  end
end
