defmodule BlogWeb.ArtLive do
  use BlogWeb, :live_view

  @default_generator "bauhaus"
  @default_seed 42

  @impl true
  def mount(params, _session, socket) do
    seed      = parse_int(params["seed"], @default_seed)
    generator = params["generator"] || @default_generator

    {:ok,
     socket
     |> assign(:seed, seed)
     |> assign(:generator, generator)
     |> assign(:generators, [])
     |> assign(:shapes, nil)
     |> assign(:ms, nil)
     |> assign(:page_title, "Art Generator")
     |> assign(:page_description, "Generative art engine written in Temper, compiled to JavaScript.")
     |> push_event("draw", %{seed: seed, generator: generator})}
  end

  @impl true
  def handle_event("generators_ready", %{"generators" => gens}, socket) do
    {:noreply, assign(socket, :generators, gens)}
  end

  def handle_event("render_done", %{"seed" => s, "generator" => g, "shapes" => n, "ms" => ms}, socket) do
    {:noreply, socket |> assign(:seed, s) |> assign(:generator, g) |> assign(:shapes, n) |> assign(:ms, ms)}
  end

  def handle_event("seed_changed", %{"seed" => seed, "generator" => gen}, socket) do
    {:noreply, socket |> assign(:seed, seed) |> assign(:generator, gen)}
  end

  def handle_event("set_generator", %{"generator" => gen}, socket) do
    {:noreply,
     socket
     |> assign(:generator, gen)
     |> push_event("draw", %{seed: socket.assigns.seed, generator: gen})}
  end

  def handle_event("set_seed", %{"seed" => raw}, socket) do
    seed = parse_int(raw, socket.assigns.seed)
    {:noreply,
     socket
     |> assign(:seed, seed)
     |> push_event("draw", %{seed: seed, generator: socket.assigns.generator})}
  end

  def handle_event("random", _params, socket) do
    # Randomness lives in the JS hook; this event comes back via seed_changed.
    {:noreply, socket}
  end

  defp parse_int(nil, default), do: default
  defp parse_int(s, default) when is_binary(s) do
    case Integer.parse(s) do
      {n, _} when n >= 0 -> n
      _ -> default
    end
  end
  defp parse_int(n, _default) when is_integer(n), do: n
end
