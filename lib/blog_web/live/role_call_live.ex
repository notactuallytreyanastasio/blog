defmodule BlogWeb.RoleCallLive do
  use BlogWeb, :live_view

  alias Blog.RoleCall

  @impl true
  def mount(_params, session, socket) do
    # Load liked shows from session or start empty
    liked_ids = Map.get(session, "role_call_liked", MapSet.new())
    hidden_ids = Map.get(session, "role_call_hidden", MapSet.new())

    {:ok,
     socket
     |> assign(:tab, :search)
     |> assign(:search_query, "")
     |> assign(:search_results, [])
     |> assign(:liked_ids, liked_ids)
     |> assign(:hidden_ids, hidden_ids)
     |> assign(:shuffle_picks, get_shuffle_picks(liked_ids, hidden_ids))
     |> assign(:recommendations, [])
     |> assign(:selected_show, nil)
     |> assign(:selected_writer, nil)
     |> assign(:show_count, RoleCall.count_shows())
     |> assign(:modal_show, nil)
     |> assign(:tour_step, nil)
     |> assign(:show_tour, false)
     |> assign(:cards_per_row, 6)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    tab = case params["tab"] do
      "liked" -> :liked
      "discover" -> :discover
      _ -> :search
    end

    socket = assign(socket, :tab, tab)

    # If liked tab, load recommendations
    socket = if tab == :liked do
      load_recommendations(socket)
    else
      socket
    end

    # Handle show modal
    socket = case params["show"] do
      nil -> assign(socket, :modal_show, nil)
      show_id -> assign(socket, :modal_show, RoleCall.get_show_with_credits(show_id))
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"query" => query}, socket) do
    results = if String.length(query) >= 2 do
      RoleCall.search_shows(query, limit: 15, exclude_ids: MapSet.to_list(socket.assigns.hidden_ids))
    else
      []
    end

    {:noreply, assign(socket, search_query: query, search_results: results)}
  end

  def handle_event("clear_search", _, socket) do
    {:noreply, assign(socket, search_query: "", search_results: [])}
  end

  def handle_event("like_show", %{"id" => show_id}, socket) do
    liked_ids = MapSet.put(socket.assigns.liked_ids, show_id)
    shuffle_picks = get_shuffle_picks(liked_ids, socket.assigns.hidden_ids)

    {:noreply,
     socket
     |> assign(:liked_ids, liked_ids)
     |> assign(:shuffle_picks, shuffle_picks)
     |> push_event("store_liked", %{ids: MapSet.to_list(liked_ids)})}
  end

  def handle_event("unlike_show", %{"id" => show_id}, socket) do
    liked_ids = MapSet.delete(socket.assigns.liked_ids, show_id)

    {:noreply,
     socket
     |> assign(:liked_ids, liked_ids)
     |> load_recommendations()
     |> push_event("store_liked", %{ids: MapSet.to_list(liked_ids)})}
  end

  def handle_event("hide_show", %{"id" => show_id}, socket) do
    hidden_ids = MapSet.put(socket.assigns.hidden_ids, show_id)
    shuffle_picks = get_shuffle_picks(socket.assigns.liked_ids, hidden_ids)

    {:noreply,
     socket
     |> assign(:hidden_ids, hidden_ids)
     |> assign(:shuffle_picks, shuffle_picks)
     |> push_event("store_hidden", %{ids: MapSet.to_list(hidden_ids)})}
  end

  def handle_event("refresh_shuffle", _, socket) do
    limit = socket.assigns.cards_per_row * 2
    shuffle_picks = get_shuffle_picks(socket.assigns.liked_ids, socket.assigns.hidden_ids, limit)
    {:noreply, assign(socket, :shuffle_picks, shuffle_picks)}
  end

  def handle_event("refresh_recommendations", _, socket) do
    {:noreply, load_recommendations(socket)}
  end

  def handle_event("clear_all", _, socket) do
    {:noreply,
     socket
     |> assign(:liked_ids, MapSet.new())
     |> assign(:hidden_ids, MapSet.new())
     |> assign(:recommendations, [])
     |> push_event("store_liked", %{ids: []})
     |> push_event("store_hidden", %{ids: []})}
  end

  def handle_event("open_show", %{"id" => show_id}, socket) do
    {:noreply, push_patch(socket, to: ~p"/role-call?#{%{tab: socket.assigns.tab, show: show_id}}")}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: ~p"/role-call?#{%{tab: socket.assigns.tab}}")}
  end

  def handle_event("select_writer", %{"id" => writer_id}, socket) do
    writer = RoleCall.get_person_with_shows(writer_id)
    {:noreply, assign(socket, :selected_writer, writer)}
  end

  def handle_event("clear_writer", _, socket) do
    {:noreply, assign(socket, :selected_writer, nil)}
  end

  def handle_event("restore_liked", %{"ids" => ids}, socket) do
    liked_ids = MapSet.new(ids)
    shuffle_picks = get_shuffle_picks(liked_ids, socket.assigns.hidden_ids)

    {:noreply,
     socket
     |> assign(:liked_ids, liked_ids)
     |> assign(:shuffle_picks, shuffle_picks)}
  end

  def handle_event("restore_hidden", %{"ids" => ids}, socket) do
    hidden_ids = MapSet.new(ids)
    shuffle_picks = get_shuffle_picks(socket.assigns.liked_ids, hidden_ids)

    {:noreply,
     socket
     |> assign(:hidden_ids, hidden_ids)
     |> assign(:shuffle_picks, shuffle_picks)}
  end

  # Tour events
  def handle_event("start_tour", _, socket) do
    {:noreply, assign(socket, show_tour: true, tour_step: 1)}
  end

  def handle_event("tour_next", _, socket) do
    next_step = socket.assigns.tour_step + 1
    if next_step > 5 do
      {:noreply,
       socket
       |> assign(show_tour: false, tour_step: nil)
       |> push_event("tour_completed", %{})}
    else
      {:noreply, assign(socket, tour_step: next_step)}
    end
  end

  def handle_event("tour_prev", _, socket) do
    prev_step = max(1, socket.assigns.tour_step - 1)
    {:noreply, assign(socket, tour_step: prev_step)}
  end

  def handle_event("skip_tour", _, socket) do
    {:noreply,
     socket
     |> assign(show_tour: false, tour_step: nil)
     |> push_event("tour_completed", %{})}
  end

  def handle_event("check_tour_status", %{"completed" => completed}, socket) do
    # If tour not completed and no liked shows, show tour
    should_show = not completed and MapSet.size(socket.assigns.liked_ids) == 0
    {:noreply, assign(socket, show_tour: should_show, tour_step: if(should_show, do: 1, else: nil))}
  end

  def handle_event("set_cards_per_row", %{"count" => count}, socket) do
    count = max(3, min(count, 10))  # Clamp between 3-10
    shuffle_picks = get_shuffle_picks(socket.assigns.liked_ids, socket.assigns.hidden_ids, count * 2)
    {:noreply, assign(socket, cards_per_row: count, shuffle_picks: shuffle_picks)}
  end

  defp get_shuffle_picks(liked_ids, hidden_ids, _limit \\ 20) do
    exclude = MapSet.union(liked_ids, hidden_ids) |> MapSet.to_list()
    # Always load 20, JS will hide excess beyond 2 rows
    RoleCall.get_random_shows(limit: 20, exclude_ids: exclude)
  end

  defp load_recommendations(socket) do
    liked_ids = MapSet.to_list(socket.assigns.liked_ids)
    exclude = MapSet.union(socket.assigns.liked_ids, socket.assigns.hidden_ids) |> MapSet.to_list()

    recommendations = RoleCall.get_recommendations(liked_ids, limit: 20, exclude_ids: exclude)
    assign(socket, :recommendations, recommendations)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <canvas id="sunflower-bg" phx-hook="SunflowerBackground"></canvas>
    <div class="role-call">
      <header class="rc-header">
        <h1>Role Call</h1>
        <p class="tagline">Discover new shows through the writers you love</p>
        <button class="tour-help-btn" phx-click="start_tour" title="Show tutorial">?</button>
      </header>

      <nav class="rc-tabs" id="tour-tabs">
        <.link patch={~p"/role-call?tab=search"} class={"rc-tab #{if @tab == :search, do: "active"}"}>
          Search
        </.link>
        <.link patch={~p"/role-call?tab=liked"} class={"rc-tab #{if @tab == :liked, do: "active"}"} id="tour-liked-tab">
          Liked (<%= MapSet.size(@liked_ids) %>)
        </.link>
        <.link patch={~p"/role-call?tab=discover"} class={"rc-tab #{if @tab == :discover, do: "active"}"}>
          Discover
        </.link>
      </nav>

      <main class="rc-main">
        <%= case @tab do %>
          <% :search -> %>
            <.search_view
              search_query={@search_query}
              search_results={@search_results}
              shuffle_picks={@shuffle_picks}
              liked_ids={@liked_ids}
              show_count={@show_count}
            />
          <% :liked -> %>
            <.liked_view
              liked_ids={@liked_ids}
              recommendations={@recommendations}
            />
          <% :discover -> %>
            <.discover_view
              recommendations={@recommendations}
              liked_ids={@liked_ids}
            />
        <% end %>
      </main>

      <%= if @modal_show do %>
        <.rc_modal show={@modal_show} liked_ids={@liked_ids} selected_writer={@selected_writer} />
      <% end %>

      <%= if @show_tour do %>
        <.tour_overlay step={@tour_step} />
      <% end %>
    </div>

    <style>
      <%= raw(styles()) %>
    </style>

    <script>
      // Restore liked/hidden from localStorage on page load
      window.addEventListener("phx:page-loading-stop", () => {
        const liked = JSON.parse(localStorage.getItem("role_call_liked") || "[]");
        const hidden = JSON.parse(localStorage.getItem("role_call_hidden") || "[]");
        const tourCompleted = localStorage.getItem("role_call_tour_completed") === "true";

        if (liked.length > 0) {
          window.liveSocket.execJS(document.body, JSON.stringify([["push", {event: "restore_liked", data: {ids: liked}}]]));
        }
        if (hidden.length > 0) {
          window.liveSocket.execJS(document.body, JSON.stringify([["push", {event: "restore_hidden", data: {ids: hidden}}]]));
        }

        // Check if we should show tour
        window.liveSocket.execJS(document.body, JSON.stringify([["push", {event: "check_tour_status", data: {completed: tourCompleted}}]]));
      }, {once: true});

      // Store to localStorage when changed
      window.addEventListener("phx:store_liked", (e) => {
        localStorage.setItem("role_call_liked", JSON.stringify(e.detail.ids));
      });
      window.addEventListener("phx:store_hidden", (e) => {
        localStorage.setItem("role_call_hidden", JSON.stringify(e.detail.ids));
      });
      window.addEventListener("phx:tour_completed", () => {
        localStorage.setItem("role_call_tour_completed", "true");
      });
    </script>
    """
  end

  defp search_view(assigns) do
    ~H"""
    <section class="rc-search-view">
      <div class="search-container" id="tour-search">
        <div class="search-input-wrapper">
          <input
            type="text"
            id="show-search"
            placeholder="Search shows..."
            value={@search_query}
            phx-keyup="search"
            phx-value-query={@search_query}
            phx-debounce="300"
            autocomplete="off"
          />
          <%= if @search_query != "" do %>
            <button class="search-clear-btn" phx-click="clear_search">&times;</button>
          <% end %>
        </div>

        <%= if @search_results != [] do %>
          <div class="search-results">
            <%= for show <- @search_results do %>
              <div class="search-result" phx-click="open_show" phx-value-id={show.id}>
                <div class="result-title"><%= show.title %></div>
                <div class="result-meta">
                  <%= show.year_start %> <%= if show.imdb_rating, do: "★ #{Float.round(show.imdb_rating, 1)}" %>
                </div>
                <button class="like-btn" phx-click="like_show" phx-value-id={show.id}>
                  <%= if MapSet.member?(@liked_ids, show.id), do: "♥", else: "♡" %>
                </button>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>

      <div class="search-hint">
        <p>Search from <%= format_number(@show_count) %> shows. Click one to see what else its writers have made.</p>
      </div>

      <div class="shuffle-section" id="tour-shuffle">
        <div class="shuffle-header">
          <h3>Or pick one of these</h3>
          <button class="shuffle-refresh-btn" phx-click="refresh_shuffle" id="tour-shuffle-btn">Show me more</button>
        </div>
        <div class="shuffle-picks" id="tour-cards" phx-hook="CardGrid">
          <%= for {show, idx} <- Enum.with_index(@shuffle_picks) do %>
            <div id={"tour-card-#{idx}"} class="card-wrapper">
              <.show_card show={show} liked_ids={@liked_ids} />
            </div>
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  defp liked_view(assigns) do
    ~H"""
    <section class="rc-liked-view">
      <div class="liked-header">
        <div class="liked-header-top">
          <h2>Shows I've Liked</h2>
          <%= if MapSet.size(@liked_ids) > 0 do %>
            <button class="clear-all-btn" phx-click="clear_all">Start fresh</button>
          <% end %>
        </div>
        <p class="subtitle">Mark shows you enjoyed — their writers become part of your taste profile</p>
      </div>

      <div class="liked-grid">
        <div class="foryou-section">
          <div class="foryou-header">
            <h3>For You</h3>
            <button class="foryou-refresh-btn" phx-click="refresh_recommendations">Refresh</button>
          </div>
          <div class="foryou-content">
            <%= if @recommendations == [] do %>
              <div class="foryou-empty">Mark shows you've liked to unlock recommendations based on their writers</div>
            <% else %>
              <div class="foryou-grid">
                <%= for show <- @recommendations do %>
                  <.show_card show={show} liked_ids={@liked_ids} compact={true} />
                <% end %>
              </div>
            <% end %>
          </div>
        </div>

        <div class="liked-list-section">
          <h3>Your liked shows (<%= MapSet.size(@liked_ids) %>)</h3>
          <div class="liked-list">
            <%= if MapSet.size(@liked_ids) == 0 do %>
              <p class="empty-state">No shows liked yet. Search or pick from suggestions above!</p>
            <% else %>
              <%= for show_id <- MapSet.to_list(@liked_ids) do %>
                <% show = Blog.RoleCall.get_show(show_id) %>
                <%= if show do %>
                  <div class="liked-item">
                    <span class="liked-title" phx-click="open_show" phx-value-id={show.id}><%= show.title %></span>
                    <button class="unlike-btn" phx-click="unlike_show" phx-value-id={show.id}>×</button>
                  </div>
                <% end %>
              <% end %>
            <% end %>
          </div>
        </div>
      </div>
    </section>
    """
  end

  defp discover_view(assigns) do
    ~H"""
    <section class="rc-discover-view">
      <div class="discover-prompt">
        <h2>Shows you'll love</h2>
        <p>Based on writers from shows you've liked</p>
      </div>

      <div class="discover-picks">
        <%= if @recommendations == [] do %>
          <div class="discover-empty">
            <p>Like some shows first to get personalized recommendations!</p>
            <.link patch={~p"/role-call?tab=search"} class="discover-cta">Go to Search</.link>
          </div>
        <% else %>
          <%= for show <- Enum.take(@recommendations, 12) do %>
            <.show_card show={show} liked_ids={@liked_ids} />
          <% end %>
        <% end %>
      </div>

      <div class="discover-buttons">
        <button class="refresh-btn" phx-click="refresh_recommendations">Show me different ones</button>
      </div>
    </section>
    """
  end

  defp show_card(assigns) do
    assigns = assign_new(assigns, :compact, fn -> false end)
    assigns = assign(assigns, :writers, Map.get(assigns.show, :writers, []))

    ~H"""
    <div class={"show-card #{if @compact, do: "compact"}"}>
      <div class="card-image" phx-click="open_show" phx-value-id={@show.id}>
        <%= if @show.image_url do %>
          <img
            src={thumb(@show.image_url)}
            alt={@show.title}
            onerror="this.style.display='none';this.nextElementSibling.style.display='flex';"
          />
          <span class="placeholder" style="display:none;">📺</span>
        <% else %>
          <span class="placeholder">📺</span>
        <% end %>
      </div>
      <div class="card-info">
        <div class="card-title" phx-click="open_show" phx-value-id={@show.id}><%= @show.title %></div>
        <div class="card-meta">
          <%= @show.year_start %> <%= if @show.imdb_rating, do: "★ #{Float.round(@show.imdb_rating, 1)}" %>
        </div>
        <%= if length(@writers) > 0 do %>
          <div class="card-writers">
            <%= Enum.map_join(Enum.take(@writers, 2), ", ", & &1.name) %>
          </div>
        <% end %>
        <div class="card-actions">
          <button class="hide-btn" phx-click="hide_show" phx-value-id={@show.id} title="Hide">✕</button>
          <button class="like-btn" phx-click="like_show" phx-value-id={@show.id} title="Like">
            <%= if MapSet.member?(@liked_ids, @show.id), do: "♥", else: "♡" %>
          </button>
        </div>
      </div>
    </div>
    """
  end

  defp rc_modal(assigns) do
    assigns = assign(assigns, :writers, Enum.filter(assigns.show.credits, & &1.role in ["creator", "writer"]))

    ~H"""
    <div class="modal-overlay" phx-click="close_modal">
      <div class="modal" phx-click-away="close_modal">
        <button class="modal-close" phx-click="close_modal">&times;</button>

        <div class="modal-body">
          <%= if @selected_writer do %>
            <.writer_detail writer={@selected_writer} liked_ids={@liked_ids} />
          <% else %>
            <.show_detail show={@show} writers={@writers} liked_ids={@liked_ids} />
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp show_detail(assigns) do
    ~H"""
    <div class="show-detail">
      <div class="show-header">
        <%= if @show.image_url do %>
          <img src={@show.image_url} alt={@show.title} class="show-poster" />
        <% end %>
        <div class="show-info">
          <h2><%= @show.title %></h2>
          <div class="show-meta">
            <%= @show.year_start %><%= if @show.year_end && @show.year_end != @show.year_start, do: "–#{@show.year_end}" %>
            <%= if @show.imdb_rating do %>
              <span class="rating">★ <%= Float.round(@show.imdb_rating, 1) %></span>
            <% end %>
          </div>
          <%= if @show.description do %>
            <p class="show-desc"><%= @show.description %></p>
          <% end %>
          <button class="modal-like-btn" phx-click="like_show" phx-value-id={@show.id}>
            <%= if MapSet.member?(@liked_ids, @show.id), do: "♥ Liked", else: "♡ Like this show" %>
          </button>
        </div>
      </div>

      <%= if length(@writers) > 0 do %>
        <div class="writers-section">
          <h3>Writers & Creators</h3>
          <p class="writers-hint">Click a writer to see their other work</p>
          <div class="writers-grid">
            <%= for credit <- @writers do %>
              <div class="writer-card" phx-click="select_writer" phx-value-id={credit.person.id}>
                <span class="writer-name"><%= credit.person.name %></span>
                <span class="writer-role"><%= credit.role %></span>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp writer_detail(assigns) do
    ~H"""
    <div class="writer-detail">
      <button class="back-btn" phx-click="clear_writer">← Back to show</button>
      <h2><%= @writer.name %></h2>
      <p class="writer-subtitle">Their work</p>

      <div class="writer-shows">
        <%= for credit <- @writer.credits do %>
          <div class="writer-show-item" phx-click="open_show" phx-value-id={credit.show.id}>
            <span class="show-title"><%= credit.show.title %></span>
            <span class="show-meta">
              <%= credit.show.year_start %>
              <%= if credit.show.imdb_rating, do: "★ #{Float.round(credit.show.imdb_rating, 1)}" %>
            </span>
            <button class="like-btn" phx-click="like_show" phx-value-id={credit.show.id}>
              <%= if MapSet.member?(@liked_ids, credit.show.id), do: "♥", else: "♡" %>
            </button>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp tour_overlay(assigns) do
    steps = [
      %{
        title: "Welcome to Role Call!",
        text: "Discover new TV shows based on the writers behind shows you already love. Let's take a quick tour!",
        target: nil,
        position: :center
      },
      %{
        title: "Search for Shows",
        text: "Type the name of any show you've enjoyed. We have over 58,000 shows in our database!",
        target: "tour-search",
        position: :bottom
      },
      %{
        title: "Or Browse Random Picks",
        text: "Not sure where to start? Check out these random suggestions. Click 'Show me more' for fresh picks.",
        target: "tour-shuffle",
        position: :top
      },
      %{
        title: "Like Shows You Enjoy",
        text: "Click the heart to like a show. This teaches us your taste in writers.",
        target: "tour-card-0",
        position: :right
      },
      %{
        title: "Get Personalized Recommendations",
        text: "Once you've liked a few shows, head to the 'Liked' tab to see recommendations based on shared writers. Happy discovering!",
        target: "tour-liked-tab",
        position: :bottom
      }
    ]

    current = Enum.at(steps, assigns.step - 1)
    assigns = assign(assigns, :current, current)
    assigns = assign(assigns, :total, length(steps))

    ~H"""
    <div class="tour-overlay">
      <div class="tour-backdrop" phx-click="skip_tour"></div>

      <%= if @current.target do %>
        <div
          class="tour-spotlight"
          id="tour-spotlight"
          phx-hook="TourSpotlight"
          data-target={@current.target}
        >
        </div>
      <% end %>

      <div class={"tour-tooltip #{@current.position}"} id="tour-tooltip" data-target={@current.target}>
        <div class="tour-progress">
          Step <%= @step %> of <%= @total %>
        </div>
        <h3 class="tour-title"><%= @current.title %></h3>
        <p class="tour-text"><%= @current.text %></p>
        <div class="tour-buttons">
          <button class="tour-skip" phx-click="skip_tour">Skip tour</button>
          <div class="tour-nav">
            <%= if @step > 1 do %>
              <button class="tour-prev" phx-click="tour_prev">Back</button>
            <% end %>
            <button class="tour-next" phx-click="tour_next">
              <%= if @step == @total, do: "Let's go!", else: "Next" %>
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp thumb(url) when is_binary(url) do
    # IMDB image URLs can be resized by modifying the path
    String.replace(url, ~r/@.*\./, "@._V1_SX200.")
  end
  defp thumb(_), do: nil

  defp format_number(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.join(",")
    |> String.reverse()
  end
  defp format_number(n), do: to_string(n)

  defp styles do
    """
    body:has(.role-call) {
      background: #1a1a2e !important;
    }

    #sunflower-bg {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      z-index: 0;
      pointer-events: none;
    }

    .role-call {
      position: relative;
      z-index: 1;
      min-height: 100vh;
      background: transparent;
      color: #fff;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      padding: 20px;
    }

    .rc-header {
      text-align: center;
      margin-bottom: 24px;
    }

    .rc-header h1 {
      font-size: 2.5rem;
      margin: 0;
      color: #fff;
      text-shadow: 0 0 20px rgba(102, 126, 234, 0.8), 0 0 40px rgba(118, 75, 162, 0.6);
    }

    .tagline {
      color: #fff;
      margin-top: 8px;
      text-shadow: 0 0 10px rgba(0,0,0,0.5);
    }

    .rc-tabs {
      display: flex;
      justify-content: center;
      gap: 8px;
      margin-bottom: 24px;
    }

    .rc-tab {
      padding: 10px 24px;
      border-radius: 20px;
      background: rgba(42, 42, 74, 0.8);
      color: #fff;
      text-decoration: none;
      transition: all 0.2s;
      text-shadow: 0 0 10px rgba(0,0,0,0.5);
    }

    .rc-tab:hover {
      background: rgba(58, 58, 90, 0.9);
      color: #fff;
    }

    .rc-tab.active {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
    }

    .rc-main {
      max-width: 1200px;
      margin: 0 auto;
    }

    /* Search View */
    .search-container {
      max-width: 600px;
      margin: 0 auto 24px;
    }

    .search-input-wrapper {
      position: relative;
    }

    .search-input-wrapper input {
      width: 100%;
      padding: 14px 20px;
      font-size: 16px;
      border: 2px solid #3a3a5a;
      border-radius: 12px;
      background: rgba(42, 42, 74, 0.85);
      color: #fff;
      outline: none;
    }

    .search-input-wrapper input:focus {
      border-color: #667eea;
    }

    .search-clear-btn {
      position: absolute;
      right: 12px;
      top: 50%;
      transform: translateY(-50%);
      background: none;
      border: none;
      color: #ddd;
      font-size: 20px;
      cursor: pointer;
    }

    .search-results {
      background: rgba(42, 42, 74, 0.85);
      border-radius: 12px;
      margin-top: 8px;
      overflow: hidden;
    }

    .search-result {
      display: flex;
      align-items: center;
      padding: 12px 16px;
      cursor: pointer;
      border-bottom: 1px solid #3a3a5a;
    }

    .search-result:hover {
      background: #3a3a5a;
    }

    .result-title {
      flex: 1;
      font-weight: 500;
    }

    .result-meta {
      color: #fff;
      font-size: 14px;
      margin-right: 12px;
    }

    .search-hint {
      text-align: center;
      color: #ddd;
      margin-bottom: 32px;
    }

    .shuffle-section {
      margin-top: 32px;
    }

    .shuffle-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }

    .shuffle-header h3 {
      margin: 0;
      color: #fff;
    }

    .shuffle-refresh-btn, .foryou-refresh-btn, .refresh-btn {
      padding: 8px 16px;
      border-radius: 8px;
      background: #3a3a5a;
      border: none;
      color: #fff;
      cursor: pointer;
    }

    .shuffle-refresh-btn:hover, .foryou-refresh-btn:hover, .refresh-btn:hover {
      background: #4a4a6a;
    }

    .shuffle-picks, .discover-picks, .foryou-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
      gap: 16px;
    }

    /* Show Cards */
    .show-card {
      background: rgba(42, 42, 74, 0.85);
      border-radius: 12px;
      overflow: hidden;
      transition: transform 0.2s;
    }

    .show-card:hover {
      transform: translateY(-4px);
    }

    .card-image {
      aspect-ratio: 2/3;
      background: #3a3a5a;
      display: flex;
      align-items: center;
      justify-content: center;
      cursor: pointer;
    }

    .card-image img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }

    .card-image .placeholder {
      color: #ddd;
      font-size: 24px;
    }

    .card-info {
      padding: 12px;
    }

    .card-title {
      font-weight: 600;
      margin-bottom: 4px;
      cursor: pointer;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .card-meta {
      color: #fff;
      font-size: 13px;
      margin-bottom: 4px;
    }

    .card-writers {
      color: #667eea;
      font-size: 12px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }

    .card-actions {
      display: flex;
      gap: 8px;
      margin-top: 8px;
    }

    .hide-btn, .like-btn, .unlike-btn {
      padding: 6px 12px;
      border-radius: 6px;
      border: none;
      cursor: pointer;
      font-size: 14px;
    }

    .hide-btn {
      background: #3a3a5a;
      color: #fff;
    }

    .like-btn {
      background: #3a3a5a;
      color: #e74c3c;
    }

    .unlike-btn {
      background: transparent;
      color: #fff;
      padding: 4px 8px;
    }

    .like-btn:hover, .hide-btn:hover {
      background: #4a4a6a;
    }

    /* Liked View */
    .liked-header {
      margin-bottom: 24px;
    }

    .liked-header-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .liked-header h2 {
      margin: 0;
    }

    .clear-all-btn {
      padding: 8px 16px;
      border-radius: 8px;
      background: #e74c3c;
      border: none;
      color: #fff;
      cursor: pointer;
    }

    .subtitle {
      color: #fff;
      margin-top: 8px;
    }

    .liked-grid {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 24px;
    }

    @media (max-width: 768px) {
      .liked-grid {
        grid-template-columns: 1fr;
      }
    }

    .foryou-section {
      background: rgba(42, 42, 74, 0.85);
      border-radius: 12px;
      padding: 20px;
    }

    .foryou-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }

    .foryou-header h3 {
      margin: 0;
    }

    .foryou-empty {
      color: #ddd;
      text-align: center;
      padding: 40px;
    }

    .liked-list-section {
      background: rgba(42, 42, 74, 0.85);
      border-radius: 12px;
      padding: 20px;
    }

    .liked-list-section h3 {
      margin: 0 0 16px;
    }

    .liked-list {
      max-height: 400px;
      overflow-y: auto;
    }

    .liked-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 0;
      border-bottom: 1px solid #3a3a5a;
    }

    .liked-title {
      cursor: pointer;
    }

    .liked-title:hover {
      color: #667eea;
    }

    .empty-state {
      color: #ddd;
    }

    /* Discover View */
    .discover-prompt {
      text-align: center;
      margin-bottom: 24px;
    }

    .discover-prompt h2 {
      margin: 0;
    }

    .discover-prompt p {
      color: #fff;
    }

    .discover-empty {
      text-align: center;
      padding: 60px;
      color: #fff;
    }

    .discover-cta {
      display: inline-block;
      margin-top: 16px;
      padding: 12px 24px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
      text-decoration: none;
      border-radius: 8px;
    }

    .discover-buttons {
      text-align: center;
      margin-top: 24px;
    }

    /* Modal */
    .modal-overlay {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.8);
      display: flex;
      align-items: center;
      justify-content: center;
      z-index: 1000;
      padding: 20px;
    }

    .modal {
      background: rgba(42, 42, 74, 0.85);
      border-radius: 16px;
      max-width: 700px;
      width: 100%;
      max-height: 80vh;
      overflow-y: auto;
      position: relative;
    }

    .modal-close {
      position: absolute;
      top: 16px;
      right: 16px;
      background: none;
      border: none;
      color: #fff;
      font-size: 28px;
      cursor: pointer;
      z-index: 10;
    }

    .modal-body {
      padding: 24px;
    }

    .show-header {
      display: flex;
      gap: 20px;
    }

    .show-poster {
      width: 150px;
      border-radius: 8px;
    }

    .show-info {
      flex: 1;
    }

    .show-info h2 {
      margin: 0 0 8px;
    }

    .show-meta {
      color: #fff;
      margin-bottom: 12px;
    }

    .show-meta .rating {
      color: #f1c40f;
      margin-left: 8px;
    }

    .show-desc {
      color: #fff;
      line-height: 1.5;
    }

    .modal-like-btn {
      margin-top: 16px;
      padding: 10px 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      color: #fff;
      border-radius: 8px;
      cursor: pointer;
      font-size: 15px;
    }

    .writers-section {
      margin-top: 24px;
      padding-top: 24px;
      border-top: 1px solid #3a3a5a;
    }

    .writers-section h3 {
      margin: 0 0 4px;
    }

    .writers-hint {
      color: #ddd;
      font-size: 13px;
      margin-bottom: 16px;
    }

    .writers-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
      gap: 12px;
    }

    .writer-card {
      background: #3a3a5a;
      padding: 12px;
      border-radius: 8px;
      cursor: pointer;
      text-align: center;
    }

    .writer-card:hover {
      background: #4a4a6a;
    }

    .writer-name {
      display: block;
      font-weight: 500;
      margin-bottom: 4px;
    }

    .writer-role {
      font-size: 12px;
      color: #fff;
      text-transform: capitalize;
    }

    /* Writer Detail */
    .writer-detail .back-btn {
      background: none;
      border: none;
      color: #667eea;
      cursor: pointer;
      padding: 0;
      margin-bottom: 16px;
    }

    .writer-detail h2 {
      margin: 0;
    }

    .writer-subtitle {
      color: #fff;
      margin-bottom: 16px;
    }

    .writer-shows {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .writer-show-item {
      display: flex;
      align-items: center;
      padding: 12px;
      background: #3a3a5a;
      border-radius: 8px;
      cursor: pointer;
    }

    .writer-show-item:hover {
      background: #4a4a6a;
    }

    .writer-show-item .show-title {
      flex: 1;
      font-weight: 500;
    }

    .writer-show-item .show-meta {
      color: #fff;
      font-size: 13px;
      margin-right: 12px;
    }

    /* Compact cards */
    .show-card.compact {
      font-size: 13px;
    }

    .show-card.compact .card-info {
      padding: 8px;
    }

    /* Tour Help Button */
    .tour-help-btn {
      position: absolute;
      top: 20px;
      right: 20px;
      width: 32px;
      height: 32px;
      border-radius: 50%;
      background: #3a3a5a;
      border: 2px solid #667eea;
      color: #667eea;
      font-size: 16px;
      font-weight: bold;
      cursor: pointer;
      transition: all 0.2s;
    }

    .tour-help-btn:hover {
      background: #667eea;
      color: #fff;
    }

    .rc-header {
      position: relative;
    }

    /* Tour Overlay */
    .tour-overlay {
      position: fixed;
      inset: 0;
      z-index: 2000;
      pointer-events: none;
    }

    .tour-backdrop {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.7);
      pointer-events: auto;
    }

    .tour-spotlight {
      position: fixed;
      border-radius: 8px;
      box-shadow: 0 0 0 9999px rgba(0, 0, 0, 0.7);
      pointer-events: none;
      transition: all 0.3s ease;
      z-index: 2001;
    }

    .tour-tooltip {
      position: fixed;
      background: rgba(42, 42, 74, 0.85);
      border: 2px solid #667eea;
      border-radius: 12px;
      padding: 20px;
      max-width: 360px;
      width: 90%;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
      pointer-events: auto;
      z-index: 2002;
      animation: tour-fade-in 0.3s ease;
    }

    @keyframes tour-fade-in {
      from { opacity: 0; transform: translateY(10px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .tour-tooltip.center {
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
    }

    .tour-tooltip.bottom {
      /* Positioned by JS hook */
    }

    .tour-tooltip.top {
      /* Positioned by JS hook */
    }

    .tour-tooltip.right {
      /* Positioned by JS hook */
    }

    .tour-tooltip::before {
      content: '';
      position: absolute;
      width: 12px;
      height: 12px;
      background: rgba(42, 42, 74, 0.85);
      border: 2px solid #667eea;
      transform: rotate(45deg);
    }

    .tour-tooltip.center::before {
      display: none;
    }

    .tour-tooltip.bottom::before {
      top: -8px;
      left: 50%;
      margin-left: -6px;
      border-right: none;
      border-bottom: none;
    }

    .tour-tooltip.top::before {
      bottom: -8px;
      left: 50%;
      margin-left: -6px;
      border-left: none;
      border-top: none;
    }

    .tour-tooltip.right::before {
      left: -8px;
      top: 50%;
      margin-top: -6px;
      border-right: none;
      border-top: none;
    }

    .tour-progress {
      font-size: 12px;
      color: #fff;
      margin-bottom: 8px;
    }

    .tour-title {
      margin: 0 0 8px;
      font-size: 18px;
      color: #fff;
    }

    .tour-text {
      margin: 0 0 16px;
      color: #fff;
      line-height: 1.5;
    }

    .tour-buttons {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .tour-skip {
      background: none;
      border: none;
      color: #ddd;
      cursor: pointer;
      font-size: 13px;
    }

    .tour-skip:hover {
      color: #fff;
    }

    .tour-nav {
      display: flex;
      gap: 8px;
    }

    .tour-prev {
      padding: 8px 16px;
      border-radius: 8px;
      background: #3a3a5a;
      border: none;
      color: #fff;
      cursor: pointer;
    }

    .tour-next {
      padding: 8px 20px;
      border-radius: 8px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border: none;
      color: #fff;
      cursor: pointer;
      font-weight: 500;
    }

    .tour-prev:hover {
      background: #4a4a6a;
    }

    .tour-next:hover {
      opacity: 0.9;
    }
    """
  end
end
