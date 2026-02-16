defmodule BlogWeb.PhishComponent do
  use BlogWeb, :live_component
  require Logger

  import BlogWeb.PhishLive, only: [batting_avg: 1, fmt_avg: 1, fmt_duration: 1, song_stats: 1, filtered_tracks: 2]

  @impl true
  def mount(socket) do
    years = Blog.Phish.list_years()
    song_list = Blog.Phish.song_list("all")

    socket =
      assign(socket,
        years: years,
        year: "all",
        song_list: song_list,
        sorted_songs: [],
        selected_song: nil,
        song_history: nil,
        sort_by: "avg",
        min_played: 5,
        filter: "",
        card_flipped: false,
        list_filter: "jamcharts",
        expanded_idx: nil
      )
      |> assign_sorted_songs()

    selected = default_song(socket.assigns.sorted_songs)

    socket =
      socket
      |> assign(selected_song: selected)
      |> load_song_history()

    {:ok, socket}
  end

  @impl true
  def handle_event("change-year", %{"year" => year}, socket) do
    song_list = Blog.Phish.song_list(year)

    socket =
      socket
      |> assign(year: year, song_list: song_list)
      |> assign_sorted_songs()

    selected = default_song(socket.assigns.sorted_songs)

    socket =
      socket
      |> assign(selected_song: selected)
      |> load_song_history()

    {:noreply, socket}
  end

  def handle_event("change-song", %{"song" => song}, socket) do
    Logger.error("PhishComponent change-song: #{song}")

    socket =
      socket
      |> assign(selected_song: song, card_flipped: false, expanded_idx: nil)
      |> load_song_history()

    Logger.error("PhishComponent song_history loaded: #{socket.assigns.song_history.song_name}")
    {:noreply, socket}
  end

  def handle_event("change-sort", %{"sort" => sort}, socket) do
    socket =
      socket
      |> assign(sort_by: sort)
      |> assign_sorted_songs()

    {:noreply, socket}
  end

  def handle_event("change-min", %{"min" => min_str}, socket) do
    min = parse_int(min_str, 5)

    socket =
      socket
      |> assign(min_played: min)
      |> assign_sorted_songs()

    {:noreply, socket}
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


  # Helpers

  defp load_song_history(socket) do
    case socket.assigns.selected_song do
      nil ->
        assign(socket, song_history: nil)

      song ->
        history = Blog.Phish.song_history(song, socket.assigns.year)
        assign(socket, song_history: history)
    end
  end

  defp assign_sorted_songs(socket) do
    %{song_list: song_list, sort_by: sort_by, min_played: min_played, filter: filter} =
      socket.assigns

    selected_song = Map.get(socket.assigns, :selected_song)

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

  defp parse_int(nil, default), do: default

  defp parse_int(str, default) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> default
    end
  end

  defp fmt_set("SET 1"), do: "Set 1"
  defp fmt_set("SET 2"), do: "Set 2"
  defp fmt_set("SET 3"), do: "Set 3"
  defp fmt_set("ENCORE"), do: "Encore"
  defp fmt_set("ENCORE 2"), do: "Encore 2"
  defp fmt_set(other), do: other
end
