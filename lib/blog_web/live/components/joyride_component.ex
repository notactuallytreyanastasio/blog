defmodule BlogWeb.JoyrideComponent do
  @moduledoc """
  Guided tour component with class-based styling.

  ## Usage

      <.live_component
        module={JoyrideComponent}
        id="tour"
        steps={@steps}
        run={@show_tour}
      />

  ## Custom Styling

  Pass a `classes` map to override default styles:

      <.live_component
        module={JoyrideComponent}
        id="tour"
        steps={@steps}
        run={@show_tour}
        classes={%{
          spotlight: "border-4 border-blue-500 rounded-lg",
          tooltip: "bg-white border border-gray-200 rounded-xl shadow-xl",
          title: "text-lg font-bold text-gray-900",
          content: "text-sm text-gray-600",
          button: "px-4 py-2 rounded border",
          button_primary: "bg-blue-500 text-white border-blue-500",
          button_back: "bg-white text-gray-700 border-gray-300"
        }}
      />

  ## Available class keys

  - `overlay` - the dark backdrop
  - `spotlight` - border around highlighted element
  - `tooltip` - the tooltip container
  - `titlebar` - Mac-style title bar (set to "" to hide)
  - `title` - step title text
  - `content` - step content text
  - `footer` - footer container
  - `progress` - "1 of 6" text
  - `button` - base button styles
  - `button_primary` - Next/Done button
  - `button_back` - Back button
  - `close` - close button/box
  """
  use BlogWeb, :live_component

  # Default classes - classic Mac OS style
  @default_classes %{
    overlay: "bg-black/40",
    spotlight: "border-2 border-black shadow-[2px_2px_0_#000]",
    tooltip: "bg-gradient-to-b from-white to-[#ccc] border-2 border-black shadow-[2px_2px_0_#000] font-['Chicago','Geneva',system-ui,sans-serif]",
    titlebar: "h-[18px] border-b-2 border-black flex items-center px-1 bg-[repeating-linear-gradient(90deg,#000_0px,#000_1px,#fff_1px,#fff_3px)]",
    title: "text-[11px] font-bold text-black bg-white px-1",
    content: "text-xs text-black leading-relaxed",
    footer: "border-t border-[#999] pt-3 mt-4",
    progress: "text-[11px] text-[#666]",
    button: "px-3 py-1 text-xs border-2 border-black rounded bg-gradient-to-b from-white to-[#ddd] shadow-[1px_1px_0_#000] cursor-pointer",
    button_primary: "font-bold",
    button_back: "",
    close: "w-3 h-3 bg-white border border-black cursor-pointer"
  }

  def mount(socket) do
    {:ok, assign(socket,
      step_index: 0,
      rect: nil,
      window_width: 1200,
      window_height: 800
    )}
  end

  def update(assigns, socket) do
    was_running = socket.assigns[:run] == true
    now_running = assigns[:run] == true

    # Merge custom classes with defaults
    custom_classes = assigns[:classes] || %{}
    classes = Map.merge(@default_classes, custom_classes)
    assigns = Map.put(assigns, :classes, classes)

    # Track if steps changed before assigning
    old_steps = socket.assigns[:steps]
    new_steps = assigns[:steps]
    steps_changed = old_steps != new_steps

    socket = assign(socket, assigns)

    socket = cond do
      # Tour just started - reset to step 0
      now_running && !was_running ->
        socket
        |> assign(step_index: 0, rect: nil)
        |> request_position()

      # Tour is running and steps changed - re-request position for current step
      now_running && steps_changed ->
        socket
        |> assign(rect: nil)
        |> request_position()

      true ->
        socket
    end

    {:ok, socket}
  end

  defp request_position(socket) do
    step = Enum.at(socket.assigns.steps, socket.assigns.step_index)
    if step do
      push_event(socket, "joyride:goto", %{target: step.target})
    else
      socket
    end
  end

  def handle_event("rect", %{"rect" => rect, "window" => window}, socket) do
    {:noreply, assign(socket,
      rect: %{x: rect["x"], y: rect["y"], width: rect["width"], height: rect["height"]},
      window_width: window["width"],
      window_height: window["height"]
    )}
  end

  def handle_event("next", _params, socket) do
    next_index = socket.assigns.step_index + 1

    if next_index >= length(socket.assigns.steps) do
      send(self(), {:tour_complete, socket.assigns.id})
      {:noreply, assign(socket, step_index: 0, rect: nil)}
    else
      socket = socket |> assign(step_index: next_index, rect: nil) |> request_position()
      {:noreply, socket}
    end
  end

  def handle_event("prev", _params, socket) do
    prev_index = max(0, socket.assigns.step_index - 1)
    socket = socket |> assign(step_index: prev_index, rect: nil) |> request_position()
    {:noreply, socket}
  end

  def handle_event("close", _params, socket) do
    send(self(), {:tour_complete, socket.assigns.id})
    {:noreply, assign(socket, step_index: 0, rect: nil)}
  end

  def render(assigns) do
    step = if assigns.run, do: Enum.at(assigns.steps, assigns.step_index), else: nil
    assigns = assign(assigns, :step, step)

    ~H"""
    <div id={@id} phx-hook="Joyride" phx-target={@myself}>
      <%= if @run && @step && @rect do %>
        <%!-- Overlay --%>
        <div
          class={["fixed inset-0 z-[9998] cursor-pointer", @classes.overlay]}
          style={overlay_clip(@rect)}
          phx-click="close"
          phx-target={@myself}
        />

        <%!-- Spotlight border --%>
        <div
          class={["fixed z-[9999] pointer-events-none", @classes.spotlight]}
          style={"top:#{@rect.y - 8}px;left:#{@rect.x - 8}px;width:#{@rect.width + 16}px;height:#{@rect.height + 16}px;"}
        />

        <%!-- Tooltip --%>
        <div
          class={["fixed z-[10000] max-w-[320px]", @classes.tooltip]}
          style={tooltip_pos(@rect, @window_width, @window_height)}
        >
          <%!-- Title bar (if class provided) --%>
          <%= if @classes.titlebar != "" do %>
            <div class={@classes.titlebar}>
              <div class={@classes.close} phx-click="close" phx-target={@myself}></div>
              <span class={["mx-auto", @classes.title]}><%= @step.title %></span>
              <div class="w-3 h-3"></div>
            </div>
          <% end %>

          <div class="p-4">
            <%!-- Title (if no titlebar) --%>
            <%= if @classes.titlebar == "" do %>
              <div class={["mb-2", @classes.title]}><%= @step.title %></div>
            <% end %>

            <%!-- Content --%>
            <div class={@classes.content}>
              <%= @step.content %>
            </div>

            <%!-- Footer --%>
            <div class={["flex justify-between items-center", @classes.footer]}>
              <span class={@classes.progress}>
                <%= @step_index + 1 %> of <%= length(@steps) %>
              </span>
              <div class="flex gap-2">
                <%= if @step_index > 0 do %>
                  <button
                    phx-click="prev"
                    phx-target={@myself}
                    class={[@classes.button, @classes.button_back]}
                  >Back</button>
                <% end %>
                <button
                  phx-click="next"
                  phx-target={@myself}
                  class={[@classes.button, @classes.button_primary]}
                ><%= if @step_index == length(@steps) - 1, do: "Done", else: "Next" %></button>
              </div>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Create a clip-path that cuts out the spotlight area
  defp overlay_clip(rect) do
    # Polygon that covers everything except the spotlight
    x1 = rect.x - 8
    y1 = rect.y - 8
    x2 = rect.x + rect.width + 8
    y2 = rect.y + rect.height + 8

    "clip-path: polygon(
      0% 0%, 0% 100%, #{x1}px 100%, #{x1}px #{y1}px,
      #{x2}px #{y1}px, #{x2}px #{y2}px, #{x1}px #{y2}px,
      #{x1}px 100%, 100% 100%, 100% 0%
    );"
  end

  defp tooltip_pos(rect, win_w, win_h) do
    top = rect.y + rect.height + 20
    left = rect.x + (rect.width / 2) - 160
    left = max(16, min(left, win_w - 340))

    if top + 200 > win_h do
      "bottom:#{win_h - rect.y + 20}px;left:#{left}px;"
    else
      "top:#{top}px;left:#{left}px;"
    end
  end
end
