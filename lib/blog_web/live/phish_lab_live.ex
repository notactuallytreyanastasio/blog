defmodule BlogWeb.PhishLabLive do
  use BlogWeb, :live_view

  alias Blog.PhishLab

  # per-leaderboard chart preset: {dataset, x, y}
  @board_presets %{
    "shows_jammiest" => {"shows", "d", "jam_z"},
    "shows_rarest" => {"shows", "d", "rarity"},
    "shows_overachievers" => {"shows", "d", "rating_z"},
    "shows_longest" => {"shows", "d", "dur"},
    "shows_most_unique" => {"shows", "d", "uniq"},
    "songs_variable" => {"songs", "avg", "cv"},
    "songs_bustouts" => {"songs", "maxgap", "plays"},
    "songs_jam_vehicles" => {"songs", "plays", "avg"},
    "perfs_outliers" => {"perfs", "d", "z"},
    "perfs_longest" => {"perfs", "d", "dur"},
    "style_definers" => {"songs", "njams", "avg"}
  }

  @presets %{
    "anomaly-scan" => %{ds: "perfs", x: "d", y: "z", color: "era", size: "none"},
    "jam-era" => %{ds: "shows", x: "d", y: "avg_song", color: "era", size: "njams"},
    "crowd-v-couch" => %{ds: "shows", x: "jam_z", y: "rating_z", color: "era", size: "none"},
    "song-risk" => %{ds: "songs", x: "avg", y: "cv", color: "plays", size: "plays"},
    "type2-map" => %{ds: "shows", x: "style:Psychedelic", y: "style:Bliss", color: "rating", size: "njams"}
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Phish Lab — anomaly detection for a band from Vermont",
       meta: PhishLab.meta(),
       leaderboards: PhishLab.leaderboards(),
       lb: "perfs_outliers",
       inspect: nil,
       inspect_kind: nil,
       highlight: nil
     )
     |> assign_config(%{ds: "shows", x: "d", y: "avg_song", color: "era", size: "none", chart: "scatter", logx: false, logy: false})}
  end

  @impl true
  def handle_event("chart-mounted", _params, socket) do
    {:noreply, push_config(socket)}
  end

  def handle_event("set-config", params, socket) do
    cfg = current_config(socket)

    new = %{
      cfg
      | ds: params["ds"] || cfg.ds,
        chart: params["chart"] || cfg.chart,
        x: params["x"] || cfg.x,
        y: params["y"] || cfg.y,
        color: params["color"] || cfg.color,
        size: params["size"] || cfg.size,
        logx: params["logx"] == "true",
        logy: params["logy"] == "true"
    }

    new = if new.ds != cfg.ds, do: reset_axes(new), else: new

    {:noreply, socket |> assign(highlight: nil) |> assign_config(new) |> push_config()}
  end

  def handle_event("preset", %{"name" => name}, socket) do
    case Map.get(@presets, name) do
      nil ->
        {:noreply, socket}

      p ->
        cfg = %{current_config(socket) | ds: p.ds, x: p.x, y: p.y, color: p.color, size: p.size, chart: "scatter"}
        {:noreply, socket |> assign(highlight: nil) |> assign_config(cfg) |> push_config()}
    end
  end

  def handle_event("set-lb", %{"lb" => lb}, socket) do
    {:noreply, assign(socket, lb: lb)}
  end

  def handle_event("lb-jump", params, socket) do
    lb = socket.assigns.lb
    {ds, x, y} = Map.get(@board_presets, lb, {"shows", "d", "rating"})

    x =
      case {lb, params["style"]} do
        {"style_definers", style} when is_binary(style) -> "style:" <> style
        _ -> x
      end

    cfg = %{current_config(socket) | ds: ds, x: x, y: y, chart: "scatter"}
    highlight = Map.take(params, ["d", "s"])

    {:noreply, socket |> assign(highlight: highlight) |> assign_config(cfg) |> push_config()}
  end

  def handle_event("inspect", %{"ds" => "shows", "key" => date}, socket) do
    {:noreply, assign(socket, inspect: PhishLab.find_show(date), inspect_kind: "shows")}
  end

  def handle_event("inspect", %{"ds" => "songs", "key" => name}, socket) do
    {:noreply, assign(socket, inspect: PhishLab.find_song(name), inspect_kind: "songs")}
  end

  def handle_event("inspect", %{"ds" => "perfs", "key" => i}, socket) do
    {:noreply, assign(socket, inspect: PhishLab.find_perf(i), inspect_kind: "perfs")}
  end

  def handle_event("close-inspect", _params, socket) do
    {:noreply, assign(socket, inspect: nil, inspect_kind: nil)}
  end

  # ----------------------------------------------------------------- helpers

  defp assign_config(socket, cfg) do
    assign(socket,
      ds: cfg.ds,
      chart: cfg.chart,
      x: cfg.x,
      y: cfg.y,
      color: cfg.color,
      size: cfg.size,
      logx: cfg.logx,
      logy: cfg.logy
    )
  end

  defp current_config(%{assigns: a}) do
    %{ds: a.ds, chart: a.chart, x: a.x, y: a.y, color: a.color, size: a.size, logx: a.logx, logy: a.logy}
  end

  defp reset_axes(%{ds: "shows"} = cfg), do: %{cfg | x: "d", y: "avg_song", color: "era", size: "none"}
  defp reset_axes(%{ds: "songs"} = cfg), do: %{cfg | x: "plays", y: "avg", color: "cv", size: "none"}
  defp reset_axes(%{ds: "perfs"} = cfg), do: %{cfg | x: "d", y: "z", color: "era", size: "none"}

  defp push_config(socket) do
    a = socket.assigns

    push_event(socket, "lab:config", %{
      ds: a.ds,
      chart: a.chart,
      x: axis_info(a.ds, a.x),
      y: axis_info(a.ds, a.y),
      color: axis_info(a.ds, a.color),
      size: axis_info(a.ds, a.size),
      logx: a.logx,
      logy: a.logy,
      highlight: a.highlight
    })
  end

  defp axis_info(_ds, "none"), do: %{key: "none", label: "", fmt: "num"}
  defp axis_info(_ds, "era"), do: %{key: "era", label: "Era", fmt: "cat"}

  defp axis_info(ds, key) do
    case Enum.find(PhishLab.metrics(ds), fn {k, _, _} -> k == key end) do
      {_, label, fmt} -> %{key: key, label: label, fmt: fmt}
      nil -> %{key: key, label: key, fmt: "num"}
    end
  end

  # ---------------------------------------------------------- template helpers

  def metric_options(ds), do: Enum.map(PhishLab.metrics(ds), fn {k, label, _} -> {k, label} end)

  def color_options(ds) do
    era = if ds in ["shows", "perfs"], do: [{"era", "Era (1.0–4.0)"}], else: []
    [{"none", "— none —"}] ++ era ++ metric_options(ds)
  end

  def size_options(ds), do: [{"none", "— uniform —"}] ++ numeric_options(ds)

  defp numeric_options(ds) do
    PhishLab.metrics(ds)
    |> Enum.reject(fn {_, _, fmt} -> fmt == :date end)
    |> Enum.map(fn {k, label, _} -> {k, label} end)
  end

  def dataset_options, do: PhishLab.datasets()

  def lb_options do
    lbs = PhishLab.leaderboards()

    PhishLab.leaderboard_order()
    |> Enum.filter(&Map.has_key?(lbs, &1))
    |> Enum.map(fn k -> {k, lbs[k]["title"]} end)
  end

  def lb_entries(assigns) do
    get_in(assigns.leaderboards, [assigns.lb, "entries"]) || []
  end

  def presets do
    [
      {"anomaly-scan", "Anomaly Scan"},
      {"jam-era", "The Jamming Eras"},
      {"crowd-v-couch", "Long ≠ Loved?"},
      {"song-risk", "Song Risk Profiles"},
      {"type2-map", "Type II Map"}
    ]
  end

  def inspect_rows(nil, _kind), do: []

  def inspect_rows(item, kind) do
    id_rows =
      case kind do
        "shows" -> [{"Venue", item["venue"]}, {"Location", item["loc"]}, {"Tour", item["tour"]}, {"Era", item["era"]}]
        "songs" -> [{"Song", item["s"]}]
        "perfs" -> [{"Song", item["s"]}, {"Set", item["set"]}]
        _ -> []
      end

    metric_rows =
      for {k, label, fmt} <- PhishLab.metrics(kind || "shows"),
          not String.starts_with?(k, "style:"),
          v = item[k],
          v != nil do
        {label, PhishLab.fmt_val(v, fmt)}
      end

    extra =
      case kind do
        "shows" -> [{"Longest song", "#{item["max_song_t"]} (#{PhishLab.fmt_sec(item["max_song"])})"}]
        "songs" ->
          [
            {"Longest version", "#{PhishLab.fmt_sec(item["max"])} on #{item["max_d"]}"}
          ] ++
            if item["maxgap_from"],
              do: [{"Shelf gap", "#{item["maxgap_from"]} → #{item["maxgap_to"]}"}],
              else: []

        _ -> []
      end

    id_rows ++ metric_rows ++ extra
  end

  def inspect_title(nil, _), do: "no selection"
  def inspect_title(item, "shows"), do: "#{item["d"]} — #{item["venue"]}"
  def inspect_title(item, "songs"), do: item["s"]
  def inspect_title(item, "perfs"), do: "#{item["s"]} — #{item["d"]}"

  def inspect_date(item), do: item && item["d"]

  def style_bars(nil), do: []

  def style_bars(item) do
    case item["styles"] do
      nil -> []
      styles -> styles |> Enum.sort_by(fn {_, v} -> -v end) |> Enum.take(8)
    end
  end

  def fmt_sec(s), do: PhishLab.fmt_sec(s)

  def fmt_meta_range(meta) do
    "#{meta["date_min"]} → #{meta["date_max"]}"
  end
end
