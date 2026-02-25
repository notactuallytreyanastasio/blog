defmodule BlogWeb.PongLive do
  use BlogWeb, :live_view

  alias BlogWeb.PongLive.GameLogic

  @fps 30
  @tick_rate trunc(1000 / @fps)
  @ai_reaction_time 150
  @defeat_message_duration 60

  def mount(_params, session, socket) do
    user_id = session["user_id"] || generate_unique_id()
    tab_id = generate_unique_id()
    game_id = "pong_#{user_id}_tab_#{tab_id}"

    state = GameLogic.initial_state(game_id)

    state =
      if connected?(socket) do
        :timer.send_interval(@tick_rate, :tick)

        state =
          case :ets.lookup(:pong_games, game_id) do
            [] ->
              store_game_state(game_id, state)
              state

            [{^game_id, existing}] ->
              GameLogic.merge_existing_state(state, existing)
          end

        Phoenix.PubSub.subscribe(Blog.PubSub, "pong:#{game_id}")

        if state.ai_controlled do
          :timer.send_interval(@ai_reaction_time, :ai_move)
        end

        state
      else
        state
      end

    {:ok, assign(socket, Map.put(state, :last_key, nil))}
  end

  def terminate(reason, socket) do
    if reason == {:shutdown, :closed} do
      :ets.delete(:pong_games, socket.assigns.game_id)
    end

    :ok
  end

  # -- Events ------------------------------------------------------------------

  def handle_event("keydown", %{"key" => key}, socket) when key in ["ArrowUp", "ArrowDown"] do
    socket =
      if socket.assigns.ai_controlled do
        assign(socket, ai_controlled: false)
      else
        socket
      end

    {:noreply, assign(socket, :last_key, key)}
  end

  def handle_event("keydown", _params, socket), do: {:noreply, socket}

  def handle_event("keyup", %{"key" => key}, socket) when key in ["ArrowUp", "ArrowDown"] do
    if socket.assigns.last_key == key do
      {:noreply, assign(socket, :last_key, nil)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("keyup", _params, socket), do: {:noreply, socket}

  def handle_event("toggle_ai", _params, socket) do
    socket = assign(socket, ai_controlled: !socket.assigns.ai_controlled)
    store_game_state(socket.assigns.game_id, socket.assigns)
    {:noreply, socket}
  end

  # -- Tick handlers -----------------------------------------------------------

  def handle_info(:tick, %{assigns: %{game_state: :defeat_message, message_timer: timer}} = socket) do
    socket =
      if timer >= @defeat_message_duration do
        reset = GameLogic.reset_ball(socket.assigns.scores.wall)
        assign(socket, Map.merge(reset, %{game_state: :playing, show_defeat_message: false}))
      else
        assign(socket, message_timer: timer + 1)
      end

    store_game_state(socket.assigns.game_id, socket.assigns)
    {:noreply, socket}
  end

  def handle_info(:tick, %{assigns: %{game_state: :scored}} = socket) do
    socket =
      assign(socket,
        game_state: :defeat_message,
        message_timer: 0,
        show_defeat_message: true
      )

    store_game_state(socket.assigns.game_id, socket.assigns)
    {:noreply, socket}
  end

  def handle_info(:tick, socket) do
    changes = GameLogic.tick(socket.assigns)
    socket = assign(socket, changes)
    store_game_state(socket.assigns.game_id, socket.assigns)
    {:noreply, socket}
  end

  def handle_info(:ai_move, socket) do
    if socket.assigns.game_state == :playing && socket.assigns.ai_controlled do
      new_paddle = GameLogic.ai_move_paddle(socket.assigns.paddle, socket.assigns.ball)
      socket = assign(socket, paddle: new_paddle)
      store_game_state(socket.assigns.game_id, socket.assigns)
      {:noreply, socket}
    else
      {:noreply, socket}
    end
  end

  # -- ETS helpers -------------------------------------------------------------

  defp generate_unique_id do
    :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
  end

  defp store_game_state(game_id, state) do
    create_ets_table_if_not_exists()

    minimal_state = %{
      game_id: game_id,
      ball: state.ball,
      paddle: state.paddle,
      scores: state.scores,
      show_defeat_message: state.show_defeat_message,
      game_state: state.game_state,
      ai_controlled: state.ai_controlled
    }

    :ets.insert(:pong_games, {game_id, minimal_state})
  end

  defp create_ets_table_if_not_exists do
    if :ets.whereis(:pong_games) == :undefined do
      :ets.new(:pong_games, [:named_table, :public, :set])
    end
  end

  @doc """
  Return all active games (used by PongGodLive).
  """
  def get_all_games do
    create_ets_table_if_not_exists()

    :ets.tab2list(:pong_games)
    |> Enum.map(fn {_id, state} -> state end)
  end

  # -- Render ------------------------------------------------------------------

  def render(assigns) do
    ~H"""
    <div class="os-desktop-winxp">
      <div class="os-window os-window-winxp" style="max-width: 900px;">
        <div class="os-titlebar">
          <span class="os-titlebar-title">Pong.exe - Game ID: {@game_id}</span>
          <div class="os-titlebar-buttons">
            <div class="os-btn-min"></div>
            <div class="os-btn-max"></div>
            <a href="/" class="os-btn-close"></a>
          </div>
        </div>
        <div class="os-menubar">
          <span>Game</span>
          <span>Options</span>
          <span>View</span>
          <span>Help</span>
        </div>
        <div class="os-content">
          <div class="w-full flex flex-col justify-center items-center p-4 bg-gradient-to-br from-gray-900 to-gray-800">
            <!-- Score display with rainbow gradient -->
            <div class="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-2xl font-bold mb-4">
              Wall: {@scores.wall}
            </div>

            <!-- AI Control Toggle Button with gradient -->
            <div class="rounded-lg shadow-md mb-4">
              <button
                phx-click="toggle_ai"
                class="px-4 py-2 rounded-md font-bold transition-colors bg-gray-900 hover:bg-gray-800 text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500"
              >
                <%= if @ai_controlled do %>
                  AI Playing (Click to Take Control)
                <% else %>
                  Manual Control (Click for AI Help)
                <% end %>
              </button>
            </div>

            <div
              class="relative"
              style={"width: #{@board.width}px; height: #{@board.height}px;"}
              phx-window-keydown="keydown"
              phx-window-keyup="keyup"
              tabindex="0"
            >
              <!-- Game board with gradient border -->
              <div class="absolute w-full h-full bg-gray-900 rounded-lg overflow-hidden p-0.5 bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500">
                <div class="w-full h-full bg-gray-900 rounded-lg overflow-hidden">
                  <!-- Center line -->
                  <div class="absolute left-1/2 top-0 w-0.5 h-full bg-gradient-to-b from-fuchsia-500 via-purple-500 to-cyan-500 opacity-30">
                  </div>

                  <!-- Defeat message -->
                  <%= if @show_defeat_message do %>
                    <div class="absolute inset-0 flex items-center justify-center z-10">
                      <div
                        class="text-center text-4xl font-bold tracking-wider uppercase text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500"
                        style="text-shadow: 0 0 10px rgba(217, 70, 239, 0.5), 0 0 20px rgba(8, 145, 178, 0.5);"
                      >
                        YOU CONTINUE<br />TO EMBRACE<br />DEFEAT
                      </div>
                    </div>
                  <% end %>

                  <!-- Trail with enhanced rainbow effect -->
                  <%= for {pos, index} <- Enum.with_index(@trail) do %>
                    <div
                      class="absolute rounded-full"
                      style={"width: #{@ball_radius * 2 * (1 - index / @trail_length)}px; height: #{@ball_radius * 2 * (1 - index / @trail_length)}px; left: #{pos.x - @ball_radius * (1 - index / @trail_length)}px; top: #{pos.y - @ball_radius * (1 - index / @trail_length)}px; background-color: #{pos.color}; opacity: #{1 - index / @trail_length * 0.7}; filter: blur(#{index / 10}px);"}
                    >
                    </div>
                  <% end %>

                  <!-- Sparkles & Burst Particles -->
                  <%= for sparkle <- @sparkles do %>
                    <div
                      class="absolute"
                      style={"width: #{sparkle.size}px; height: #{sparkle.size}px; left: #{sparkle.x - sparkle.size/2}px; top: #{sparkle.y - sparkle.size/2}px; background-color: #{sparkle.color}; opacity: #{sparkle.life / @sparkle_life}; border-radius: #{if rem(sparkle.life, 2) == 0, do: "50%", else: "0"}; transform: rotate(#{sparkle.life * 5}deg); filter: blur(1px);"}
                    >
                    </div>
                  <% end %>

                  <!-- Paddle with gradient -->
                  <div
                    class="absolute"
                    style={"width: #{@paddle_width}px; height: #{@paddle_height}px; left: #{@paddle.x}px; top: #{@paddle.y}px;"}
                  >
                    <div class="w-full h-full bg-gradient-to-b from-fuchsia-500 via-purple-500 to-cyan-500 rounded-sm">
                    </div>
                  </div>

                  <!-- Ball with gradient -->
                  <div
                    class="absolute rounded-full bg-gradient-to-br from-fuchsia-500 via-purple-500 to-cyan-500"
                    style={"width: #{@ball_radius * 2}px; height: #{@ball_radius * 2}px; left: #{@ball.x - @ball_radius}px; top: #{@ball.y - @ball_radius}px; filter: drop-shadow(0 0 4px rgba(217, 70, 239, 0.5));"}
                  >
                  </div>
                </div>
              </div>
            </div>

            <div class="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-sm font-bold mt-4">
              Use the up and down arrow keys to move the paddle
            </div>

            <div class="mt-2">
              <a
                href={~p"/pong/god"}
                class="inline-block px-3 py-1 rounded-md bg-gradient-to-r from-fuchsia-500 via-purple-500 to-cyan-500 text-white font-bold hover:shadow-lg transition-shadow"
              >
                God Mode View
              </a>
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <span>Ready</span>
        </div>
      </div>
    </div>
    """
  end
end
