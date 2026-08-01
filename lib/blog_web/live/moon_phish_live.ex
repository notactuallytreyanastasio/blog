defmodule BlogWeb.MoonPhishLive do
  use BlogWeb, :live_view

  alias Blog.Moon

  @phase_order [
    "New Moon",
    "Waxing Crescent",
    "First Quarter",
    "Waxing Gibbous",
    "Full Moon",
    "Waning Gibbous",
    "Last Quarter",
    "Waning Crescent"
  ]

  @phase_emoji %{
    "New Moon" => "🌑",
    "Waxing Crescent" => "🌒",
    "First Quarter" => "🌓",
    "Waxing Gibbous" => "🌔",
    "Full Moon" => "🌕",
    "Waning Gibbous" => "🌖",
    "Last Quarter" => "🌗",
    "Waning Crescent" => "🌘"
  }

  @impl true
  def mount(_params, _session, socket) do
    shows = annotated_shows()
    full_count = Enum.count(shows, & &1.moon.full_moon?)

    phase_counts =
      shows
      |> Enum.group_by(& &1.moon.phase_name)
      |> Map.new(fn {name, list} -> {name, length(list)} end)

    {first, last} = {List.first(shows), List.last(shows)}

    {:ok,
     assign(socket,
       page_title: "Moon Phish — every Phish show vs. the lunar calendar",
       shows: shows,
       total: length(shows),
       full_count: full_count,
       phase_counts: phase_counts,
       first_date: first && first.date,
       last_date: last && last.date,
       today_moon: today_moon(),
       next_full: next_full_moon(),
       view: "full",
       era: "all",
       phase: nil,
       q: ""
     )}
  end

  @impl true
  def handle_event("set-view", %{"view" => view}, socket) when view in ["full", "all"] do
    {:noreply, assign(socket, view: view, phase: nil)}
  end

  def handle_event("set-era", %{"era" => era}, socket) do
    {:noreply, assign(socket, era: era)}
  end

  def handle_event("set-phase", %{"phase" => phase}, socket) do
    new_phase = if socket.assigns.phase == phase, do: nil, else: phase
    {:noreply, assign(socket, phase: new_phase, view: "all")}
  end

  def handle_event("search", %{"value" => q}, socket) do
    {:noreply, assign(socket, q: q)}
  end

  # Template helpers

  def phase_order, do: @phase_order

  def phase_emoji(name), do: Map.get(@phase_emoji, name, "🌑")

  def filtered_shows(%{shows: shows, view: view, era: era, phase: phase, q: q}) do
    shows
    |> Enum.filter(fn s ->
      (view != "full" or s.moon.full_moon?) and
        (phase == nil or s.moon.phase_name == phase) and
        era_match?(s.date.year, era) and
        query_match?(s, q)
    end)
  end

  def group_by_year(shows) do
    shows
    |> Enum.sort_by(& &1.date, {:desc, Date})
    |> Enum.chunk_by(& &1.date.year)
    |> Enum.map(fn [first | _] = group -> {first.date.year, group} end)
  end

  def fmt_date(date), do: Calendar.strftime(date, "%b %d")

  def fmt_long_date(nil), do: ""
  def fmt_long_date(date), do: Calendar.strftime(date, "%B %-d, %Y")

  def fmt_illum(illum), do: "#{round(illum * 100)}%"

  def fmt_pct(count, total) when total > 0 do
    :erlang.float_to_binary(100 * count / total, decimals: 1) <> "%"
  end

  def fmt_pct(_, _), do: "0%"

  def near_full_label(%{full_moon?: true}), do: nil

  def near_full_label(%{days_from_full: d}) when abs(d) <= 1.5 do
    n = abs(d) |> Float.round() |> trunc() |> max(1)
    if d < 0, do: "#{n}d before full", else: "#{n}d after full"
  end

  def near_full_label(_), do: nil

  def era_title("all"), do: "All eras"
  def era_title("1.0"), do: "Phish 1.0 — 1983–2000"
  def era_title("2.0"), do: "Phish 2.0 — 2002–2004"
  def era_title("3.0"), do: "Phish 3.0 — 2009–2020"
  def era_title("4.0"), do: "Phish 4.0 — 2021–now"
  def era_title(_), do: nil

  defp era_match?(_year, "all"), do: true
  defp era_match?(year, "1.0"), do: year <= 2000
  defp era_match?(year, "2.0"), do: year >= 2002 and year <= 2004
  defp era_match?(year, "3.0"), do: year >= 2009 and year <= 2020
  defp era_match?(year, "4.0"), do: year >= 2021
  defp era_match?(_, _), do: true

  defp query_match?(_show, ""), do: true

  defp query_match?(show, q) do
    q = String.downcase(q)

    Enum.any?([show.venue, show.location, show.tour_name], fn field ->
      field != nil and String.contains?(String.downcase(field), q)
    end)
  end

  defp annotated_shows do
    case :persistent_term.get({__MODULE__, :shows}, nil) do
      nil ->
        shows = build_annotated_shows()
        :persistent_term.put({__MODULE__, :shows}, shows)
        shows

      shows ->
        shows
    end
  end

  defp build_annotated_shows do
    shows = Blog.Phish.list_shows()

    case shows do
      [] ->
        []

      _ ->
        from_year = hd(shows).date.year
        to_year = List.last(shows).date.year + 1
        new_moons = Moon.new_moons(from_year - 1, to_year)
        full_moons = Moon.full_moons(from_year - 1, to_year)

        Enum.map(shows, fn s ->
          %{
            date: s.date,
            venue: s.venue,
            location: s.location,
            tour_name: s.tour_name,
            moon: Moon.phase_info(s.date, new_moons, full_moons)
          }
        end)
    end
  end

  defp today_moon do
    today = Date.utc_today()
    year = today.year
    Moon.phase_info(today, Moon.new_moons(year - 1, year + 1), Moon.full_moons(year - 1, year + 1))
  end

  defp next_full_moon do
    now = DateTime.utc_now()
    year = now.year

    (year - 1)
    |> Moon.full_moons(year + 1)
    |> Enum.find(fn dt -> DateTime.compare(dt, now) == :gt end)
    |> case do
      nil -> nil
      dt -> DateTime.to_date(dt)
    end
  end
end
