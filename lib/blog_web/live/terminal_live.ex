defmodule BlogWeb.TerminalLive do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias Blog.Chat
  require Logger

  @presence_topic "terminal_presence"

  @tour_steps_base [
    %{
      target: "toys-section",
      title: "Fun Toys & Art",
      content: "These are fun toys or art generators.",
      placement: :bottom
    },
    %{
      target: "bluesky-section",
      title: "Bluesky Feeds",
      content: "These are atproto firehose toys.",
      placement: :bottom
    },
    %{
      target: "nathan-section",
      title: "Nathan Fielder",
      content: "Writing experiments with regard to Nathan Fielder.",
      placement: :bottom
    },
    %{
      target: "trees-item",
      title: "Tree Law",
      content: "Tree law, brother.",
      placement: :bottom
    },
    %{
      target: "receipt-item",
      title: "Receipt Printer",
      content: "Send me a very literal DM to my desk.",
      placement: :bottom
    },
    %{
      target: "utilities-section",
      title: "Utilities",
      content: "Silly or helpful little utilities.",
      placement: :bottom
    }
  ]

  @name_dialog_step %{
    target: "aim-name-dialog",
    title: "Pick Your Screen Name",
    content: "Choose a name for the chat - it'll stick around for next time!",
    placement: :left
  }

  @chat_window_step %{
    target: "chat-window",
    title: "Leave a Note!",
    content: "Say hi in the chatroom - messages persist so I'll see them later!",
    placement: :left
  }

  # Build tour steps - include name dialog step only if dialog is visible
  defp build_tour_steps(chatter) do
    if is_nil(chatter) do
      [@name_dialog_step, @chat_window_step | @tour_steps_base]
    else
      [@chat_window_step | @tour_steps_base]
    end
  end

  # Icon sections and items are now loaded from the database.
  # Manage them at /admin/finder

  def mount(params, session, socket) do
    # Get visitor's IP from session (set by RemoteIp plug)
    visitor_ip = Map.get(session, "remote_ip", "unknown")

    # Check for returning chatter by IP hash
    ip_hash = Chat.hash_ip(visitor_ip)
    returning_chatter = if ip_hash, do: Chat.get_chatter_by_ip(ip_hash), else: nil

    # Don't set chatter yet - user needs to confirm their name first via the dialog
    # We track returning_chatter separately to show "Welcome back!" message
    reader_id =
      if connected?(socket) do
        id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

        # If returning chatter exists, use their color; otherwise generate new
        color =
          if returning_chatter,
            do: returning_chatter.color,
            else: Blog.Chat.Chatter.random_color()

        display_name = if returning_chatter, do: returning_chatter.screen_name, else: nil

        {:ok, _} =
          Presence.track(self(), @presence_topic, id, %{
            joined_at: DateTime.utc_now(),
            color: color,
            display_name: display_name
          })

        # Subscribe to presence and chat topics
        Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
        Phoenix.PubSub.subscribe(Blog.PubSub, Chat.topic())
        Phoenix.PubSub.subscribe(Blog.PubSub, "github:work_log")

        id
      else
        nil
      end

    # chatter is nil until they confirm via save_name or skip_name
    chatter = nil

    # Get online users from presence
    visitor_list =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    # Get messages from Postgres
    messages = Chat.list_messages("terminal")

    # Get blog posts
    blog_posts = Blog.Content.Post.all() |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime})

    # Load icon sections from database
    sections = Blog.Finder.list_sections_with_items()
    all_items = Enum.flat_map(sections, & &1.items)

    # Load museum projects
    museum_projects = Blog.Museum.Projects.all()

    # Schedule boot transition if connected
    if connected?(socket) do
      Process.send_after(self(), :boot_complete, 8000)
    end

    {:ok,
     assign(socket,
       sections: sections,
       programs: all_items,
       selected: nil,
       time: format_time(),
       # Boot phase - :splash or :desktop
       boot_phase: if(connected?(socket), do: :splash, else: :desktop),
       # Blog posts
       blog_posts: blog_posts,
       # Museum state
       museum_projects: museum_projects,
       museum_categories: Blog.Museum.Projects.categories(),
       museum_selected_project: nil,
       museum_category_filter: nil,
       show_museum: true,
       show_finder: false,
       # Chat state
       reader_id: reader_id,
       visitor_ip: visitor_ip,
       chatter: chatter,
       returning_chatter: returning_chatter,
       show_chat: false,
       name_form: %{"name" => if(returning_chatter, do: returning_chatter.screen_name, else: "")},
       chat_messages: messages,
       chat_form: %{"message" => ""},
       visitor_list: visitor_list,
       total_online: map_size(visitor_list),
       # Phish window state
       show_phish: true,
       # Tree state
       show_tree: false,
       # Work Log
       show_work_log: false,
       work_log_events: Blog.GitHub.WorkLog.list_recent(),
       # Leica collage viewer state: false | :warning | :loading | :viewing
       # ?leica=1 skips warning and starts loading immediately
       show_leica: if(params["leica"], do: :loading, else: false),
       # Tour state - auto-start for first-time visitors (desktop only)
       show_tour: is_nil(returning_chatter),
       tour_steps: build_tour_steps(chatter),
       # Mobile state - which window is active on mobile
       # Options: :finder, :chat, :name_dialog, :blog, :phish, :museum
       mobile_window: :museum
     )}
  end

  def handle_info(:boot_complete, socket) do
    {:noreply, assign(socket, boot_phase: :desktop)}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 60000)
    {:noreply, assign(socket, time: format_time())}
  end

  defp format_time do
    Calendar.strftime(DateTime.utc_now(), "%I:%M %p")
  end

  def handle_event("select", %{"name" => name}, socket) do
    {:noreply, assign(socket, selected: name)}
  end

  def handle_event("open", %{"path" => path}, socket) do
    {:noreply, push_navigate(socket, to: path)}
  end

  def handle_event("open", _params, socket) do
    {:noreply, socket}
  end

  # Phish window toggle
  def handle_event("toggle_phish", _params, socket) do
    {:noreply, assign(socket, show_phish: !socket.assigns.show_phish)}
  end

  # Work Log window toggle
  def handle_event("toggle_work_log", _params, socket) do
    {:noreply, assign(socket, show_work_log: !socket.assigns.show_work_log)}
  end

  # Museum events
  def handle_event("museum_select", %{"slug" => slug}, socket) do
    project = Blog.Museum.Projects.get_by_slug(slug)
    {:noreply, assign(socket, museum_selected_project: project)}
  end

  def handle_event("museum_close_detail", _params, socket) do
    {:noreply, assign(socket, museum_selected_project: nil)}
  end

  def handle_event("museum_filter", %{"category" => "all"}, socket) do
    {:noreply,
     assign(socket,
       museum_projects: Blog.Museum.Projects.all(),
       museum_category_filter: nil
     )}
  end

  def handle_event("museum_filter", %{"category" => cat}, socket) do
    {:noreply,
     assign(socket,
       museum_projects: Blog.Museum.Projects.by_category(cat),
       museum_category_filter: cat
     )}
  end

  def handle_event("toggle_museum", _params, socket) do
    {:noreply, assign(socket, show_museum: !socket.assigns.show_museum)}
  end

  def handle_event("toggle_finder", _params, socket) do
    {:noreply, assign(socket, show_finder: !socket.assigns.show_finder)}
  end

  def handle_event("skip_splash", _params, socket) do
    {:noreply, assign(socket, boot_phase: :desktop)}
  end

  # Tree event handler
  def handle_event("toggle_tree", _params, socket) do
    {:noreply, assign(socket, show_tree: !socket.assigns.show_tree)}
  end

  # Leica collage viewer
  def handle_event("toggle_leica", _params, socket) do
    new_state = if socket.assigns.show_leica, do: false, else: :warning
    {:noreply, assign(socket, show_leica: new_state)}
  end

  def handle_event("confirm_leica", _params, socket) do
    {:noreply, assign(socket, show_leica: :loading)}
  end

  def handle_event("close_leica", _params, socket) do
    {:noreply, assign(socket, show_leica: false)}
  end

  def handle_event("leica_loaded", _params, socket) do
    {:noreply, assign(socket, show_leica: :viewing)}
  end

  # Chat event handlers
  def handle_event("toggle_chat", _params, socket) do
    new_show_chat = !socket.assigns.show_chat
    # When opening chat on mobile, show name dialog if no chatter set
    mobile_window =
      if new_show_chat && is_nil(socket.assigns.chatter) do
        :name_dialog
      else
        socket.assigns.mobile_window
      end

    {:noreply, assign(socket, show_chat: new_show_chat, mobile_window: mobile_window)}
  end

  def handle_event("save_name", %{"name" => name}, socket) do
    reader_id = socket.assigns.reader_id
    visitor_ip = socket.assigns.visitor_ip
    trimmed_name = String.trim(name)

    if reader_id && trimmed_name != "" do
      # Create or update chatter in Postgres
      case Chat.find_or_create_chatter(trimmed_name, visitor_ip) do
        {:ok, chatter} ->
          # Update presence with the chatter's info
          Presence.update(self(), @presence_topic, reader_id, fn meta ->
            meta
            |> Map.put(:display_name, chatter.screen_name)
            |> Map.put(:color, chatter.color)
          end)

          {:noreply,
           assign(socket,
             chatter: chatter,
             name_form: %{"name" => chatter.screen_name},
             tour_steps: build_tour_steps(chatter),
             mobile_window: :chat
           )}

        {:error, _changeset} ->
          # Handle error - keep dialog open
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_name", %{"name" => name}, socket) do
    {:noreply, assign(socket, name_form: %{"name" => name})}
  end

  def handle_event("skip_name", _params, socket) do
    # Skip creates an anonymous chatter
    visitor_ip = socket.assigns.visitor_ip
    anonymous_name = "Visitor#{:rand.uniform(9999)}"

    case Chat.find_or_create_chatter(anonymous_name, visitor_ip) do
      {:ok, chatter} ->
        reader_id = socket.assigns.reader_id

        if reader_id do
          Presence.update(self(), @presence_topic, reader_id, fn meta ->
            meta
            |> Map.put(:display_name, chatter.screen_name)
            |> Map.put(:color, chatter.color)
          end)
        end

        {:noreply,
         assign(socket,
           chatter: chatter,
           tour_steps: build_tour_steps(chatter),
           mobile_window: :chat
         )}

      {:error, _} ->
        {:noreply, assign(socket, chatter: nil)}
    end
  end

  def handle_event("send_chat_message", %{"message" => message}, socket) do
    chatter = socket.assigns.chatter
    trimmed_message = String.trim(message)

    if chatter && trimmed_message != "" do
      # Save to Postgres and broadcast
      case Chat.create_message(chatter, trimmed_message, "terminal") do
        {:ok, _message} ->
          # Get updated messages
          updated_messages = Chat.list_messages("terminal")

          {:noreply,
           assign(socket, chat_form: %{"message" => ""}, chat_messages: updated_messages)}

        {:error, _changeset} ->
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("validate_chat_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, chat_form: %{"message" => message})}
  end

  # Handle presence updates
  def handle_info(%{event: "presence_diff"}, socket) do
    visitor_list =
      Presence.list(@presence_topic)
      |> Enum.map(fn {id, %{metas: [meta | _]}} -> {id, meta} end)
      |> Enum.into(%{})

    {:noreply, assign(socket, visitor_list: visitor_list, total_online: map_size(visitor_list))}
  end

  # Handle new chat messages
  def handle_info({:new_chat_message, _message}, socket) do
    updated_messages = Chat.list_messages("terminal")
    {:noreply, assign(socket, chat_messages: updated_messages)}
  end

  # Handle Joyride tour completion
  def handle_info({:tour_complete, _id}, socket) do
    {:noreply, assign(socket, show_tour: false)}
  end

  def handle_info(:work_log_updated, socket) do
    {:noreply, assign(socket, work_log_events: Blog.GitHub.WorkLog.list_recent())}
  end

  # Tour controls
  def handle_event("start_tour", _params, socket) do
    {:noreply, assign(socket, show_tour: true)}
  end

  # Mobile window switching
  def handle_event("switch_mobile_window", %{"window" => window}, socket) do
    window_atom = String.to_existing_atom(window)

    # If switching to chat but user hasn't set name, show name dialog first
    {window_atom, show_chat, show_phish, show_museum, show_finder} =
      cond do
        window_atom == :chat ->
          if is_nil(socket.assigns.chatter) do
            {:name_dialog, true, socket.assigns.show_phish, socket.assigns.show_museum,
             socket.assigns.show_finder}
          else
            {:chat, true, socket.assigns.show_phish, socket.assigns.show_museum,
             socket.assigns.show_finder}
          end

        window_atom == :phish ->
          {:phish, socket.assigns.show_chat, true, socket.assigns.show_museum,
           socket.assigns.show_finder}

        window_atom == :museum ->
          {:museum, socket.assigns.show_chat, socket.assigns.show_phish, true,
           socket.assigns.show_finder}

        window_atom == :finder ->
          {:finder, socket.assigns.show_chat, socket.assigns.show_phish,
           socket.assigns.show_museum, true}

        true ->
          {window_atom, socket.assigns.show_chat, socket.assigns.show_phish,
           socket.assigns.show_museum, socket.assigns.show_finder}
      end

    {:noreply,
     assign(socket,
       mobile_window: window_atom,
       show_chat: show_chat,
       show_phish: show_phish,
       show_museum: show_museum,
       show_finder: show_finder
     )}
  end

  # Forward phish component events via send_update
  @phish_events ~w(change-year change-song change-sort change-min change-filter-text flip-card change-list-filter toggle-notes play-jam)
  def handle_event(event, params, socket) when event in @phish_events do
    send_update(BlogWeb.PhishComponent, id: "phish-embed", __event__: event, __params__: params)
    {:noreply, socket}
  end

  # Function component for rendering icon items
  defp icon_item(assigns) do
    # Support optional data-joyride on individual icons
    assigns = assign_new(assigns, :joyride, fn -> nil end)

    ~H"""
    <div
      class={"icon #{if @selected == @program.name, do: "selected"}"}
      phx-click="select"
      phx-value-name={@program.name}
      data-joyride={@joyride}
      phx-hook={if @program.description, do: "Tooltip"}
      data-tooltip={@program.description}
      id={if @program.description, do: "icon-#{@program.id}"}
    >
      <div class="icon-image" phx-click={if @program.path, do: "open"} phx-value-path={@program.path}>
        {@program.icon}
      </div>
      <div class="icon-label">{@program.name}</div>
    </div>
    """
  end

  defp category_label("hardware"), do: "Hardware"
  defp category_label("maps"), do: "Maps"
  defp category_label("ml"), do: "ML & AI"
  defp category_label("music"), do: "Music"
  defp category_label("social"), do: "Social"
  defp category_label("tools"), do: "Tools"
  defp category_label("writing"), do: "Writing"
  defp category_label(other), do: String.capitalize(other)

  def render(assigns) do
    ~H"""
    <%= if @boot_phase == :splash do %>
      <div class="mac-boot" phx-click="skip_splash">
        <div class="boot-screen">
          <div class="boot-logo">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 32 32"
              width="128"
              height="128"
              style="image-rendering: pixelated;"
            >
              <rect x="12" y="2" width="8" height="2" fill="#000" />
              <rect x="10" y="4" width="12" height="2" fill="#000" />
              <rect x="8" y="6" width="16" height="2" fill="#000" />
              <rect x="8" y="8" width="16" height="2" fill="#000" />
              <rect x="10" y="10" width="12" height="2" fill="#000" />
              <rect x="12" y="12" width="8" height="2" fill="#000" />
              <rect x="14" y="14" width="4" height="6" fill="#000" />
              <rect x="10" y="20" width="12" height="2" fill="#000" />
            </svg>
          </div>
          <div class="boot-text">Hi, this is Bobby's website</div>
          <div class="boot-subtext">
            I am a programmer, photographer, and artist living in NYC.<br />
            I prefer to use things in ways they were not intended, and evoke new directions of vision by playing with the social fabric that wraps us around a computer.
          </div>
          <div class="boot-progress">
            <div class="boot-progress-bar"></div>
          </div>
          <div class="boot-hint">Click anywhere to skip</div>
        </div>
      </div>
    <% else %>
      <div class="mac">
        <%!-- Joyride Tour Component --%>
        <.live_component
          module={LiveJoyride.Component}
          id="site-tour"
          steps={@tour_steps}
          run={@show_tour}
        />
        
    <!-- Menu Bar -->
        <div class="menu-bar">
          <div class="menu-left">
            <span class="apple-menu">&#63743;</span>
            <span class="menu-item">File</span>
            <span class="menu-item">Edit</span>
            <span class="menu-item">View</span>
            <span class="menu-item" phx-click="start_tour" style="cursor: pointer;">Tour</span>
          </div>
          <div class="menu-right">
            <span>{@time}</span>
          </div>
        </div>
        
    <!-- Desktop -->
        <div class="desktop">
          <!-- Mac Window (Finder) -->
          <%= if @show_finder do %>
            <div
              class={"window mobile-window-finder #{if @mobile_window == :finder, do: "mobile-active"}"}
              phx-hook="Draggable"
              id="finder-window"
            >
              <div class="title-bar">
                <div class="close-box" phx-click="toggle_finder"></div>
                <div class="title">bobbby.online</div>
                <div class="resize-box"></div>
              </div>
              <div class="window-content">
                <div class="icon-grid">
                  <%= for section <- @sections do %>
                    <div class="icon-section" data-joyride={section.joyride_target}>
                      <div class="section-label">{section.label || section.name}</div>
                      <div class="section-items">
                        <%= for item <- section.items do %>
                          <%= if item.action do %>
                            <div
                              class="icon"
                              phx-click={item.action}
                              data-joyride={item.joyride_target}
                              phx-hook={if item.description, do: "Tooltip"}
                              data-tooltip={item.description}
                              id={if item.description, do: "icon-#{item.id}"}
                            >
                              <div class="icon-image">{item.icon}</div>
                              <div class={"icon-label #{if item.action == "toggle_phish" && @show_phish, do: "selected-label"}"}>
                                {item.name}
                              </div>
                            </div>
                          <% else %>
                            <.icon_item
                              program={item}
                              selected={@selected}
                              joyride={item.joyride_target}
                            />
                          <% end %>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                  <%!-- Other Work & Frivolity - opens Museum window --%>
                  <div class="icon-section">
                    <div class="section-label">Other Work & Frivolity</div>
                    <div class="section-items">
                      <div class="icon" phx-click="toggle_museum" id="icon-museum-toggle">
                        <div class="icon-image">
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 32 32"
                            width="28"
                            height="28"
                            style="image-rendering: pixelated;"
                          >
                            <rect x="2" y="2" width="28" height="3" fill="#000" />
                            <rect x="2" y="2" width="3" height="28" fill="#000" />
                            <rect x="2" y="27" width="28" height="3" fill="#000" />
                            <rect x="27" y="2" width="3" height="28" fill="#000" />
                            <rect x="7" y="7" width="18" height="2" fill="#000" />
                            <rect x="7" y="11" width="14" height="2" fill="#000" />
                            <rect x="7" y="15" width="18" height="2" fill="#000" />
                            <rect x="7" y="19" width="10" height="2" fill="#000" />
                            <rect x="7" y="23" width="16" height="2" fill="#000" />
                          </svg>
                        </div>
                        <div class={"icon-label #{if @show_museum, do: "selected-label"}"}>
                          {"Projects"}
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
              <div class="status-bar">
                <span>{length(@programs)} items</span>
                <span>{@total_online} online</span>
              </div>
            </div>
          <% end %>
          
    <!-- Museum Project List Window -->
          <%= if @show_museum do %>
            <div
              class={"museum-list-window mobile-window-museum #{if @mobile_window == :museum, do: "mobile-active"}"}
              phx-hook="Draggable"
              id="museum-list-window"
            >
              <div class="title-bar">
                <div class="close-box" phx-click="toggle_museum"></div>
                <div class="title">Technical Museum</div>
                <div class="resize-box"></div>
              </div>
              <div class="museum-filter-row">
                <span
                  phx-click="museum_filter"
                  phx-value-category="all"
                  class={"museum-filter-tag #{if @museum_category_filter == nil, do: "active"}"}
                >
                  All
                </span>
                <%= for cat <- @museum_categories do %>
                  <span
                    phx-click="museum_filter"
                    phx-value-category={cat}
                    class={"museum-filter-tag #{if @museum_category_filter == cat, do: "active"}"}
                  >
                    {category_label(cat)}
                  </span>
                <% end %>
                <span style="flex: 1;"></span>
                <span
                  phx-click="toggle_finder"
                  class={"museum-filter-tag #{if @show_finder, do: "active"}"}
                  style="border: 1px solid #999;"
                >
                  Apps & Games
                </span>
              </div>
              <div class="museum-list-content">
                <%= for project <- @museum_projects do %>
                  <div
                    class={"museum-list-item #{if @museum_selected_project && @museum_selected_project.slug == project.slug, do: "selected"}"}
                    phx-click="museum_select"
                    phx-value-slug={project.slug}
                  >
                    <div class="museum-list-icon">
                      {raw(Blog.Museum.Icons.get(project.slug))}
                    </div>
                    <div class="museum-list-info">
                      <div class="museum-list-name">{project.title}</div>
                      <div class="museum-list-tagline">{project.tagline}</div>
                      <div class="museum-list-tags">
                        <%= for tech <- Enum.take(project.tech_stack, 3) do %>
                          <span class="museum-list-tech">{tech}</span>
                        <% end %>
                      </div>
                    </div>
                  </div>
                <% end %>
              </div>
              <div class="status-bar">
                <span>{length(@museum_projects)} exhibits</span>
                <span
                  phx-click="toggle_finder"
                  style={"cursor: pointer; #{if @show_finder, do: "background: #000; color: #fff; padding: 0 6px;", else: "text-decoration: underline; padding: 0 6px;"}"}
                >
                  Apps & Games
                </span>
              </div>
            </div>
          <% end %>

          <%!-- Work Log Desktop Icon --%>
          <div class="desktop-icon-worklog" phx-click="toggle_work_log">
            <div class="desktop-icon-img">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="48" height="48" style="image-rendering: pixelated;">
                <rect x="6" y="4" width="20" height="24" fill="#1a1a2e"/>
                <rect x="7" y="5" width="18" height="22" fill="#1a1a2e" stroke="#e8a838" stroke-width="1"/>
                <rect x="9" y="8" width="5" height="1" fill="#e8a838"/>
                <rect x="15" y="8" width="8" height="1" fill="#5ce65c"/>
                <rect x="9" y="11" width="5" height="1" fill="#e8a838"/>
                <rect x="15" y="11" width="6" height="1" fill="#e65c5c"/>
                <rect x="9" y="14" width="5" height="1" fill="#e8a838"/>
                <rect x="15" y="14" width="7" height="1" fill="#5ce65c"/>
                <rect x="9" y="17" width="5" height="1" fill="#e8a838"/>
                <rect x="15" y="17" width="4" height="1" fill="#fff"/>
                <rect x="9" y="20" width="5" height="1" fill="#e8a838"/>
                <rect x="15" y="20" width="9" height="1" fill="#5ce65c"/>
              </svg>
            </div>
            <div class="desktop-icon-label">WORK<br/>LOG</div>
          </div>

          <%!-- Leica Desktop Icon --%>
          <div class="desktop-icon-leica" phx-click="toggle_leica">
            <div class="desktop-icon-img">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32" width="48" height="48" style="image-rendering: pixelated;">
                <rect x="4" y="8" width="24" height="16" fill="#000"/>
                <rect x="6" y="10" width="20" height="12" fill="#333"/>
                <rect x="12" y="12" width="8" height="8" rx="4" fill="#666"/>
                <rect x="14" y="14" width="4" height="4" rx="2" fill="#999"/>
                <rect x="8" y="9" width="4" height="2" fill="#555"/>
                <rect x="24" y="10" width="2" height="2" fill="#c00"/>
              </svg>
            </div>
            <div class="desktop-icon-label">MY FAV<br/>LEICA SHOTS</div>
          </div>

          <%!-- Leica Warning Dialog --%>
          <%= if @show_leica == :warning do %>
            <div class="leica-warning-overlay">
              <div class="leica-warning-dialog" phx-hook="Draggable" id="leica-warning">
                <div class="title-bar">
                  <div class="close-box" phx-click="close_leica"></div>
                  <div class="title">Warning</div>
                  <div class="resize-box"></div>
                </div>
                <div class="leica-warning-content">
                  <div class="leica-warning-icon">&#9888;</div>
                  <div class="leica-warning-text">
                    <strong>Large File Warning</strong>
                    <p>This collage is <strong>110 MB</strong> at full resolution (30,846 &times; 20,550 pixels).</p>
                    <p>It will take a while to download and may use significant memory. Not recommended on mobile devices.</p>
                    <p>Once loaded, you can zoom and pan around the full-resolution image.</p>
                  </div>
                  <div class="leica-warning-buttons">
                    <button class="leica-btn primary" phx-click="confirm_leica">Load Full Resolution</button>
                    <button class="leica-btn" phx-click="close_leica">Cancel</button>
                  </div>
                </div>
              </div>
            </div>
          <% end %>

          <%!-- Leica Viewer Window --%>
          <%= if @show_leica in [:loading, :viewing] do %>
            <div class="leica-viewer-window" phx-hook="Draggable" id="leica-viewer-window">
              <div class="title-bar">
                <div class="close-box" phx-click="close_leica"></div>
                <div class="title">MY FAV LEICA SHOTS — 30,846 × 20,550</div>
                <div class="resize-box"></div>
              </div>
              <div class="leica-viewer-container" phx-hook="LeicaViewer" id="leica-viewer" phx-update="ignore">
                <div class="leica-loading">
                  <div class="leica-loading-text">Downloading 110 MB...</div>
                  <div class="boot-progress" style="width: 200px; margin: 12px auto;">
                    <div class="boot-progress-bar" style="animation: boot-fill 15s ease-in-out forwards;"></div>
                  </div>
                  <div class="leica-loading-hint">This may take a minute</div>
                </div>
                <img
                  src="https://bobbby-media.fsn1.your-objectstorage.com/leica/leica_6_by_6_full.jpg"
                  class="leica-img"
                  style="opacity: 0;"
                />
                <div class="leica-controls">
                  <button class="leica-ctrl-btn leica-zoom-out" title="Zoom out">&#x2212;</button>
                  <span class="leica-zoom-label">100%</span>
                  <button class="leica-ctrl-btn leica-zoom-in" title="Zoom in">+</button>
                  <button class="leica-ctrl-btn leica-fit" title="Fit to window">Fit</button>
                  <a
                    href="https://bobbby-media.fsn1.your-objectstorage.com/leica/leica_6_by_6_full.jpg"
                    download
                    class="leica-ctrl-btn"
                    title="Download full resolution"
                    target="_blank"
                  >&#x2B73; Save</a>
                </div>
              </div>
              <div class="status-bar">
                <span>leica_6_by_6.jpg — 110 MB</span>
                <span>Scroll to zoom, drag to pan</span>
              </div>
            </div>
          <% end %>

          <%!-- Right column: detail window stacked above phish --%>
          <div class="right-column">
            <!-- Museum Detail Window -->
            <%= if @museum_selected_project do %>
              <div class="museum-detail-window" phx-hook="Draggable" id="museum-detail-window">
                <div class="title-bar">
                  <div class="close-box" phx-click="museum_close_detail"></div>
                  <div class="title">{@museum_selected_project.title}</div>
                  <div class="resize-box"></div>
                </div>
                <div class="museum-detail-content">
                  <div class="museum-detail-icon">
                    {raw(Blog.Museum.Icons.get(@museum_selected_project.slug))}
                  </div>
                  <div class="museum-detail-title">{@museum_selected_project.title}</div>
                  <div class="museum-detail-tagline">{@museum_selected_project.tagline}</div>
                  <div class="museum-detail-description">
                    {String.trim(@museum_selected_project.description)}
                  </div>
                  <div class="museum-detail-tech">
                    <%= for tech <- @museum_selected_project.tech_stack do %>
                      <span class="museum-list-tech">{tech}</span>
                    <% end %>
                  </div>
                  <%= if @museum_selected_project.github_repos != [] do %>
                    <div class="museum-detail-repos">
                      <strong>Source:</strong>
                      <%= for %{"name" => name, "full_name" => full_name} <- @museum_selected_project.github_repos do %>
                        <a
                          href={"https://github.com/#{full_name}"}
                          target="_blank"
                          class="museum-repo-link"
                        >
                          {name}
                        </a>
                      <% end %>
                    </div>
                  <% end %>
                  <%= if @museum_selected_project.internal_path do %>
                    <a href={@museum_selected_project.internal_path} class="museum-launch-btn">
                      Launch &#x25B6;
                    </a>
                  <% end %>
                  <%= if @museum_selected_project.external_url do %>
                    <a
                      href={@museum_selected_project.external_url}
                      target="_blank"
                      class="museum-launch-btn"
                      style="margin-top: 8px;"
                    >
                      Visit &#x2197;
                    </a>
                  <% end %>
                </div>
                <div class="status-bar">
                  <span>{@museum_selected_project.category}</span>
                  <span>{length(@museum_selected_project.tech_stack)} technologies</span>
                </div>
              </div>
            <% end %>
          </div>

          <%!-- Far right column: blog + phish stacked --%>
          <div class="far-right-column">
            <!-- Blog Posts Window -->
            <div
              class={"blog-window mobile-window-blog #{if @mobile_window == :blog, do: "mobile-active"}"}
              phx-hook="Draggable"
              id="blog-window"
            >
              <div class="title-bar">
                <div class="close-box"></div>
                <div class="title">Thoughts & Tidbits - Blog</div>
                <div class="resize-box"></div>
              </div>
              <div class="blog-window-content">
                <div class="blog-posts-list">
                  <%= for post <- @blog_posts do %>
                    <a href={~p"/post/#{post.slug}"} class="blog-post-row">
                      <div class="blog-post-icon">📝</div>
                      <div class="blog-post-info">
                        <div class="blog-post-title">{post.title}</div>
                        <div class="blog-post-meta">
                          {Calendar.strftime(post.written_on, "%B %d, %Y")}
                          <%= if length(post.tags) > 0 do %>
                            <span class="blog-post-tags">
                              <%= for tag <- post.tags do %>
                                <span class="blog-tag">{tag.name}</span>
                              <% end %>
                            </span>
                          <% end %>
                        </div>
                      </div>
                    </a>
                  <% end %>
                </div>
              </div>
              <div class="status-bar">
                <span>{length(@blog_posts)} posts</span>
                <span>{@total_online} {if @total_online == 1, do: "reader", else: "readers"}</span>
              </div>
            </div>
            
    <!-- Phish Jamchart Window -->
            <%= if @show_phish do %>
              <div
                class={"phish-embed-window mobile-window-phish #{if @mobile_window == :phish, do: "mobile-active"}"}
                phx-hook="Draggable"
                id="phish-window"
              >
                <div class="title-bar">
                  <div class="close-box" phx-click="toggle_phish"></div>
                  <div class="title">phangraphs — Phish 3.0 Jam Analytics</div>
                  <div class="resize-box"></div>
                </div>
                <div class="phish-embed-content">
                  <.live_component module={BlogWeb.PhishComponent} id="phish-embed" />
                </div>
                <div class="status-bar">
                  <span>phangraphs</span>
                  <span>Phish 3.0 Jam Analytics</span>
                </div>
              </div>
            <% end %>
          </div>
          <%!-- end far-right-column --%>
          
    <!-- Psychedelic Tree (always visible, transparent background) -->
          <div class="tree-container" id="tree-wrapper" phx-update="ignore">
            <canvas id="psychedelic-tree" phx-hook="PsychedelicTree"></canvas>
          </div>

    <!-- Work Log Window -->
          <%= if @show_work_log do %>
            <div class="work-log-window" phx-hook="Draggable" id="work-log-window">
              <div class="title-bar">
                <div class="close-box" phx-click="toggle_work_log"></div>
                <div class="title">Work Log — git log</div>
                <div class="resize-box"></div>
              </div>
              <div class="work-log-term">
                <div style="color: #8888aa;">$ git log</div>
                <%= if Enum.empty?(@work_log_events) do %>
                  <div style="color: #8888aa; text-align: center; padding: 20px 0;">Loading commits...</div>
                <% else %>
                  <%= for event <- @work_log_events do %>
                    <div class="wl-push-header"><span class="wl-sha"><a href={"https://github.com/#{event.repo}"} target="_blank">{String.slice((List.first(event.commits) || %{sha: ""})[:sha] || "", 0..6)}</a></span> <span class="wl-plus">+{event.additions}</span>/<span class="wl-minus">-{event.deletions}</span> <span class="wl-ref"><a href={"https://github.com/#{event.repo}"} target="_blank">{event.repo |> String.split("/") |> List.last()}</a>/{event.branch}</span></div>
                    <%= for commit <- event.commits do %>
                      <div class="wl-commit">    <span class="wl-sha"><a href={"https://github.com/#{event.repo}/commit/#{commit.sha}"} target="_blank">{commit.sha}</a></span> {commit.message}</div>
                    <% end %>
                  <% end %>
                <% end %>
              </div>
              <div class="status-bar">
                <span>{length(@work_log_events)} pushes</span>
                <span>github.com/notactuallytreyanastasio</span>
              </div>
            </div>
          <% end %>

    <!-- AIM Chat Window (Windows 95 style overlaid on Mac) -->
        <!-- Name Dialog - show for new visitors or returning visitors without confirmed chatter -->
          <%= if @reader_id && is_nil(@chatter) && @show_chat do %>
            <div
              class={"aim-name-dialog mobile-window-name_dialog #{if @mobile_window == :name_dialog, do: "mobile-active"}"}
              style="top: 80px; right: 40px;"
              data-joyride="aim-name-dialog"
              phx-hook="Draggable"
              id="name-dialog-window"
            >
              <div class="aim-name-dialog-titlebar">
                <span>{if @returning_chatter, do: "Welcome Back!", else: "Enter Screen Name"}</span>
              </div>
              <div class="aim-name-dialog-content">
                <div class="aim-name-dialog-text">
                  <%= if @returning_chatter do %>
                    Welcome back, <strong><%= @returning_chatter.screen_name %></strong>! Change your name or join as:
                  <% else %>
                    Please enter your screen name to join the chat:
                  <% end %>
                </div>
                <.form for={%{}} phx-submit="save_name" phx-change="validate_name">
                  <input
                    type="text"
                    name="name"
                    value={@name_form["name"]}
                    placeholder="Screen Name"
                    maxlength="20"
                    class="aim-name-input"
                    autofocus
                  />
                  <div class="aim-name-buttons">
                    <button type="submit" class="aim-name-btn primary">
                      {if @returning_chatter,
                        do: "Join as #{@returning_chatter.screen_name}",
                        else: "OK"}
                    </button>
                    <button type="button" class="aim-name-btn" phx-click="skip_name">Skip</button>
                  </div>
                </.form>
              </div>
            </div>
          <% end %>
          
    <!-- Chat Toggle Button -->
          <button
            class="aim-toggle-btn"
            phx-click="toggle_chat"
            style={if @show_chat, do: "display: none;", else: "right: 40px;"}
          >
            Chat Room
          </button>
          
    <!-- AIM Chat Container -->
          <div
            class={[
              "aim-chat-container",
              "mobile-window-chat",
              if(@show_chat, do: "open", else: ""),
              if(@mobile_window == :chat, do: "mobile-active", else: "")
            ]}
            style="right: 40px; bottom: 40px;"
            data-joyride="chat-window"
            phx-hook="Draggable"
            id="chat-window"
          >
            <div class="aim-chat-titlebar">
              <span class="aim-chat-title">AIM Chat - Terminal</span>
              <div class="aim-chat-controls">
                <button class="aim-control-btn" phx-click="toggle_chat">×</button>
              </div>
            </div>

            <div class="aim-chat-content">
              <div class="aim-buddy-list-title">Online ({@total_online})</div>
              <div class="aim-buddy-list">
                <%= for {_id, user} <- @visitor_list do %>
                  <div class="aim-buddy">
                    <div class="aim-buddy-status"></div>
                    <span class="aim-buddy-name" style={"color: #{user.color};"}>
                      {if Map.get(user, :display_name),
                        do: Map.get(user, :display_name),
                        else: "Anonymous"}
                    </span>
                  </div>
                <% end %>
              </div>

              <div class="aim-messages-area" id="aim-chat-messages" phx-hook="ChatScroll">
                <%= for message <- @chat_messages do %>
                  <div class="aim-message">
                    <span
                      class="aim-message-sender"
                      style={"color: #{if message.chatter, do: message.chatter.color, else: "#666"};"}
                    >
                      {if message.chatter, do: message.chatter.screen_name, else: "Anonymous"}
                    </span>
                    <span class="aim-message-time">
                      {Calendar.strftime(message.inserted_at, "%I:%M %p")}
                    </span>
                    <div class="aim-message-content">{message.content}</div>
                  </div>
                <% end %>
                <%= if Enum.empty?(@chat_messages) do %>
                  <div class="aim-message">
                    <span class="aim-message-sender" style="color: #000080;">ChatBot</span>
                    <div class="aim-message-content">Welcome! Say hello!</div>
                  </div>
                <% end %>
              </div>

              <div class="aim-input-area">
                <.form for={%{}} phx-submit="send_chat_message" phx-change="validate_chat_message">
                  <textarea
                    name="message"
                    class="aim-input-box"
                    placeholder="Type a message..."
                    maxlength="500"
                    autocomplete="off"
                  ><%= @chat_form["message"] %></textarea>
                  <button type="submit" class="aim-send-btn">Send</button>
                  <div style="clear: both;"></div>
                </.form>
              </div>
            </div>
          </div>

          <%!-- Mobile Taskbar - only visible on mobile --%>
          <div class="mobile-taskbar">
            <button
              class={"mobile-taskbar-btn #{if @mobile_window == :finder, do: "active"}"}
              phx-click="switch_mobile_window"
              phx-value-window="finder"
            >
              📁 Apps
            </button>
            <button
              class={"mobile-taskbar-btn #{if @mobile_window == :museum, do: "active"}"}
              phx-click="switch_mobile_window"
              phx-value-window="museum"
            >
              Museum
            </button>
            <button
              class={"mobile-taskbar-btn #{if @mobile_window == :blog, do: "active"}"}
              phx-click="switch_mobile_window"
              phx-value-window="blog"
            >
              Blog
            </button>
            <%= if is_nil(@chatter) do %>
              <button
                class={"mobile-taskbar-btn #{if @mobile_window == :name_dialog, do: "active"}"}
                phx-click="switch_mobile_window"
                phx-value-window="name_dialog"
              >
                ✏️ Name
              </button>
            <% end %>
            <button
              class={"mobile-taskbar-btn #{if @mobile_window == :phish, do: "active"}"}
              phx-click="switch_mobile_window"
              phx-value-window="phish"
            >
              🐟 Phish
            </button>
            <button
              class={"mobile-taskbar-btn #{if @mobile_window == :chat, do: "active"}"}
              phx-click="switch_mobile_window"
              phx-value-window="chat"
            >
              💬 Chat
            </button>
          </div>
        </div>
      </div>
    <% end %>

    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      html, body {
        height: 100%;
        overflow: hidden;
      }

      .mac {
        height: 100vh;
        background: #a8a8a8;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 14px;
        cursor: default;
        -webkit-font-smoothing: none;
      }

      /* Menu Bar */
      .menu-bar {
        height: 24px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
      }

      .menu-left {
        display: flex;
        gap: 16px;
      }

      .apple-menu {
        font-family: system-ui;
        font-size: 16px;
      }

      .menu-item {
        cursor: default;
      }

      .menu-item:hover {
        background: #000;
        color: #fff;
      }

      .menu-right {
        font-size: 13px;
      }

      /* Desktop */
      .desktop {
        height: calc(100vh - 24px);
        padding: 20px;
        background: repeating-linear-gradient(
          0deg,
          #a8a8a8,
          #a8a8a8 1px,
          #b8b8b8 1px,
          #b8b8b8 2px
        );
        display: flex;
        gap: 20px;
        align-items: flex-start;
      }

      /* Window (Icons/Finder) */
      .window {
        width: 780px;
        min-width: 720px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        flex-shrink: 0;
      }

      /* Blog Window */
      .blog-window {
        width: 100%;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        flex: 1;
        min-height: 0;
        display: flex;
        flex-direction: column;
      }

      /* Hide chat on smaller screens to prioritize main windows */
      @media (max-width: 1200px) {
        .aim-chat-container,
        .aim-name-dialog,
        .aim-toggle-btn {
          display: none !important;
        }
      }

      .blog-window .title-bar {
        height: 24px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        align-items: center;
        padding: 0 4px;
        background: repeating-linear-gradient(
          90deg,
          #fff 0px,
          #fff 1px,
          #000 1px,
          #000 2px,
          #fff 2px,
          #fff 3px
        );
      }

      .blog-window .close-box {
        width: 12px;
        height: 12px;
        border: 1px solid #000;
        background: #fff;
        margin-right: 8px;
      }

      .blog-window .title {
        flex: 1;
        text-align: center;
        background: #fff;
        padding: 0 8px;
        font-weight: bold;
      }

      .blog-window-content {
        flex: 1;
        min-height: 0;
        overflow-y: auto;
        background: #fff;
      }

      .blog-posts-list {
        display: flex;
        flex-direction: column;
      }

      .blog-post-row {
        display: flex;
        align-items: center;
        padding: 8px 12px;
        border-bottom: 1px solid #ccc;
        text-decoration: none;
        color: inherit;
        cursor: default;
      }

      .blog-post-row:hover {
        background: #000;
        color: #fff;
      }

      .blog-post-row:hover .blog-tag {
        background: #333;
        color: #fff;
      }

      .blog-post-row:hover .blog-post-meta {
        color: #ccc;
      }

      .blog-post-icon {
        font-size: 22px;
        margin-right: 10px;
        width: 26px;
        text-align: center;
      }

      .blog-post-info {
        flex: 1;
        min-width: 0;
      }

      .blog-post-title {
        font-weight: bold;
        font-size: 14px;
        margin-bottom: 2px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }

      .blog-post-meta {
        font-size: 12px;
        color: #666;
        display: flex;
        align-items: center;
        gap: 6px;
        flex-wrap: wrap;
      }

      .blog-post-tags {
        display: flex;
        gap: 3px;
        flex-wrap: wrap;
      }

      .blog-tag {
        background: #e0e0e0;
        padding: 1px 5px;
        border-radius: 2px;
        font-size: 11px;
      }

      .blog-window .status-bar {
        height: 22px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 12px;
      }

      .title-bar {
        height: 24px;
        background: #fff;
        border-bottom: 1px solid #000;
        display: flex;
        align-items: center;
        padding: 0 4px;
        background: repeating-linear-gradient(
          90deg,
          #fff 0px,
          #fff 1px,
          #000 1px,
          #000 2px,
          #fff 2px,
          #fff 3px
        );
      }

      .close-box {
        width: 12px;
        height: 12px;
        border: 1px solid #000;
        background: #fff;
        margin-right: 8px;
      }

      .close-box:hover {
        background: #000;
      }

      .title {
        flex: 1;
        text-align: center;
        background: #fff;
        padding: 0 8px;
        font-weight: bold;
      }

      .resize-box {
        width: 12px;
        height: 12px;
      }

      .window-content {
        padding: 10px;
        min-height: 300px;
        max-height: 70vh;
        overflow-y: auto;
        background: #fff;
      }

      .icon-grid {
        display: flex;
        flex-direction: column;
        gap: 8px;
      }

      .icon-section {
        padding: 6px;
        border-radius: 4px;
      }

      .icon-section:hover {
        background: rgba(0, 0, 0, 0.03);
      }

      /* Tippy.js base styles */
      .tippy-box {
        position: relative;
        background-color: #000;
        color: #fff;
        border-radius: 2px;
        font-size: 11px;
        font-family: "Geneva", "Chicago", "Helvetica Neue", sans-serif;
        line-height: 1.4;
        outline: 0;
        padding: 4px 8px;
      }
      .tippy-box[data-placement^='top'] > .tippy-arrow { bottom: 0; }
      .tippy-box[data-placement^='top'] > .tippy-arrow::before {
        bottom: -7px; left: 0;
        border-width: 8px 8px 0;
        border-top-color: #000;
      }
      .tippy-box[data-placement^='bottom'] > .tippy-arrow { top: 0; }
      .tippy-box[data-placement^='bottom'] > .tippy-arrow::before {
        top: -7px; left: 0;
        border-width: 0 8px 8px;
        border-bottom-color: #000;
      }
      .tippy-arrow {
        width: 16px; height: 16px;
        color: #000;
      }
      .tippy-arrow::before {
        content: '';
        position: absolute;
        border-color: transparent;
        border-style: solid;
      }
      .tippy-content {
        position: relative;
        z-index: 1;
      }

      .section-label {
        font-size: 10px;
        font-weight: bold;
        text-transform: uppercase;
        color: #666;
        letter-spacing: 0.5px;
        margin-bottom: 4px;
        padding-left: 2px;
      }

      .section-items {
        display: flex;
        flex-wrap: wrap;
        gap: 6px;
      }

      .icon {
        width: 56px;
        text-align: center;
        padding: 2px;
        cursor: default;
      }

      .icon.selected .icon-label {
        background: #000;
        color: #fff;
      }

      .icon-image {
        font-size: 28px;
        height: 34px;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .icon-label {
        font-size: 11px;
        margin-top: 1px;
        padding: 1px 2px;
        word-wrap: break-word;
      }

      .status-bar {
        height: 22px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 12px;
      }

      /* Double click to open */
      .icon-image {
        cursor: pointer;
      }

      /* Phish embed window */
      /* Work Log Window */
      .work-log-window {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        width: 520px;
        max-width: 90vw;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        z-index: 120;
        display: flex;
        flex-direction: column;
        max-height: 70vh;
      }
      .work-log-term {
        background: #1a1a2e;
        color: #c8c8c8;
        font-family: "Monaco", "Menlo", "Courier New", monospace;
        font-size: 11px;
        line-height: 1.4;
        padding: 8px 12px;
        overflow-y: auto;
        overflow-x: auto;
        flex: 1;
        min-height: 0;
        max-height: 50vh;
      }
      .work-log-term a { color: inherit; text-decoration: none; }
      .work-log-term a:hover { text-decoration: underline; }
      .wl-push-header { color: #c8c8c8; margin-top: 6px; white-space: nowrap; }
      .wl-push-header:first-of-type { margin-top: 4px; }
      .wl-sha { color: #e8a838; }
      .wl-sha a { color: #e8a838; }
      .wl-plus { color: #5ce65c; }
      .wl-minus { color: #e65c5c; }
      .wl-ref { color: #5ccccc; }
      .wl-ref a { color: #5ccccc; }
      .wl-commit { padding-left: 4ch; color: #fff; white-space: pre-wrap; word-break: break-word; }

      .phish-embed-window {
        width: 100%;
        max-width: 420px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        flex: 1;
        min-height: 0;
        display: flex;
        flex-direction: column;
      }

      .phish-embed-content {
        flex: 1;
        min-height: 0;
        overflow-y: auto;
        background: #fff;
      }

      .phish-embed-window .status-bar {
        height: 20px;
        border-top: 1px solid #000;
        background: #fff;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 0 8px;
        font-size: 10px;
      }

      .selected-label {
        background: #000;
        color: #fff;
      }

      /* Psychedelic tree container */
      .tree-container {
        position: fixed;
        top: 0;
        left: 0;
        width: 100vw;
        height: 100vh;
        pointer-events: none;
        z-index: 50;
      }

      .tree-container canvas {
        width: 100%;
        height: 100%;
        display: block;
      }

      /* Mobile taskbar - hidden on desktop */
      .mobile-taskbar {
        display: none;
      }

      /* ============================================
         MOBILE STYLES (max-width: 768px)
         ============================================ */
      @media (max-width: 768px) {
        /* Hide menu bar items except time on mobile */
        .menu-left .menu-item {
          display: none;
        }

        /* Desktop padding adjustments for mobile */
        .desktop {
          padding: 10px;
          padding-bottom: 70px; /* Room for taskbar */
        }

        /* Finder window - full screen on mobile */
        .window.mobile-window-finder {
          position: fixed;
          top: 20px; /* Below menu bar */
          left: 0;
          right: 0;
          bottom: 60px; /* Above taskbar */
          width: 100% !important;
          max-width: 100% !important;
          z-index: 100;
          display: none; /* Hidden by default */
        }

        .window.mobile-window-finder.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .window.mobile-window-finder .window-content {
          flex: 1;
          max-height: none;
          min-height: auto;
          overflow-y: auto;
        }

        /* Blog window - full screen on mobile */
        .blog-window.mobile-window-blog {
          position: fixed;
          top: 20px;
          left: 0;
          right: 0;
          bottom: 60px;
          width: 100% !important;
          max-width: 100% !important;
          z-index: 100;
          display: none;
        }

        .blog-window.mobile-window-blog.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .blog-window.mobile-window-blog .blog-window-content {
          flex: 1;
          max-height: none;
          overflow-y: auto;
        }

        /* Name dialog - full screen on mobile */
        .aim-name-dialog.mobile-window-name_dialog {
          position: fixed !important;
          top: 20px !important;
          left: 0 !important;
          right: 0 !important;
          bottom: 60px !important;
          width: 100% !important;
          max-width: 100% !important;
          z-index: 200;
          display: none; /* Hidden by default */
          box-sizing: border-box;
        }

        .aim-name-dialog.mobile-window-name_dialog.mobile-active {
          display: block;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-dialog-content {
          padding: 20px;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-input {
          width: 100%;
          font-size: 16px; /* Prevent zoom on iOS */
          padding: 12px;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-buttons {
          flex-direction: column;
          gap: 10px;
        }

        .aim-name-dialog.mobile-window-name_dialog .aim-name-btn {
          width: 100%;
          padding: 12px;
          font-size: 16px;
        }

        /* Chat container - full screen on mobile */
        .aim-chat-container.mobile-window-chat {
          position: fixed !important;
          top: 20px !important;
          left: 0 !important;
          right: 0 !important;
          bottom: 60px !important;
          width: 100% !important;
          max-width: 100% !important;
          z-index: 150;
          display: none; /* Hidden by default */
          box-sizing: border-box;
        }

        .aim-chat-container.mobile-window-chat.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .aim-chat-container.mobile-window-chat .aim-chat-content {
          flex: 1;
          display: flex;
          flex-direction: column;
          overflow: hidden;
        }

        .aim-chat-container.mobile-window-chat .aim-messages-area {
          flex: 1;
          overflow-y: auto;
        }

        .aim-chat-container.mobile-window-chat .aim-input-box {
          font-size: 16px; /* Prevent zoom on iOS */
        }

        /* Hide the floating chat toggle on mobile */
        .aim-toggle-btn {
          display: none !important;
        }

        /* Hide tree animation on mobile for performance */
        .tree-container {
          display: none;
        }

        /* Mobile taskbar - fixed at bottom */
        .mobile-taskbar {
          display: flex;
          position: fixed;
          bottom: 0;
          left: 0;
          right: 0;
          height: 50px;
          background: linear-gradient(to bottom, #dfdfdf, #c0c0c0);
          border-top: 2px solid #fff;
          box-shadow: 0 -2px 4px rgba(0, 0, 0, 0.2);
          z-index: 1000;
          padding: 5px;
          gap: 5px;
        }

        .mobile-taskbar-btn {
          flex: 1;
          background: linear-gradient(to bottom, #ececec, #d4d4d4);
          border: 1px solid #888;
          border-radius: 4px;
          font-size: 12px;
          font-weight: bold;
          cursor: pointer;
          display: flex;
          align-items: center;
          justify-content: center;
          gap: 4px;
          box-shadow: 1px 1px 0 #fff inset, -1px -1px 0 #888 inset;
        }

        .mobile-taskbar-btn:active,
        .mobile-taskbar-btn.active {
          background: linear-gradient(to bottom, #c0c0c0, #a8a8a8);
          box-shadow: -1px -1px 0 #fff inset, 1px 1px 0 #888 inset;
        }

        /* Icon grid adjustments for mobile */
        .icon-grid {
          gap: 4px;
        }

        .icon-section {
          gap: 8px;
          padding: 4px;
        }

        .icon {
          width: 60px;
        }

        .icon-image {
          font-size: 28px;
          height: 36px;
        }

        .icon-label {
          font-size: 9px;
        }

        /* Phish window - full screen on mobile */
        .phish-embed-window.mobile-window-phish {
          position: fixed !important;
          top: 20px !important;
          left: 0 !important;
          right: 0 !important;
          bottom: 60px !important;
          width: 100% !important;
          max-width: 100% !important;
          min-width: 0 !important;
          transform: none !important;
          z-index: 200;
          display: none;
        }

        .phish-embed-window.mobile-window-phish.mobile-active {
          display: flex;
          flex-direction: column;
        }

        .phish-embed-window.mobile-window-phish .phish-embed-content {
          flex: 1;
          max-height: none;
          overflow-y: auto;
        }

        /* Hide joyride tour on mobile - too complex for small screens */
        #site-tour {
          display: none !important;
        }
      }

      /* ========================================
         BOOT SPLASH SCREEN
         ======================================== */

      .mac-boot {
        width: 100vw;
        height: 100vh;
        background: #a8a8a8;
        background-image: repeating-conic-gradient(#a0a0a0 0% 25%, #a8a8a8 0% 50%);
        background-size: 2px 2px;
        display: flex;
        justify-content: center;
        align-items: center;
        cursor: pointer;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        -webkit-font-smoothing: none;
      }

      .boot-screen {
        text-align: center;
        max-width: 600px;
        padding: 40px;
      }

      .boot-logo {
        margin-bottom: 40px;
      }

      .boot-logo svg {
        display: inline-block;
      }

      .boot-text {
        font-size: 32px;
        font-weight: bold;
        margin-bottom: 20px;
        color: #000;
      }

      .boot-subtext {
        font-size: 18px;
        line-height: 1.7;
        color: #333;
        margin-bottom: 40px;
      }

      .boot-progress {
        width: 340px;
        height: 20px;
        border: 2px solid #000;
        margin: 0 auto 24px;
        background: #fff;
        padding: 3px;
      }

      .boot-progress-bar {
        height: 100%;
        background: #000;
        animation: boot-fill 8s ease-in-out forwards;
      }

      @keyframes boot-fill {
        0% { width: 0%; }
        30% { width: 30%; }
        60% { width: 65%; }
        80% { width: 85%; }
        100% { width: 100%; }
      }

      .boot-hint {
        font-size: 13px;
        color: #888;
      }

      /* ========================================
         MUSEUM WINDOWS
         ======================================== */

      .museum-list-window {
        width: 720px;
        min-width: 600px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
        flex-shrink: 0;
      }

      .museum-filter-row {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
        padding: 6px 10px;
        border-bottom: 1px solid #000;
        background: #e8e8e8;
        font-size: 14px;
      }

      .museum-filter-tag {
        padding: 3px 10px;
        cursor: pointer;
        border: 1px solid transparent;
      }

      .museum-filter-tag:hover {
        background: #d0d0d0;
      }

      .museum-filter-tag.active {
        background: #000;
        color: #fff;
      }

      .museum-list-content {
        max-height: calc(100vh - 160px);
        overflow-y: auto;
        background: #fff;
      }

      .museum-list-item {
        display: flex;
        gap: 12px;
        padding: 10px 14px;
        cursor: pointer;
        border-bottom: 1px solid #e0e0e0;
        align-items: flex-start;
      }

      .museum-list-item:hover {
        background: #e8e8e8;
      }

      .museum-list-item.selected {
        background: #000;
        color: #fff;
      }

      .museum-list-item.selected .museum-list-tagline {
        color: #ccc;
      }

      .museum-list-item.selected .museum-list-tech {
        border-color: #666;
        background: #333;
        color: #fff;
      }

      .museum-list-icon {
        width: 48px;
        height: 48px;
        flex-shrink: 0;
        margin-top: 2px;
      }

      .museum-list-item.selected .museum-list-icon svg {
        filter: invert(1);
      }

      .museum-list-icon svg {
        width: 48px;
        height: 48px;
      }

      .museum-list-info {
        flex: 1;
        min-width: 0;
      }

      .museum-list-name {
        font-size: 18px;
        font-weight: bold;
        margin-bottom: 4px;
      }

      .museum-list-tagline {
        font-size: 14px;
        color: #666;
        line-height: 1.4;
        margin-bottom: 5px;
      }

      .museum-list-tags {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
      }

      .museum-list-tech {
        font-size: 12px;
        padding: 1px 6px;
        border: 1px solid #ccc;
        background: #f0f0f0;
      }

      /* Right column: museum detail stacked */
      .right-column {
        display: flex;
        flex-direction: column;
        gap: 12px;
        flex-shrink: 0;
        align-self: flex-start;
      }

      /* Far right column: blog + phish stacked to fill viewport height */
      .far-right-column {
        display: flex;
        flex-direction: column;
        gap: 8px;
        width: 420px;
        min-width: 320px;
        max-width: 420px;
        margin-left: auto;
        align-self: flex-start;
        height: calc(100vh - 64px);
        flex-shrink: 0;
      }

      /* Museum Detail Window */

      .museum-detail-window {
        width: 480px;
        min-width: 380px;
        background: #fff;
        border: 1px solid #000;
        box-shadow: 1px 1px 0 #000;
      }

      .museum-detail-content {
        padding: 20px;
        max-height: calc(100vh - 140px);
        overflow-y: auto;
        background: #fff;
      }

      .museum-detail-icon {
        width: 80px;
        height: 80px;
        margin: 0 auto 16px;
      }

      .museum-detail-icon svg {
        width: 80px;
        height: 80px;
      }

      .museum-detail-title {
        font-size: 22px;
        font-weight: bold;
        text-align: center;
        margin-bottom: 6px;
      }

      .museum-detail-tagline {
        font-size: 15px;
        color: #666;
        text-align: center;
        font-style: italic;
        margin-bottom: 16px;
      }

      .museum-detail-description {
        font-size: 15px;
        line-height: 1.7;
        margin-bottom: 16px;
        white-space: pre-line;
      }

      .museum-detail-tech {
        display: flex;
        flex-wrap: wrap;
        gap: 4px;
        margin-bottom: 16px;
      }

      .museum-detail-repos {
        font-size: 14px;
        margin-bottom: 16px;
      }

      .museum-repo-link {
        color: #000;
        text-decoration: underline;
        margin-left: 6px;
      }

      .museum-repo-link:hover {
        background: #000;
        color: #fff;
      }

      .museum-launch-btn {
        display: block;
        text-align: center;
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 13px;
        padding: 8px 16px;
        border: 2px solid #000;
        background: #fff;
        color: #000;
        text-decoration: none;
        box-shadow: 2px 2px 0 #000;
        cursor: pointer;
        margin-top: 16px;
      }

      .museum-launch-btn:hover {
        background: #000;
        color: #fff;
      }

      .museum-launch-btn:active {
        box-shadow: 0 0 0 #000;
        transform: translate(2px, 2px);
      }

      @media (max-width: 768px) {
        .museum-list-window {
          width: 100%;
        }

        .museum-detail-window {
          position: fixed;
          top: 24px;
          left: 0;
          right: 0;
          width: 100%;
          height: calc(100vh - 24px);
          z-index: 200;
        }
      }

      /* ========================================
         LEICA COLLAGE VIEWER
         ======================================== */

      /* Desktop icon */
      .desktop-icon-worklog {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        text-align: center;
        cursor: pointer;
        z-index: 10;
        padding: 8px;
        border-radius: 4px;
      }
      .desktop-icon-worklog:hover {
        background: rgba(0,0,0,0.1);
      }
      .desktop-icon-leica {
        position: absolute;
        bottom: 40px;
        left: 50%;
        transform: translateX(-50%);
        text-align: center;
        cursor: pointer;
        z-index: 10;
        padding: 8px;
        border-radius: 4px;
      }

      .desktop-icon-leica:hover {
        background: rgba(0, 0, 0, 0.1);
      }

      .desktop-icon-leica:hover .desktop-icon-label {
        background: #000;
        color: #fff;
      }

      .desktop-icon-img {
        display: flex;
        justify-content: center;
        margin-bottom: 4px;
      }

      .desktop-icon-label {
        font-size: 12px;
        font-weight: bold;
        line-height: 1.3;
        padding: 2px 4px;
        white-space: nowrap;
      }

      /* Warning overlay */
      .leica-warning-overlay {
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.4);
        z-index: 500;
        display: flex;
        align-items: center;
        justify-content: center;
      }

      .leica-warning-dialog {
        width: 420px;
        background: #fff;
        border: 2px solid #000;
        box-shadow: 4px 4px 0 #000;
      }

      .leica-warning-content {
        padding: 20px;
        text-align: center;
      }

      .leica-warning-icon {
        font-size: 48px;
        margin-bottom: 12px;
        color: #cc0000;
      }

      .leica-warning-text {
        font-size: 13px;
        line-height: 1.6;
        margin-bottom: 20px;
        text-align: left;
      }

      .leica-warning-text p {
        margin: 8px 0;
      }

      .leica-warning-buttons {
        display: flex;
        gap: 10px;
        justify-content: center;
      }

      .leica-btn {
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 13px;
        padding: 8px 20px;
        border: 2px solid #000;
        background: #fff;
        color: #000;
        cursor: pointer;
        box-shadow: 2px 2px 0 #000;
      }

      .leica-btn:hover {
        background: #e0e0e0;
      }

      .leica-btn:active {
        box-shadow: 0 0 0 #000;
        transform: translate(2px, 2px);
      }

      .leica-btn.primary {
        background: #000;
        color: #fff;
      }

      .leica-btn.primary:hover {
        background: #333;
      }

      /* Viewer window */
      .leica-viewer-window {
        position: fixed;
        top: 30px;
        left: 30px;
        right: 30px;
        bottom: 30px;
        background: #fff;
        border: 2px solid #000;
        box-shadow: 4px 4px 0 #000;
        z-index: 400;
        display: flex;
        flex-direction: column;
      }

      .leica-viewer-container {
        flex: 1;
        overflow: hidden;
        background: #1a1a1a;
        position: relative;
        cursor: grab;
      }

      .leica-img {
        transform-origin: 0 0;
        will-change: transform;
        max-width: none;
        display: block;
      }

      .leica-loading {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        color: #fff;
        text-align: center;
        z-index: 5;
      }

      .leica-loading-text {
        font-size: 18px;
        font-weight: bold;
        margin-bottom: 8px;
      }

      .leica-loading-hint {
        font-size: 12px;
        color: #999;
        margin-top: 8px;
      }

      /* Controls bar */
      .leica-controls {
        position: absolute;
        bottom: 0;
        left: 0;
        right: 0;
        height: 36px;
        background: rgba(0, 0, 0, 0.8);
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 0 12px;
        z-index: 10;
      }

      .leica-ctrl-btn {
        font-family: "Chicago", "Geneva", "Helvetica", sans-serif;
        font-size: 13px;
        padding: 4px 10px;
        background: #333;
        color: #fff;
        border: 1px solid #666;
        cursor: pointer;
        text-decoration: none;
      }

      .leica-ctrl-btn:hover {
        background: #555;
      }

      .leica-zoom-label {
        color: #fff;
        font-size: 12px;
        min-width: 40px;
        text-align: center;
      }

      @media (max-width: 768px) {
        .desktop-icon-leica {
          position: static;
          transform: none;
          margin: 20px auto;
        }

        .leica-viewer-window {
          top: 24px;
          left: 0;
          right: 0;
          bottom: 50px;
        }

        .leica-warning-dialog {
          width: 90%;
        }
      }
    </style>
    """
  end
end
