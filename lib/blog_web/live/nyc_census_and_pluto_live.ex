defmodule BlogWeb.NycCensusAndPlutoLive do
  @moduledoc "Interactive NYC map with population estimation using PLUTO + Census data."
  use BlogWeb, :live_view

  alias Blog.Population.Estimator

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, loading: false, results: nil, error: nil)}
  end

  @impl true
  def handle_event("shape_drawn", %{"polygon" => polygon}, socket) do
    socket = assign(socket, loading: true, error: nil, results: nil)

    task =
      Task.async(fn ->
        Estimator.estimate(polygon)
      end)

    {:noreply, assign(socket, task_ref: task.ref)}
  end

  def handle_event("clear_shape", _params, socket) do
    {:noreply, assign(socket, results: nil, error: nil, loading: false)}
  end

  @impl true
  def handle_info({ref, {:ok, results}}, %{assigns: %{task_ref: ref}} = socket) do
    Process.demonitor(ref, [:flush])

    summary = Map.drop(results, [:lots])

    socket =
      socket
      |> assign(loading: false, results: summary, task_ref: nil)
      |> push_event("estimation_results", results)

    {:noreply, socket}
  end

  def handle_info({ref, {:error, reason}}, %{assigns: %{task_ref: ref}} = socket) do
    Process.demonitor(ref, [:flush])

    {:noreply, assign(socket, loading: false, error: inspect(reason), task_ref: nil)}
  end

  def handle_info({:DOWN, ref, :process, _pid, reason}, %{assigns: %{task_ref: ref}} = socket) do
    {:noreply,
     assign(socket, loading: false, error: "Estimation failed: #{inspect(reason)}", task_ref: nil)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <div id="map-wrapper" phx-hook="NycMap" class="nyc-map-wrapper">
      <div id="nyc-map" phx-update="ignore" class="nyc-map"></div>

      <div class="nyc-results-panel">
        <h1 class="nyc-title">How Many People Live Here?</h1>
        <p class="nyc-subtitle">Draw a shape on the map to estimate population.</p>

        <div :if={@loading} class="nyc-loading">
          <div class="nyc-spinner"></div>
          <p>Estimating population...</p>
        </div>

        <div :if={@error} class="nyc-error">
          <p><%= @error %></p>
        </div>

        <div :if={@results} class="nyc-results">
          <div class="nyc-stat nyc-primary">
            <span class="nyc-stat-value"><%= format_number(round(@results.total_population)) %></span>
            <span class="nyc-stat-label">estimated people</span>
          </div>

          <div class="nyc-stat-grid">
            <div class="nyc-stat">
              <span class="nyc-stat-value"><%= format_number(@results.total_lots) %></span>
              <span class="nyc-stat-label">tax lots</span>
            </div>
            <div class="nyc-stat">
              <span class="nyc-stat-value"><%= format_number(@results.total_residential_units) %></span>
              <span class="nyc-stat-label">residential units</span>
            </div>
            <div class="nyc-stat">
              <span class="nyc-stat-value"><%= @results.tract_count %></span>
              <span class="nyc-stat-label">census tracts</span>
            </div>
          </div>

          <button phx-click="clear_shape" class="nyc-clear-btn">
            Clear &amp; Start Over
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp format_number(n) when is_float(n), do: n |> round() |> format_number()

  defp format_number(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1,")
    |> String.reverse()
  end

  defp format_number(n), do: to_string(n)
end
