defmodule BlogWeb.PhishLive do
  use BlogWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    years = Blog.Phish.list_years()

    {:ok,
     assign(socket,
       page_title: "phstats — Phish 3.0 Jamchart Analysis",
       page_description: "A site for dorking out with phish stats on jams. 3.0 only, just cuz I know that'll bother some of you. Doink around.",
       page_image: "https://www.bobbby.online/images/og-phish.png",
       years: years,
       year: "all",
       song_list: [],
       sorted_songs: [],
       selected_song: nil,
       song_history: nil,
       sort_by: "avg",
       min_played: 5,
       filter: "",
       card_flipped: false,
       list_filter: "jamcharts",
       expanded_idx: nil
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    year = params["year"] || "all"
    sort_by = params["sort"] || "avg"
    min_played = parse_int(params["min"], 5)
    filter = params["filter"] || ""

    song_list = Blog.Phish.song_list(year)

    socket =
      socket
      |> assign(year: year, sort_by: sort_by, min_played: min_played, filter: filter, song_list: song_list)
      |> assign_sorted_songs()

    selected_song = params["song"] || default_song(socket.assigns.sorted_songs)

    socket =
      socket
      |> assign(selected_song: selected_song)
      |> load_song_history()

    {:noreply, socket}
  end

  @impl true
  def handle_event("change-year", %{"year" => year}, socket) do
    {:noreply, push_params(socket, %{year: year, song: nil})}
  end

  def handle_event("change-song", %{"song" => song}, socket) do
    {:noreply, push_params(socket, %{song: song})}
  end

  def handle_event("change-sort", %{"sort" => sort}, socket) do
    {:noreply, push_params(socket, %{sort: sort})}
  end

  def handle_event("change-min", %{"min" => min_str}, socket) do
    min = parse_int(min_str, 5)
    {:noreply, push_params(socket, %{min: min})}
  end

  def handle_event("change-filter-text", %{"value" => filter}, socket) do
    socket =
      socket
      |> assign(filter: filter)
      |> assign_sorted_songs()

    {:noreply, socket}
  end

  def handle_event("flip-card", _params, socket) do
    {:noreply, assign(socket, card_flipped: !socket.assigns.card_flipped)}
  end

  def handle_event("change-list-filter", %{"filter" => filter}, socket) do
    {:noreply, assign(socket, list_filter: filter, expanded_idx: nil)}
  end

  def handle_event("toggle-notes", %{"idx" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    current = socket.assigns.expanded_idx
    {:noreply, assign(socket, expanded_idx: if(current == idx, do: nil, else: idx))}
  end

  def handle_event("play-jam", %{"url" => url, "date" => date, "song" => song}, socket) do
    {:noreply, push_event(socket, "play-jam", %{url: url, date: date, song: song})}
  end

  def handle_event("chart-mounted", _params, socket) do
    case socket.assigns.song_history do
      nil ->
        {:noreply, socket}

      history ->
        {:noreply,
         push_event(socket, "song-data", %{
           song_name: history.song_name,
           tracks: history.tracks
         })}
    end
  end

  # Helpers

  defp load_song_history(socket) do
    case socket.assigns.selected_song do
      nil ->
        assign(socket, song_history: nil)

      song ->
        history = Blog.Phish.song_history(song, socket.assigns.year)
        socket
        |> assign(song_history: history)
        |> push_event("song-data", %{
          song_name: history.song_name,
          tracks: history.tracks
        })
    end
  end

  defp assign_sorted_songs(socket) do
    %{song_list: song_list, sort_by: sort_by, min_played: min_played, filter: filter, selected_song: selected_song} =
      socket.assigns

    filtered =
      song_list
      |> Enum.filter(fn s ->
        s.times_played >= min_played || s.song_name == selected_song
      end)
      |> Enum.filter(fn s ->
        filter == "" ||
          String.contains?(String.downcase(s.song_name), String.downcase(filter)) ||
          s.song_name == selected_song
      end)

    sorted =
      Enum.sort_by(filtered, fn s ->
        case sort_by do
          "avg" -> {-batting_avg(s), -s.jamchart_count}
          "jc" -> {-s.jamchart_count, -batting_avg(s)}
          "played" -> {-s.times_played, 0}
          _ -> {-batting_avg(s), -s.jamchart_count}
        end
      end)

    assign(socket, sorted_songs: sorted)
  end

  defp default_song([first | _]), do: first.song_name
  defp default_song([]), do: nil

  defp push_params(socket, new_params) do
    current = %{
      year: socket.assigns.year,
      song: socket.assigns.selected_song,
      sort: socket.assigns.sort_by,
      min: socket.assigns.min_played
    }

    merged = Map.merge(current, new_params)

    # Only include non-default params
    query =
      []
      |> then(fn q -> if merged.year != "all", do: [{"year", merged.year} | q], else: q end)
      |> then(fn q -> if merged.song, do: [{"song", merged.song} | q], else: q end)
      |> then(fn q -> if merged.sort != "avg", do: [{"sort", merged.sort} | q], else: q end)
      |> then(fn q -> if merged.min != 5, do: [{"min", to_string(merged.min)} | q], else: q end)

    push_patch(socket, to: "/phish?" <> URI.encode_query(query))
  end

  # Template helpers

  def batting_avg(%{times_played: 0}), do: 0.0
  def batting_avg(%{jamchart_count: jc, times_played: tp}), do: jc / tp

  def fmt_avg(%{times_played: 0}), do: ".000"

  def fmt_avg(song) do
    avg = batting_avg(song)
    if avg >= 1.0, do: "1.000", else: "." <> String.pad_leading("#{round(avg * 1000)}", 3, "0")
  end

  def fmt_duration(ms) when is_nil(ms) or ms <= 0, do: "?"

  def fmt_duration(ms) do
    m = div(ms, 60000)
    s = div(rem(ms, 60000), 1000)
    "#{m}:#{String.pad_leading("#{s}", 2, "0")}"
  end

  defp parse_int(nil, default), do: default
  defp parse_int(str, default) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> default
    end
  end

  # Computed stats for mobile card
  def song_stats(nil), do: %{
    jc_count: 0, avg_dur: 0, longest_ms: 0, longest_track: nil,
    most_loved_track: nil, notable_quote: nil, total_hours: 0.0,
    recent_form: nil, dur_trend: nil, recent_avg_dur: 0, jc_streak: 0,
  }

  def song_stats(%{tracks: tracks}) do
    jc_count = Enum.count(tracks, fn t -> t.is_jamchart == 1 end)
    total_dur = Enum.reduce(tracks, 0, fn t, acc -> acc + (t.duration_ms || 0) end)
    avg_dur = if length(tracks) > 0, do: total_dur / length(tracks), else: 0
    longest = Enum.max_by(tracks, fn t -> t.duration_ms || 0 end, fn -> nil end)
    most_loved = Enum.max_by(tracks, fn t -> t.likes || 0 end, fn -> nil end)

    notable_quote =
      tracks
      |> Enum.filter(fn t -> t.is_jamchart == 1 and t.jam_notes != "" end)
      |> Enum.map(fn t -> t.jam_notes end)
      |> List.first()
      |> case do
        nil -> nil
        q -> if String.length(q) > 80, do: String.slice(q, 0, 80) <> "...", else: q
      end

    # Total jam time in hours
    total_hours = total_dur / 3_600_000

    # Recent form: last 5 tracks JC rate
    last5 = Enum.take(tracks, -5)
    last5_jc = Enum.count(last5, fn t -> t.is_jamchart == 1 end)
    recent_form = if length(last5) > 0, do: {last5_jc, length(last5)}, else: nil

    # Duration trend: compare last 5 avg to overall avg
    recent_avg_dur =
      if length(last5) > 0 do
        Enum.reduce(last5, 0, fn t, acc -> acc + (t.duration_ms || 0) end) / length(last5)
      else
        0
      end

    dur_trend =
      cond do
        avg_dur == 0 or length(tracks) < 6 -> nil
        recent_avg_dur > avg_dur * 1.1 -> :longer
        recent_avg_dur < avg_dur * 0.9 -> :shorter
        true -> :stable
      end

    # JC streak: consecutive jamcharts from most recent backwards
    jc_streak =
      tracks
      |> Enum.reverse()
      |> Enum.take_while(fn t -> t.is_jamchart == 1 end)
      |> length()

    %{
      jc_count: jc_count,
      avg_dur: avg_dur,
      longest_ms: if(longest, do: longest.duration_ms, else: 0),
      longest_track: longest,
      most_loved_track: most_loved,
      notable_quote: notable_quote,
      total_hours: total_hours,
      recent_form: recent_form,
      dur_trend: dur_trend,
      recent_avg_dur: recent_avg_dur,
      jc_streak: jc_streak
    }
  end

  def filtered_tracks(nil, _filter), do: []

  def filtered_tracks(%{tracks: tracks}, filter) do
    case filter do
      "jamcharts" -> Enum.filter(tracks, fn t -> t.is_jamchart == 1 end)
      _ -> tracks
    end
  end
end
