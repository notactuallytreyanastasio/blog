defmodule BlogWeb.SkyLive do
  use BlogWeb, :live_view

  alias Blog.Sky

  @big_threshold 500

  @impl true
  def mount(_params, _session, socket) do
    communities = load_communities()

    socket =
      assign(socket,
        page_title: "Fill The Sky",
        communities: communities,
        selected_community: nil,
        selected_profile: nil,
        community_filter: "",
        view_mode: "big",
        loading: true
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("select_community", %{"index" => index}, socket) do
    index = if is_binary(index), do: String.to_integer(index), else: index

    new_selected =
      if socket.assigns.selected_community == index, do: nil, else: index

    socket =
      socket
      |> assign(selected_community: new_selected)
      |> push_event("select_community", %{index: new_selected})

    {:noreply, socket}
  end

  def handle_event("filter_communities", %{"community_filter" => filter}, socket) do
    {:noreply, assign(socket, community_filter: filter)}
  end

  def handle_event("set_view_mode", %{"mode" => mode}, socket) do
    socket =
      socket
      |> assign(view_mode: mode, selected_community: nil)
      |> push_event("select_community", %{index: nil})
      |> push_event("set_view_mode", %{mode: mode})

    {:noreply, socket}
  end

  def handle_event("clear_selection", _params, socket) do
    socket =
      socket
      |> assign(selected_community: nil, selected_profile: nil)
      |> push_event("select_community", %{index: nil})

    {:noreply, socket}
  end

  def handle_event("point_clicked", %{"handle" => handle, "community_index" => idx}, socket) do
    case Sky.get_profile_by_handle(handle) do
      {:ok, profile} ->
        {:noreply, assign(socket, selected_profile: profile, selected_community: idx)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("map_loaded", _params, socket) do
    {:noreply, assign(socket, loading: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="os-desktop-mac" style="padding: 8px; min-height: 100vh;">
      <div class="os-window os-window-mac" style="width: 98vw; max-width: 100%; height: calc(100vh - 16px); display: flex; flex-direction: column;">
        <div class="os-titlebar">
          <div class="os-titlebar-buttons">
            <a href="/" class="os-btn-close"></a>
          </div>
          <span class="os-titlebar-title">Fill The Sky — Bluesky Communities</span>
          <div class="os-titlebar-spacer"></div>
        </div>

        <div class="os-content" style="flex: 1; display: flex; padding: 0; overflow: hidden; position: relative;">
          <div style="flex: 1; position: relative; min-width: 0; overflow: hidden;">
            <div
              id="sky-map"
              phx-hook="SkyMap"
              phx-update="ignore"
              style="width: 100%; height: 100%; background: #222;"
            >
            </div>

            <div
              :if={@loading}
              style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; background: rgba(34,34,34,0.85);"
            >
              <div style="color: #fff; font-size: 14px; font-family: Chicago, Geneva, Helvetica, sans-serif;">
                Loading 545,173 points...
              </div>
            </div>
          </div>

          <div style="width: 500px; flex-shrink: 0; border-left: 1px solid #000; display: flex; flex-direction: column; background: #fff;">
            <div
              :if={@selected_profile}
              style="padding: 8px; border-bottom: 1px solid #000; font-family: Chicago, Geneva, Helvetica, sans-serif; font-size: 11px;"
            >
              <div style="display: flex; justify-content: space-between; align-items: start;">
                <div style="display: flex; gap: 8px; align-items: start; min-width: 0;">
                  <img
                    :if={@selected_profile.avatar_url}
                    src={@selected_profile.avatar_url}
                    style="width: 40px; height: 40px; border: 1px solid #000; flex-shrink: 0;"
                  />
                  <div
                    :if={!@selected_profile.avatar_url}
                    style="width: 40px; height: 40px; border: 1px solid #000; flex-shrink: 0; background: #ccc; display: flex; align-items: center; justify-content: center;"
                  >
                    ?
                  </div>
                  <div style="min-width: 0;">
                    <div style="font-weight: bold; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                      {@selected_profile.handle || @selected_profile.did}
                    </div>
                    <div :if={@selected_profile.display_name} style="color: #666; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                      {@selected_profile.display_name}
                    </div>
                  </div>
                </div>
                <button
                  phx-click="clear_selection"
                  style="border: 1px solid #000; background: #fff; cursor: pointer; padding: 0 4px; font-size: 11px; flex-shrink: 0;"
                >
                  x
                </button>
              </div>
              <p :if={@selected_profile.bio} style="margin: 6px 0 0 0; color: #333; line-height: 1.3; max-height: 3.9em; overflow: hidden;">
                {@selected_profile.bio}
              </p>
              <div style="margin-top: 4px; color: #666; display: flex; gap: 12px;">
                <span>{@selected_profile.followers_count} followers</span>
                <span>{@selected_profile.following_count} following</span>
              </div>
              <a
                :if={@selected_profile.handle}
                href={"https://bsky.app/profile/#{@selected_profile.handle}"}
                target="_blank"
                style="display: inline-block; margin-top: 4px; color: #00f; text-decoration: underline;"
              >
                View on Bluesky
              </a>
            </div>

            <div style="padding: 6px 8px; border-bottom: 1px solid #000;">
              <div style="display: flex; border: 1px solid #000; font-size: 11px;">
                <button
                  phx-click="set_view_mode"
                  phx-value-mode="big"
                  style={"flex: 1; padding: 3px 0; border: none; cursor: pointer; font-family: Chicago, Geneva, Helvetica, sans-serif; font-size: 11px;" <> if(@view_mode == "big", do: " background: #000; color: #fff;", else: " background: #fff; color: #000;")}
                >
                  Big Scene
                </button>
                <button
                  phx-click="set_view_mode"
                  phx-value-mode="niche"
                  style={"flex: 1; padding: 3px 0; border: none; border-left: 1px solid #000; cursor: pointer; font-family: Chicago, Geneva, Helvetica, sans-serif; font-size: 11px;" <> if(@view_mode == "niche", do: " background: #000; color: #fff;", else: " background: #fff; color: #000;")}
                >
                  Niche
                </button>
                <button
                  phx-click="set_view_mode"
                  phx-value-mode="all"
                  style={"flex: 1; padding: 3px 0; border: none; border-left: 1px solid #000; cursor: pointer; font-family: Chicago, Geneva, Helvetica, sans-serif; font-size: 11px;" <> if(@view_mode == "all", do: " background: #000; color: #fff;", else: " background: #fff; color: #000;")}
                >
                  All
                </button>
              </div>
            </div>

            <div style="padding: 4px 8px; border-bottom: 1px solid #ccc;">
              <form phx-change="filter_communities">
                <input
                  type="text"
                  name="community_filter"
                  value={@community_filter}
                  placeholder="Filter..."
                  phx-debounce="200"
                  style="width: 100%; border: 1px solid #000; padding: 2px 4px; font-size: 11px; font-family: Chicago, Geneva, Helvetica, sans-serif; box-sizing: border-box;"
                />
              </form>
            </div>

            <div style="flex: 1; overflow-y: auto; font-size: 11px;">
              <div
                :for={c <- visible_communities(@communities, @community_filter, @view_mode)}
                phx-click="select_community"
                phx-value-index={c.i}
                style={"padding: 3px 8px; cursor: pointer; display: flex; align-items: center; gap: 4px; font-family: Chicago, Geneva, Helvetica, sans-serif;" <> if(c.i == @selected_community, do: " background: #000; color: #fff;", else: "")}
              >
                <span style="flex: 1; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                  {c.l || "Community #{c.i}"}
                </span>
                <span style={"font-size: 10px;" <> if(c.i == @selected_community, do: " color: #ccc;", else: " color: #999;")}>
                  {c.m}
                </span>
              </div>
            </div>
          </div>
        </div>

        <div class="os-statusbar">
          <span>{view_mode_count(@communities, @view_mode)} communities</span>
          <span>545,173 accounts · Fill The Sky</span>
        </div>
      </div>
    </div>
    """
  end

  defp load_communities do
    path = Application.app_dir(:blog, "priv/static/data/sky_communities.json")

    case File.read(path) do
      {:ok, json} ->
        json
        |> Jason.decode!()
        |> Enum.sort_by(& &1["m"], :desc)
        |> Enum.map(fn c ->
          %{i: c["i"], l: c["l"], m: c["m"], cx: c["cx"], cy: c["cy"]}
        end)

      {:error, _} ->
        []
    end
  end

  defp visible_communities(communities, filter, mode) do
    communities
    |> filter_by_mode(mode)
    |> filter_by_text(filter)
  end

  defp filter_by_mode(communities, "all"), do: communities

  defp filter_by_mode(communities, "big"),
    do: Enum.filter(communities, &(&1.m >= @big_threshold))

  defp filter_by_mode(communities, "niche"),
    do: Enum.filter(communities, &(&1.m < @big_threshold))

  defp filter_by_mode(communities, _), do: communities

  defp filter_by_text(communities, ""), do: communities
  defp filter_by_text(communities, nil), do: communities

  defp filter_by_text(communities, filter) do
    pattern = String.downcase(filter)

    Enum.filter(communities, fn c ->
      label = String.downcase(c.l || "")
      String.contains?(label, pattern)
    end)
  end

  defp view_mode_count(communities, "big"),
    do: Enum.count(communities, &(&1.m >= @big_threshold))

  defp view_mode_count(communities, "niche"),
    do: Enum.count(communities, &(&1.m < @big_threshold))

  defp view_mode_count(communities, _), do: length(communities)
end
