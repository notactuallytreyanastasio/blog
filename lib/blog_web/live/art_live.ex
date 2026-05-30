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
     |> assign_meta(seed, generator)
     |> push_event("draw", %{seed: seed, generator: generator})}
  end

  @impl true
  def handle_event("generators_ready", %{"generators" => gens}, socket) do
    {:noreply, assign(socket, :generators, gens)}
  end

  def handle_event("render_done", %{"seed" => s, "generator" => g, "shapes" => n, "ms" => ms}, socket) do
    {:noreply,
     socket
     |> assign(:seed, s)
     |> assign(:generator, g)
     |> assign(:shapes, n)
     |> assign(:ms, ms)
     |> assign_meta(s, g)}
  end

  def handle_event("seed_changed", %{"seed" => seed, "generator" => gen}, socket) do
    {:noreply,
     socket
     |> assign(:seed, seed)
     |> assign(:generator, gen)
     |> assign_meta(seed, gen)}
  end

  def handle_event("set_generator", %{"generator" => gen}, socket) do
    {:noreply,
     socket
     |> assign(:generator, gen)
     |> assign_meta(socket.assigns.seed, gen)
     |> push_event("draw", %{seed: socket.assigns.seed, generator: gen})}
  end

  def handle_event("set_seed", %{"seed" => raw}, socket) do
    seed = parse_int(raw, socket.assigns.seed)
    {:noreply,
     socket
     |> assign(:seed, seed)
     |> assign_meta(seed, socket.assigns.generator)
     |> push_event("draw", %{seed: seed, generator: socket.assigns.generator})}
  end

  def handle_event("random", _params, socket), do: {:noreply, socket}

  defp assign_meta(socket, seed, generator) do
    socket
    |> assign(:page_title, "Temper Art — seed #{seed} · #{generator}")
    |> assign(:page_description, "The engine is one Temper program — a statically-typed language that cross-compiles to JS, Python, Java, C#, Lua, and Rust. Written once, it runs natively on every backend. Three algorithms: Bauhaus grids, flow-field particles, Mondrian subdivision. Every seed is deterministic across all backends. Currently running as compiled JavaScript. #{generator |> String.capitalize()}, seed #{seed}.")
    |> assign(:page_image, "https://www.bobbby.online/images/og-temper-art.png")
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
