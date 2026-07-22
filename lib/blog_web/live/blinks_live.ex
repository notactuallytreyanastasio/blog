defmodule BlogWeb.BlinksLive do
  use BlogWeb, :live_view

  alias Blog.Blinks
  alias Blog.Chat
  alias BlogWeb.Presence

  # one shared presence topic for every link's room, so the list page can
  # show live-occupancy dots without subscribing to each room
  @rooms_presence "blinks_rooms_presence"

  def mount(_params, session, socket) do
    visitor_ip = Map.get(session, "remote_ip", "unknown")
    returning = Chat.get_chatter_by_ip(Chat.hash_ip(visitor_ip))

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, Blinks.topic())
      Phoenix.PubSub.subscribe(Blog.PubSub, @rooms_presence)
    end

    {:ok,
     assign(socket,
       page_title: "Blinks: Bobbby's links",
       total: Blinks.count_blinks(),
       visitor_ip: visitor_ip,
       # screen names are sticky: recognized visitors are signed on already
       chatter: returning,
       returning_name: returning && returning.screen_name,
       chat_blink: nil,
       chat_messages: [],
       chat_topic: nil,
       chat_room: nil,
       rooms_live: %{},
       chat_input: "",
       chat_votes: %{},
       my_votes: %{},
       replying_to: nil,
       show_buddies: false,
       buddies: [],
       mention_suggestions: [],
       presence_key: "v_" <> Base.encode16(:crypto.strong_rand_bytes(6)),
       dork_editing: false,
       dork_tags: Blinks.dork_tags(),
       singles_open: false,
       hidden_ids: MapSet.new(),
       fresh_ids: MapSet.new(),
       admin: false,
       admin_error: nil,
       # the tour auto-runs when this browser hasn't seen it (localStorage,
       # reported by the BlinksPrefs hook) — IP-based identity would wrongly
       # skip it in incognito/new browsers on a known network
       show_tour: false,
       tour_steps: []
     )}
  end

  @page_size 50

  def handle_params(params, _uri, socket) do
    q = params["q"] || ""
    nodork = params["nodork"] == "1"

    page =
      case Integer.parse(params["page"] || "1") do
        {n, ""} when n >= 1 -> n
        _ -> 1
      end

    view = if params["view"] == "archives", do: :archives, else: :live

    week =
      with :archives <- view,
           {:ok, date} <- Date.from_iso8601(params["week"] || "") do
        Date.beginning_of_week(date)
      else
        _ -> nil
      end

    tags =
      (params["tags"] || "")
      |> String.split(",")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(&1 == ""))

    similar_to =
      with id when is_binary(id) <- params["similar"],
           {id, ""} <- Integer.parse(id),
           %{} = blink <- Blinks.get_blink(id) do
        blink
      else
        _ -> nil
      end

    socket =
      socket
      |> assign(
        q: q,
        selected_tags: tags,
        nodork: nodork,
        similar_to: similar_to,
        page: page,
        view: view,
        week: week
      )
      |> assign(fresh_ids: MapSet.new())
      |> reload()
      |> sync_chat(params["chat"])

    {:noreply, assign(socket, tour_steps: build_tour_steps(socket.assigns.chat_blink != nil))}
  end

  defp build_tour_steps(chat_open?) do
    base = [
      %{
        target: "search",
        title: "Search everything",
        content: "Titles, tags, and notes are all searchable from here.",
        placement: :bottom
      },
      %{
        target: "tags-box",
        title: "Browse by tag",
        content:
          "Click tags to combine them — you'll see links matching any of them. Click a tag again to drop it.",
        placement: :left
      },
      %{
        target: "chat-link",
        title: "Every link is a chat room",
        content:
          "This opens an AIM window that's both a comments section and a live discussion.",
        placement: :bottom
      },
      %{
        target: "hide-link",
        title: "Not your thing?",
        content: "Hide any link and it stays hidden for you on this device.",
        placement: :bottom
      }
    ]

    chat_steps =
      if chat_open? do
        [
          %{
            target: "chat-window",
            title: "The chat window",
            content:
              "Drag it by the title bar; grab the bottom-right corner to resize. On phones it goes fullscreen.",
            placement: :left
          },
          %{
            target: "chat-window",
            title: "Markdown + votes",
            content:
              "Messages support markdown — links become clickable, **bold**, lists, code. Hover a message to 👍/👎 it. Votes only exist on comments; links themselves can't be voted on.",
            placement: :left
          }
        ]
      else
        [
          %{
            target: "chat-link",
            title: "Inside the chat",
            content:
              "Once open: drag the title bar, resize from the corner, write markdown (links become clickable), and hover messages to 👍/👎 them. Votes are for comments only — links don't have votes.",
            placement: :bottom
          }
        ]
      end

    base ++ chat_steps
  end

  defp reload(socket) do
    %{q: q, selected_tags: tags, nodork: nodork, similar_to: similar_to} = socket.assigns
    exclude = if nodork, do: socket.assigns.dork_tags, else: []

    %{page: page, view: view, week: week} = socket.assigns

    blinks =
      cond do
        similar_to ->
          Blinks.list_similar(similar_to, 25)

        view == :archives and is_nil(week) ->
          []

        view == :archives ->
          Blinks.list_blinks(query: q, tags: tags, exclude_tags: exclude, week: week, limit: 500)

        true ->
          Blinks.list_blinks(
            query: q,
            tags: tags,
            exclude_tags: exclude,
            limit: @page_size + 1,
            offset: (page - 1) * @page_size
          )
      end

    has_more = !similar_to and view == :live and length(blinks) > @page_size

    blinks =
      blinks
      |> Enum.take(if(view == :live, do: @page_size, else: length(blinks)))
      |> Enum.reject(&MapSet.member?(socket.assigns.hidden_ids, &1.id))

    socket =
      if view == :archives and is_nil(week),
        do: assign(socket, weeks: Blinks.weeks()),
        else: assign(socket, weeks: [])

    assign(socket,
      blinks: blinks,
      has_more: has_more,
      tags: Blinks.list_tags([], exclude),
      chat_counts: Chat.count_messages_by_room(Enum.map(blinks, &room/1))
    )
  end

  # Open/close the chat window based on the ?chat= param, keeping the
  # PubSub subscription in step with whichever room is on screen.
  defp sync_chat(socket, chat_param) do
    blink =
      with id when is_binary(id) <- chat_param,
           {id, ""} <- Integer.parse(id) do
        Blinks.get_blink(id)
      else
        _ -> nil
      end

    new_topic = if blink, do: Chat.room_topic(room(blink))
    new_room = if blink, do: room(blink)
    old_topic = socket.assigns.chat_topic
    old_room = socket.assigns.chat_room

    if connected?(socket) and new_topic != old_topic do
      if old_topic, do: Phoenix.PubSub.unsubscribe(Blog.PubSub, old_topic)
      if new_topic, do: Phoenix.PubSub.subscribe(Blog.PubSub, new_topic)

      if old_room, do: Presence.untrack(self(), @rooms_presence, socket.assigns.presence_key)

      if new_room do
        {:ok, _} =
          Presence.track(self(), @rooms_presence, socket.assigns.presence_key, %{
            room: new_room,
            name: presence_name(socket.assigns.chatter),
            color: (socket.assigns.chatter && socket.assigns.chatter.color) || "#888"
          })
      end
    end

    messages = if blink, do: Chat.list_messages(room(blink), 100), else: []
    ids = Enum.map(messages, & &1.id)
    chatter = socket.assigns.chatter

    assign(socket,
      chat_blink: blink,
      chat_topic: new_topic,
      chat_room: new_room,
      replying_to: nil,
      show_buddies: false,
      buddies: if(new_room, do: list_buddies(new_room), else: []),
      rooms_live: occupancy(),
      chat_messages: messages,
      chat_votes: Chat.vote_counts(ids),
      my_votes: if(chatter, do: Chat.my_votes(ids, chatter.id), else: %{})
    )
  end

  defp presence_name(nil), do: "lurker"
  defp presence_name(chatter), do: chatter.screen_name

  defp all_present do
    Presence.list(@rooms_presence)
    |> Enum.map(fn {_key, %{metas: [meta | _]}} -> meta end)
  end

  defp list_buddies(room) do
    all_present()
    |> Enum.filter(&(&1.room == room))
    |> Enum.sort_by(& &1.name)
  end

  defp occupancy do
    all_present()
    |> Enum.frequencies_by(& &1.room)
  end

  defp room(blink), do: "blink:#{blink.id}"

  # ── events ──────────────────────────────────────────────────────────────

  def handle_event("toggle-tag", %{"tag" => tag}, socket) do
    selected = socket.assigns.selected_tags

    selected =
      if tag in selected, do: List.delete(selected, tag), else: selected ++ [tag]

    {:noreply, patch(socket, tags: Enum.join(selected, ","), similar: "", page: "")}
  end

  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, patch(socket, q: q, similar: "", page: "")}
  end

  def handle_event("more", _params, socket) do
    {:noreply, patch(socket, page: to_string(socket.assigns.page + 1))}
  end

  def handle_event("prev-page", _params, socket) do
    page = max(socket.assigns.page - 1, 1)
    {:noreply, patch(socket, page: if(page > 1, do: to_string(page), else: ""))}
  end

  def handle_event("clear", _params, socket) do
    {:noreply, patch(socket, q: "", tags: "", similar: "", chat: "")}
  end

  def handle_event("similar", %{"id" => id}, socket) do
    {:noreply, patch(socket, similar: id)}
  end

  def handle_event("toggle-singles", _params, socket) do
    {:noreply, assign(socket, singles_open: !socket.assigns.singles_open)}
  end

  def handle_event("toggle-dork", _params, socket) do
    {:noreply, patch(socket, nodork: if(socket.assigns.nodork, do: "", else: "1"))}
  end

  def handle_event("edit-dork", _params, socket) do
    {:noreply, assign(socket, dork_editing: !socket.assigns.dork_editing)}
  end

  def handle_event("save-dork-tags", %{"dork_tags" => value}, socket) do
    :ok = Blinks.set_dork_tags(String.split(value, ","))

    {:noreply,
     socket
     |> assign(dork_tags: Blinks.dork_tags(), dork_editing: false)
     |> reload()}
  end

  def handle_event("open-chat", %{"id" => id}, socket) do
    {:noreply, patch(socket, chat: id)}
  end

  def handle_event("close-chat", _params, socket) do
    {:noreply, patch(socket, chat: "")}
  end

  def handle_event("sign-on", %{"screen_name" => name}, socket) do
    case String.trim(name) do
      "" ->
        {:noreply, socket}

      name ->
        case Chat.find_or_create_chatter(name, socket.assigns.visitor_ip) do
          {:ok, chatter} ->
            if socket.assigns.chat_room do
              Presence.update(self(), @rooms_presence, socket.assigns.presence_key, %{
                room: socket.assigns.chat_room,
                name: chatter.screen_name,
                color: chatter.color
              })
            end

            ids = Enum.map(socket.assigns.chat_messages, & &1.id)
            {:noreply, assign(socket, chatter: chatter, my_votes: Chat.my_votes(ids, chatter.id))}

          {:error, _} ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("vote-msg", %{"id" => id, "val" => val}, socket) do
    %{chatter: chatter, chat_messages: messages} = socket.assigns
    message = Enum.find(messages, &(to_string(&1.id) == id))
    value = if val == "1", do: 1, else: -1

    if chatter && message do
      Chat.vote_message(message, chatter, value)
      # counts arrive via the room broadcast; refresh just my own vote here
      {:noreply, assign(socket, my_votes: Chat.my_votes([message.id], chatter.id) |> then(&Map.merge(socket.assigns.my_votes, put_or_drop(&1, message.id))))}
    else
      {:noreply, socket}
    end
  end

  def handle_event("start-tour", _params, socket) do
    {:noreply, assign(socket, show_tour: true)}
  end

  def handle_event("prefs", %{"ids" => ids} = params, socket) when is_list(ids) do
    socket = socket |> assign(hidden_ids: MapSet.new(ids)) |> reload()
    socket = if params["seenTour"], do: socket, else: assign(socket, show_tour: true)
    socket = if valid_key?(params["adminKey"]), do: assign(socket, admin: true), else: socket
    {:noreply, socket}
  end

  def handle_event("unlock-admin", %{"key" => key}, socket) do
    if valid_key?(key) do
      {:noreply,
       socket
       |> assign(admin: true, admin_error: nil)
       |> push_event("blinks:admin-key", %{key: key})}
    else
      {:noreply, assign(socket, admin_error: "nope, that's not it")}
    end
  end

  def handle_event("lock-admin", _params, socket) do
    {:noreply,
     socket
     |> assign(admin: false)
     |> push_event("blinks:admin-key", %{key: nil})}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    if socket.assigns.admin do
      {id, _} = Integer.parse(id)
      # list refresh arrives via the :blink_deleted broadcast
      Blinks.delete_blink(id)
    end

    {:noreply, socket}
  end

  def handle_event("hide", %{"id" => id}, socket) do
    {id, _} = Integer.parse(id)

    {:noreply,
     socket
     |> assign(hidden_ids: MapSet.put(socket.assigns.hidden_ids, id))
     |> reload()
     |> push_event("blinks:hide", %{id: id})}
  end

  def handle_event("unhide-all", _params, socket) do
    {:noreply,
     socket
     |> assign(hidden_ids: MapSet.new())
     |> reload()
     |> push_event("blinks:unhide-all", %{})}
  end

  def handle_event("sign-off", _params, socket) do
    if socket.assigns.chat_room do
      Presence.update(self(), @rooms_presence, socket.assigns.presence_key, %{
        room: socket.assigns.chat_room,
        name: "lurker",
        color: "#888"
      })
    end

    {:noreply, assign(socket, chatter: nil)}
  end

  def handle_event("reply", %{"id" => id}, socket) do
    target = Enum.find(socket.assigns.chat_messages, &(to_string(&1.id) == id))
    {:noreply, assign(socket, replying_to: target)}
  end

  def handle_event("cancel-reply", _params, socket) do
    {:noreply, assign(socket, replying_to: nil)}
  end

  def handle_event("toggle-buddies", _params, socket) do
    {:noreply, assign(socket, show_buddies: !socket.assigns.show_buddies)}
  end

  def handle_event("mention", %{"name" => name}, socket) do
    input = String.trim_trailing(socket.assigns.chat_input)
    input = if input == "", do: "@#{name} ", else: "#{input} @#{name} "
    {:noreply, assign(socket, chat_input: input)}
  end

  def handle_event("chat-typing", %{"message" => message}, socket) do
    suggestions =
      case Regex.run(~r/@([\w.\-]*)$/, message) do
        [_, prefix] ->
          down = String.downcase(prefix)

          socket
          |> mention_candidates()
          |> Enum.filter(&String.starts_with?(String.downcase(&1), down))
          |> Enum.take(5)

        nil ->
          []
      end

    {:noreply, assign(socket, chat_input: message, mention_suggestions: suggestions)}
  end

  def handle_event("complete-mention", %{"name" => name}, socket) do
    input = Regex.replace(~r/@[\w.\-]*$/, socket.assigns.chat_input, "@#{name} ")
    {:noreply, assign(socket, chat_input: input, mention_suggestions: [])}
  end

  def handle_event("send-chat-message", %{"message" => message}, socket) do
    %{chatter: chatter, chat_blink: blink, replying_to: replying_to} = socket.assigns

    if chatter && blink && String.trim(message) != "" do
      Chat.create_message(chatter, message, room(blink),
        reply_to_id: replying_to && replying_to.id
      )
    end

    {:noreply, assign(socket, chat_input: "", replying_to: nil, mention_suggestions: [])}
  end

  def handle_info({:new_chat_message, message}, socket) do
    %{chat_blink: blink, chat_counts: counts} = socket.assigns

    if blink && message.room == room(blink) do
      {:noreply,
       assign(socket,
         chat_messages: socket.assigns.chat_messages ++ [message],
         chat_counts: Map.update(counts, message.room, 1, &(&1 + 1))
       )}
    else
      {:noreply, socket}
    end
  end

  def handle_info({:blink_saved, %Blinks.Blink{} = blink}, socket) do
    {:noreply,
     socket
     |> assign(
       total: Blinks.count_blinks(),
       fresh_ids: MapSet.put(socket.assigns.fresh_ids, blink.id)
     )
     |> reload()}
  end

  def handle_info({event, %Blinks.Blink{}}, socket)
      when event in [:blink_updated, :blink_deleted] do
    {:noreply, socket |> assign(total: Blinks.count_blinks()) |> reload()}
  end

  def handle_info({:tour_complete, _id}, socket) do
    {:noreply, socket |> assign(show_tour: false) |> push_event("blinks:tour-seen", %{})}
  end

  def handle_info({:message_vote, message_id, counts}, socket) do
    {:noreply, assign(socket, chat_votes: Map.put(socket.assigns.chat_votes, message_id, counts))}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", topic: @rooms_presence}, socket) do
    room = socket.assigns.chat_room

    {:noreply,
     assign(socket,
       rooms_live: occupancy(),
       buddies: if(room, do: list_buddies(room), else: [])
     )}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    {:noreply, socket}
  end

  # ── helpers ─────────────────────────────────────────────────────────────

  # merge helper for my_votes: fresh lookup either has the id or the vote was removed
  defp put_or_drop(fresh, id) when is_map(fresh) do
    if Map.has_key?(fresh, id), do: fresh, else: %{id => :none}
  end

  defp my_vote(my_votes, id) do
    case Map.get(my_votes, id) do
      :none -> nil
      v -> v
    end
  end

  defp votes_for(chat_votes, id), do: Map.get(chat_votes, id, {0, 0})

  defp patch(socket, overrides) do
    a = socket.assigns

    base = %{
      q: a.q,
      tags: Enum.join(a.selected_tags, ","),
      page: if(a.page > 1, do: to_string(a.page), else: ""),
      view: if(a.view == :archives, do: "archives", else: ""),
      week: if(a.week, do: Date.to_iso8601(a.week), else: ""),
      nodork: if(a.nodork, do: "1", else: ""),
      similar: if(a.similar_to, do: to_string(a.similar_to.id), else: ""),
      chat: if(a.chat_blink, do: to_string(a.chat_blink.id), else: "")
    }

    params =
      base
      |> Map.merge(Map.new(overrides))
      |> Enum.reject(fn {_k, v} -> v in [nil, ""] end)

    push_patch(socket, to: ~p"/blinks?#{params}")
  end

  defp valid_key?(key) do
    expected = Application.get_env(:blog, :blinks_api_token)

    is_binary(expected) and expected != "" and is_binary(key) and
      Plug.Crypto.secure_compare(key, expected)
  end

  defp domain(url) do
    case URI.parse(url).host do
      nil -> ""
      host -> String.replace_prefix(host, "www.", "")
    end
  end

  defp wayback(url), do: "https://web.archive.org/web/*/" <> url
  defp archive_ph(url), do: "https://archive.ph/newest/" <> url

  defp rss_href([]), do: "/blinks.rss"
  defp rss_href(tags), do: "/blinks.rss?" <> URI.encode_query(tags: Enum.join(tags, ","))

  defp comment_label(0), do: "chat"
  defp comment_label(1), do: "1 comment"
  defp comment_label(n), do: "#{n} comments"

  # Top-level = not a reply, or a reply whose parent fell outside the loaded
  # window (render it flat rather than losing it).
  defp top_messages(messages) do
    ids = MapSet.new(messages, & &1.id)

    Enum.filter(messages, fn m ->
      is_nil(m.reply_to_id) or not MapSet.member?(ids, m.reply_to_id)
    end)
  end

  defp replies_for(messages, parent), do: Enum.filter(messages, &(&1.reply_to_id == parent.id))

  @doc false
  # Markdown for chat messages: input is HTML-escaped first (so raw HTML in a
  # message can never execute), then rendered with headings demoted to h3 max,
  # unsafe link schemes stripped, links opened in new tabs, and @mentions
  # wrapped for highlighting.
  def render_md(content, chatter) do
    content
    |> Plug.HTML.html_escape()
    |> then(&Regex.replace(~r/^\#{1,2}\s/m, &1, "### "))
    |> Earmark.as_html!(compact_output: true, smartypants: false)
    |> String.replace(~r/href="(javascript|data|vbscript):[^"]*"/i, ~s(href="#"))
    |> String.replace("<a href=", ~s(<a target="_blank" rel="noopener nofollow" href=))
    |> highlight_mentions(chatter)
    |> Phoenix.HTML.raw()
  end

  defp highlight_mentions(html, chatter) do
    me = chatter && "@" <> chatter.screen_name

    Regex.replace(~r/(^|[\s>])(@[\w.\-]+)/, html, fn _, pre, mention ->
      class = if mention == me, do: "mention me", else: "mention"
      ~s(#{pre}<span class="#{class}">#{mention}</span>)
    end)
  end

  defp sender_name(message),
    do: (message.chatter && message.chatter.screen_name) || "Anonymous"

  defp sender_color(message), do: (message.chatter && message.chatter.color) || "#666"

  defp thread_posts(%{thread: %{"posts" => posts}}) when is_list(posts), do: posts
  defp thread_posts(_blink), do: []

  defp root_quote(blink) do
    case thread_posts(blink) do
      [%{"quote" => %{} = quote} | _] -> quote
      _ -> nil
    end
  end

  # Row headline: first quote wins, then a thread's top-level post, then title.
  defp headline(blink) do
    cond do
      blink.quotes != [] ->
        "“#{List.first(blink.quotes)}”"

      thread_posts(blink) != [] ->
        thread_posts(blink) |> hd() |> Map.get("text", "") |> String.slice(0, 140)

      true ->
        blink.title || blink.url
    end
  end

  defp frequent_tags(tags), do: Enum.filter(tags, &(&1.count >= 2))
  defp single_tags(tags), do: Enum.filter(tags, &(&1.count == 1))

  # Names worth autocompleting: whoever is in the room now + whoever has posted.
  defp mention_candidates(socket) do
    from_presence = socket.assigns.buddies |> Enum.map(& &1.name) |> Enum.reject(&(&1 == "lurker"))
    from_messages = socket.assigns.chat_messages |> Enum.map(&sender_name/1)

    Enum.uniq(from_presence ++ from_messages) -- ["Anonymous"]
  end

  def render(assigns) do
    ~H"""
    <div id="blinks-page" phx-hook="BlinksPrefs">
      <style>
        #blinks-page, #blinks-page *, #blinks-page *::before, #blinks-page *::after { box-sizing: border-box; }
        /* the outer shell never scrolls; inner regions (paper, sidebar, chat) do */
        #blinks-page { font: 12px verdana, arial, helvetica, sans-serif; color: #000; background: #fff; height: 100dvh; display: flex; flex-direction: column; overflow: hidden; }
        #blinks-page .masthead { flex-shrink: 0; }
        #blinks-page a { text-decoration: none; }
        #blinks-page .masthead { background: #cee3f8; border-bottom: 1px solid #5f99cf; padding: 4px 10px; display: flex; align-items: baseline; gap: 12px; flex-wrap: wrap; }
        #blinks-page .masthead h1 { font-size: 15px; font-weight: bold; letter-spacing: -0.5px; margin: 0; display: inline; }
        #blinks-page .masthead h1 span { color: #ff4500; }
        #blinks-page .dateline { color: #369; font-size: 10px; }
        #blinks-page .tabs { display: flex; gap: 3px; align-self: flex-end; margin-bottom: -5px; }
        #blinks-page .tabs .tab { font-size: 11px; font-weight: bold; color: #369; background: #b9d2ec; border: 1px solid #5f99cf; border-bottom: none; border-radius: 3px 3px 0 0; padding: 2px 10px; }
        #blinks-page .tabs .tab.on { background: #fff; color: #ff4500; }
        #blinks-page .bundles { overflow-y: auto; min-height: 0; }
        #blinks-page .bundle { display: block; border: 1px solid #ddd; border-radius: 2px; padding: 7px 10px; margin-bottom: 6px; }
        #blinks-page .bundle:hover { border-color: #5f99cf; background: #f5f9fd; }
        #blinks-page .bundle b { color: #0000ff; font-size: 13px; }
        #blinks-page .bundle .bcount { color: #888; font-size: 10px; margin-left: 8px; }
        #blinks-page .bundle .bpreview { color: #888; font-size: 10px; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        #blinks-page .tour-link { color: #369; font-size: 10px; font-weight: bold; cursor: pointer; }
        #blinks-page .searchform { margin-left: auto; }
        #blinks-page .searchform input[type="text"] { border: 1px solid #5f99cf; font-size: 12px; padding: 2px 4px; width: 220px; }

        #blinks-page .layout { display: flex; gap: 16px; padding: 8px 10px; align-items: stretch; flex: 1 1 auto; min-height: 0; overflow: hidden; }
        #blinks-page .links { flex: 1; min-width: 0; display: flex; flex-direction: column; min-height: 0; }
        #blinks-page .filterbar { margin: 0 0 6px; color: #888; font-size: 11px; }
        #blinks-page .filterbar .clear { color: #369; cursor: pointer; }

        /* posts fill column one to the bottom of the screen, then flow to the
           next column; overflow makes more columns you scroll sideways to */
        #blinks-page .paper { flex: 1 1 auto; min-height: 0; columns: 2; column-gap: 44px; column-fill: auto; column-rule: 1px solid #ddd; overflow-x: auto; overflow-y: hidden; }

        #blinks-page .thing { display: block; padding: 3px 0; break-inside: avoid; -webkit-column-break-inside: avoid; }
        /* dead links: the whole row fades to a readable grey */
        #blinks-page .thing.dead { filter: grayscale(1); opacity: 0.55; }
        #blinks-page .thing.dead .title { color: #666; }
        /* new arrivals tune in from static, like a channel coming in */
        #blinks-page .thing.fresh { position: relative; animation: blinks-detune 2.2s ease-out both; }
        #blinks-page .thing.fresh::after { content: ""; position: absolute; inset: 0; pointer-events: none; mix-blend-mode: hard-light; background-image: repeating-radial-gradient(circle at 17% 32%, #000 0 1px, transparent 1px 2px), repeating-radial-gradient(circle at 73% 61%, #fff 0 1px, transparent 1px 3px), repeating-linear-gradient(0deg, rgba(0,0,0,0.35) 0 1px, transparent 1px 3px); background-size: 7px 7px, 11px 11px, 100% 4px; animation: blinks-staticfuzz 2.2s steps(10) both; }
        @keyframes blinks-detune {
          0% { filter: blur(3px) saturate(0) contrast(2.6) brightness(1.4); opacity: 0.15; }
          35% { filter: blur(2px) saturate(0.1) contrast(2.1) brightness(1.2); opacity: 0.5; }
          70% { filter: blur(0.8px) saturate(0.5) contrast(1.4); opacity: 0.85; }
          100% { filter: none; opacity: 1; }
        }
        @keyframes blinks-staticfuzz {
          0% { opacity: 0.9; background-position: 0 0, 0 0, 0 0; }
          15% { background-position: 3px 2px, -4px 3px, 0 2px; }
          30% { background-position: -2px 4px, 5px -2px, 0 -1px; opacity: 0.75; }
          45% { background-position: 4px -3px, -3px -4px, 0 3px; }
          60% { background-position: -4px 1px, 2px 4px, 0 -2px; opacity: 0.5; }
          75% { background-position: 2px -4px, -5px 2px, 0 1px; opacity: 0.3; }
          90% { background-position: -3px 3px, 4px -1px, 0 -3px; opacity: 0.12; }
          100% { opacity: 0; }
        }
        @media (prefers-reduced-motion: reduce) {
          #blinks-page .thing.fresh, #blinks-page .thing.fresh::after { animation: none; }
        }
        #blinks-page .rank { color: #c6c6c6; font-size: 11px; margin-right: 3px; }
        #blinks-page .thumb { width: 48px; height: 36px; object-fit: cover; border: 1px solid #ddd; float: left; margin-right: 6px; }
        #blinks-page .favicon { width: 11px; height: 11px; vertical-align: -2px; margin-right: 2px; }
        #blinks-page .entry { display: inline; }
        #blinks-page .title { font-size: 13px; color: #0000ff; }
        #blinks-page .title:visited { color: #551a8b; }
        #blinks-page .domain { color: #888; font-size: 10px; }
        #blinks-page .domain a { color: #888; }
        #blinks-page .desc { color: #333; font-size: 11px; margin: 1px 0; max-width: 72ch; }
        #blinks-page .notes { margin: 0; display: inline; }
        #blinks-page .notes summary { display: inline-block; cursor: pointer; color: #fff; background: #369; border: 1px outset #5f99cf; border-radius: 2px; font-size: 8px; font-weight: bold; letter-spacing: 0.5px; padding: 1px 5px; list-style: none; user-select: none; }
        #blinks-page .notes summary::-webkit-details-marker { display: none; }
        #blinks-page .notes summary::before { content: "TAP FOR WORDS"; }
        #blinks-page .notes[open] summary { border-style: inset; background: #1d4568; }
        #blinks-page .notes[open] summary::before { content: "OK ENOUGH WORDS"; }
        #blinks-page .title.quoted { font-style: italic; }
        #blinks-page .subtitle { color: #888; font-size: 10px; }
        #blinks-page .pillbtn { display: inline-block; cursor: pointer; color: #fff; background: #369; border: 1px outset #5f99cf; border-radius: 2px; font-size: 8px; font-weight: bold; letter-spacing: 0.5px; padding: 1px 5px; list-style: none; user-select: none; }
        #blinks-page .pillbtn::-webkit-details-marker { display: none; }
        #blinks-page .xd { display: inline; margin: 0; }
        #blinks-page .xd[open] .pillbtn { border-style: inset; background: #1d4568; }
        #blinks-page .threadmark { display: inline; cursor: pointer; color: #369; font-size: 10px; font-weight: bold; list-style: none; user-select: none; }
        #blinks-page .threadmark::-webkit-details-marker { display: none; }
        #blinks-page .quote-item { font-style: italic; color: #333; font-size: 11px; border-left: 3px solid #ddd; padding-left: 6px; margin: 3px 0; max-width: 72ch; }
        #blinks-page .thread-view { margin: 4px 0; max-width: 72ch; }
        #blinks-page .tpost { border-left: 2px solid #cee3f8; margin: 0 0 6px 4px; padding: 2px 0 2px 8px; }
        #blinks-page .tpost .thandle { color: #888; font-size: 9px; margin-left: 4px; }
        #blinks-page .tpost .ttext { white-space: pre-wrap; font-size: 11px; color: #222; margin-top: 1px; }
        #blinks-page .tquote { border-left: 2px solid #ddd; margin: 3px 0 0 6px; padding-left: 6px; color: #555; font-size: 10px; white-space: pre-wrap; }
        #blinks-page .bsky-quote { color: #555; font-size: 11px; font-style: italic; border-left: 3px solid #cee3f8; padding-left: 6px; margin: 1px 0; max-width: 72ch; white-space: pre-wrap; }
        #blinks-page .meta { font-size: 9px; margin-top: 1px; }
        #blinks-page .meta a { color: #888; font-weight: bold; margin-right: 6px; cursor: pointer; }
        #blinks-page .meta a.del { color: #c00; }
        #blinks-page .live-dot { display: inline-block; width: 7px; height: 7px; border-radius: 50%; background: #7fbf00; margin-right: 3px; vertical-align: 0; animation: blinks-pulse 2s ease-in-out infinite; }
        #blinks-page .live-n { color: #4a8000; }
        @keyframes blinks-pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.35; } }
        #blinks-page .tag { display: inline-block; background: #f5f5f5; border: 1px solid #ddd; border-radius: 2px; color: #369; font-size: 9px; padding: 0 3px; margin: 0 2px 1px 0; cursor: pointer; }
        #blinks-page .tag.on { background: #cee3f8; border-color: #5f99cf; font-weight: bold; }
        #blinks-page .empty { color: #888; padding: 20px 0; }
        #blinks-page .pager { flex-shrink: 0; padding: 6px 0 2px; display: flex; align-items: center; gap: 10px; }
        #blinks-page .pager button { font: bold 12px verdana; color: #888; background: #f5f5f5; border: 1px solid #ddd; border-radius: 2px; padding: 4px 14px; cursor: pointer; letter-spacing: 1px; }
        #blinks-page .pager button:hover { color: #369; border-color: #5f99cf; }
        #blinks-page .pager .pageno { color: #888; font-size: 10px; }

        #blinks-page .sidebar { width: 280px; flex-shrink: 0; overflow-y: auto; min-height: 0; }
        #blinks-page .sidebox { border: 1px solid #5f99cf; margin-bottom: 12px; }
        #blinks-page .sidebox h2 { background: #cee3f8; color: #369; font-size: 11px; font-weight: bold; margin: 0; padding: 3px 6px; }
        #blinks-page .sidebox .body { padding: 6px; }
        #blinks-page .tag-cloud { display: flex; flex-wrap: wrap; gap: 3px; }
        #blinks-page .tag-cloud .tag { font-size: 10px; padding: 0 4px; }
        #blinks-page .tag .tcount { color: #888; font-size: 9px; margin-left: 3px; }
        #blinks-page .tag.on .tcount { color: #eee; }
        #blinks-page .singles-link { color: #369; font-size: 10px; cursor: pointer; font-weight: bold; }
        #blinks-page .singles-pop { position: absolute; left: 4px; right: 4px; z-index: 500; margin-top: 4px; background: #fff; border: 1px solid #5f99cf; box-shadow: 2px 2px 6px rgba(0,0,0,0.25); padding: 6px; max-height: 200px; overflow-y: auto; display: flex; flex-wrap: wrap; gap: 3px; }

        #blinks-page .dork-btn { display: block; width: 100%; font: bold 14px verdana; padding: 9px 0; margin-bottom: 6px; cursor: pointer; border: 3px outset #ff4500; background: #ff4500; color: #fff; letter-spacing: 1px; }
        #blinks-page .dork-btn.on { border-style: inset; background: #b33000; }
        #blinks-page .dork-edit { color: #888; font-size: 10px; cursor: pointer; }
        #blinks-page .dork-form input { width: 100%; border: 1px solid #5f99cf; font-size: 11px; padding: 3px; margin: 4px 0; }

        /* Win95 chat window: big but never oversized on desktop */
        #blinks-page .win95 { position: fixed; top: 90px; right: 16px; width: min(56vw, 920px); max-width: calc(100vw - 32px); min-width: 340px; z-index: 1000; background: #c0c0c0; border: 2px solid; border-color: #dfdfdf #404040 #404040 #dfdfdf; box-shadow: 1px 1px 0 #000, 4px 4px 8px rgba(0,0,0,0.4); font-family: "Tahoma", "MS Sans Serif", verdana, sans-serif; }
        @media (max-width: 1250px) { #blinks-page .win95 { width: min(440px, calc(100vw - 40px)); } }
        #blinks-page .win95.sized { display: flex; flex-direction: column; height: calc(100vh - 110px); max-height: calc(100vh - 100px); min-height: 320px; resize: both; overflow: hidden; }
        @media (max-width: 1250px) { #blinks-page .win95.sized { height: min(72vh, 640px); } }
        #blinks-page .win95-titlebar { display: flex; align-items: center; gap: 6px; background: linear-gradient(90deg, #000080, #1084d0); color: #fff; font-weight: bold; font-size: 11px; padding: 3px 4px; cursor: move; user-select: none; }
        #blinks-page .win95-titlebar .t { flex: 1; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        #blinks-page .win95-btn { width: 16px; height: 14px; font-size: 9px; line-height: 1; background: #c0c0c0; border: 1px solid; border-color: #fff #404040 #404040 #fff; color: #000; cursor: pointer; font-weight: bold; padding: 0; }
        #blinks-page .win95-menubar { font-size: 11px; padding: 2px 6px; color: #000; border-bottom: 1px solid #808080; }
        #blinks-page .win95-menubar span { margin-right: 10px; }
        #blinks-page .aim-messages { background: #fff; border: 2px inset #808080; margin: 6px; height: min(55vh, 480px); overflow-y: auto; padding: 4px 6px; font-size: 12px; }
        #blinks-page .win95.sized .aim-messages { flex: 1; height: auto; min-height: 100px; }
        #blinks-page .aim-msg { margin-bottom: 3px; word-wrap: break-word; }
        #blinks-page .aim-msg .sn { font-weight: bold; }
        #blinks-page .aim-msg .ts { color: #888; font-size: 9px; margin-left: 4px; }
        #blinks-page .reply-link { color: #888; font-size: 9px; font-weight: bold; margin-left: 6px; cursor: pointer; }
        /* slack-style reactions: hidden until hover, existing ones show as pills */
        #blinks-page .votes { display: block; margin: 1px 0 2px; font-size: 9px; }
        #blinks-page .votes a { visibility: hidden; cursor: pointer; color: #888; margin-right: 4px; }
        #blinks-page .msg-main:hover .votes a, #blinks-page .aim-reply:hover .votes a { visibility: visible; }
        #blinks-page .votes a.haz { visibility: visible; background: #f8f8f8; border: 1px solid #ddd; border-radius: 10px; padding: 0 5px; }
        #blinks-page .votes a.on { visibility: visible; background: #e8f2fc; border: 1px solid #1264a3; color: #1264a3; font-weight: bold; border-radius: 10px; padding: 0 5px; }
        #blinks-page .aim-reply { margin: 3px 0 3px 16px; border-left: 3px solid #cee3f8; padding-left: 6px; }
        #blinks-page .mention { color: #000080; font-weight: bold; }
        #blinks-page .mention.me { background: #ffff99; }
        /* markdown in messages */
        #blinks-page .md p { margin: 0 0 2px; }
        #blinks-page .md a { color: #0000c0; text-decoration: underline; }
        #blinks-page .md h3 { font-size: 13px; margin: 3px 0 1px; }
        #blinks-page .md code { background: #f4f4f4; border: 1px solid #e0e0e0; font-size: 11px; padding: 0 2px; }
        #blinks-page .md pre { background: #f4f4f4; border: 1px solid #ddd; padding: 4px 6px; margin: 2px 0; overflow-x: auto; }
        #blinks-page .md pre code { border: none; }
        #blinks-page .md ul, #blinks-page .md ol { margin: 2px 0 2px 20px; }
        #blinks-page .md blockquote { margin: 2px 0 2px 4px; border-left: 3px solid #ccc; padding-left: 6px; color: #555; }
        #blinks-page .replying-bar { margin: 0 6px 4px; padding: 3px 6px; background: #ffffcc; border: 1px solid #808080; font-size: 11px; }
        #blinks-page .aim-compose { margin: 0 6px 6px; }
        #blinks-page .aim-compose textarea.aim-box { width: 100%; height: 72px; border: 2px inset #808080; font: 12px Tahoma, verdana, sans-serif; padding: 5px; resize: vertical; background: #fff; }
        #blinks-page .aim-compose-row { display: flex; justify-content: space-between; align-items: center; margin-top: 4px; }
        #blinks-page .aim-send { font: bold 11px Tahoma, verdana; padding: 4px 14px; background: #c0c0c0; border: 2px outset #dfdfdf; cursor: pointer; }
        #blinks-page .aim-send:active { border-style: inset; }
        #blinks-page .mention-suggest { margin: 0 6px 4px; font-size: 10px; color: #888; }
        #blinks-page .mention-suggest .tag { cursor: pointer; font-family: inherit; font-size: 10px; padding: 0 4px; }
        #blinks-page .aim-signon { margin: 10px; padding: 14px; background: #ffffcc; border: 1px solid #808080; text-align: center; font-size: 12px; }
        #blinks-page .aim-signon .man { font-size: 34px; }
        #blinks-page .aim-signon input { border: 2px inset #808080; font-size: 16px; padding: 4px; width: 100%; max-width: 320px; margin: 8px 0; }
        #blinks-page .aim-link { font-size: 10px; color: #888; margin: 0 8px 6px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        #blinks-page .buddy-panel { background: #fff; border: 2px inset #808080; margin: 6px; max-height: 240px; overflow-y: auto; padding: 4px 6px; font-size: 12px; }
        #blinks-page .buddy-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; background: #7fbf00; margin-right: 5px; }
        #blinks-page .win95.buddies { left: auto; right: 40px; top: 120px; width: 220px; min-width: 0; z-index: 1001; }

        @media (max-width: 800px) {
          /* phones keep normal document scrolling — a locked shell is misery there */
          #blinks-page { height: auto; display: block; overflow: visible; }
          #blinks-page .layout { flex-direction: column; overflow: visible; }
          #blinks-page .paper { columns: 1; height: auto; overflow: visible; }
          #blinks-page .sidebar { width: 100%; overflow-y: visible; }
          #blinks-page .masthead .searchform { margin-left: 0; width: 100%; }
          #blinks-page .searchform input[type="text"] { width: 100%; }
          /* bigger tap targets */
          #blinks-page .title { font-size: 15px; }
          #blinks-page .meta { font-size: 11px; }
          #blinks-page .meta a { margin-right: 10px; }
          #blinks-page .tag { font-size: 11px; padding: 1px 5px; }
          /* chat goes fullscreen on phones (beats any dragged inline style) */
          #blinks-page .win95 { top: 0 !important; left: 0 !important; right: 0 !important; bottom: 0 !important; width: 100vw !important; height: 100dvh !important; max-width: none; min-width: 0; border-width: 0; transform: none !important; }
          #blinks-page .win95.sized { height: 100dvh !important; max-height: none; resize: none; }
          #blinks-page .win95 .aim-messages { flex: 1; height: auto; }
          #blinks-page .win95.buddies { top: 15% !important; left: 8% !important; right: 8% !important; bottom: auto !important; width: auto !important; height: auto !important; border-width: 2px; }
          /* 16px+ inputs stop iOS from auto-zooming (which shoves the layout sideways) */
          #blinks-page input[type="text"], #blinks-page textarea { font-size: 16px; }
        }
      </style>

      <.live_component
        module={LiveJoyride.Component}
        id="blinks-tour"
        steps={@tour_steps}
        run={@show_tour}
      />

      <header class="masthead">
        <h1>bobbby's <span>links</span></h1>
        <nav class="tabs">
          <.link patch={~p"/blinks"} class={["tab", @view == :live && "on"]}>live</.link>
          <.link patch={~p"/blinks?view=archives"} class={["tab", @view == :archives && "on"]}>
            archives
          </.link>
        </nav>
        <span class="dateline">{@total} saved</span>
        <a class="tour-link" phx-click="start-tour">tour</a>
        <a class="tour-link" href="/blinks/stumble" target="_blank" title="a random saved link">
          stumble 🎲
        </a>
        <form class="searchform" phx-submit="search" data-joyride="search">
          <input type="text" name="q" value={@q} placeholder="search title, tags, notes…" />
        </form>
      </header>

      <div class="layout">
        <div class="links">
          <button class={["dork-btn", @nodork && "on"]} phx-click="toggle-dork">
            {if @nodork,
              do: "✓ HIDING THE ULTRA NERDY STUFF (#{length(@dork_tags)} tags)",
              else: "CLICK TO HIDE THE ULTRA NERDY STUFF"}
          </button>
          <div style="margin: -2px 0 6px;">
            <span class="dork-edit" phx-click="edit-dork">
              {if @dork_editing, do: "cancel", else: "edit dork list (#{Enum.join(@dork_tags, ", ")})"}
            </span>
            <form :if={@dork_editing} class="dork-form" phx-submit="save-dork-tags">
              <input
                type="text"
                name="dork_tags"
                value={Enum.join(@dork_tags, ", ")}
                placeholder="tags that count as dork stuff, comma separated"
              />
              <button class="aim-send" type="submit">save</button>
            </form>
          </div>

          <div :if={@similar_to} class="filterbar">
            links similar to
            <a href={@similar_to.url} target="_blank" rel="noopener" style="color:#369;">
              {@similar_to.title || @similar_to.url}
            </a>
            &nbsp;<span class="clear" phx-click="clear">back to all</span>
          </div>

          <div :if={!@similar_to && (@selected_tags != [] or @q != "")} class="filterbar">
            filtering:
            <span
              :for={tag <- @selected_tags}
              class="tag on"
              phx-click="toggle-tag"
              phx-value-tag={tag}
              title="remove"
            >
              {tag} ✕
            </span>
            <span :if={@q != ""}>“{@q}”</span>
            &nbsp;<span class="clear" phx-click="clear">clear all</span>
          </div>

          <div :if={@view == :archives && is_nil(@week)} class="bundles">
            <div :if={@weeks == []} class="empty">no weeks archived yet.</div>
            <.link
              :for={bundle <- @weeks}
              patch={~p"/blinks?view=archives&week=#{Date.to_iso8601(bundle.monday)}"}
              class="bundle"
            >
              <b>Week of {Calendar.strftime(bundle.monday, "%b %-d")} –
                {Calendar.strftime(Date.add(bundle.monday, 6), "%b %-d, %Y")}</b>
              <span class="bcount">{bundle.count} links</span>
              <div class="bpreview">{Enum.join(bundle.titles, " · ")}</div>
            </.link>
          </div>

          <div :if={@week} class="filterbar">
            <b>
              Week of {Calendar.strftime(@week, "%b %-d")} –
              {Calendar.strftime(Date.add(@week, 6), "%b %-d, %Y")}
            </b>
            · {length(@blinks)} links ·
            <.link patch={~p"/blinks?view=archives"} class="clear">← all weeks</.link>
          </div>

          <div :if={MapSet.size(@hidden_ids) > 0} class="filterbar">
            {MapSet.size(@hidden_ids)} hidden by you ·
            <span class="clear" phx-click="unhide-all">unhide all</span>
          </div>

          <div :if={@blinks == [] && !(@view == :archives && is_nil(@week))} class="empty">
            nothing here. go save some links.
          </div>

          <div class="paper">
            <div
              :for={{blink, i} <- Enum.with_index(@blinks, 1)}
              class={[
                "thing",
                MapSet.member?(@fresh_ids, blink.id) && "fresh",
                blink.dead_at && "dead"
              ]}
              id={"blink-#{blink.id}"}
            >
              <span class="rank">{(@page - 1) * 50 + i}</span>
              <img :if={blink.image_url} class="thumb" src={blink.image_url} loading="lazy" />
              <div class="entry">
                <a
                  class={["title", blink.quotes != [] && "quoted"]}
                  href={if blink.dead_at, do: "https://web.archive.org/web/2/" <> blink.url, else: blink.url}
                  target="_blank"
                  rel="noopener"
                  title={blink.dead_at && "original link is dead — points at the wayback copy"}
                >
                  {headline(blink)}
                </a>
                <span class="domain">
                  (<img :if={blink.favicon_url} class="favicon" src={blink.favicon_url} loading="lazy" /><a href={
                    "/blinks?" <> URI.encode_query(q: domain(blink.url))
                  }>{blink.site_name || domain(blink.url)}</a>)
                </span>
                <div :if={blink.quotes != [] && blink.title} class="subtitle">{blink.title}</div>
                <div :if={root_quote(blink)} class="bsky-quote">
                  ↳ quoting <b>@{root_quote(blink)["handle"]}</b>: “{root_quote(blink)["text"]}”
                </div>
                <div class="meta">
                  <span :for={tag <- blink.tags}>
                    <span
                      class={["tag", tag in @selected_tags && "on"]}
                      phx-click="toggle-tag"
                      phx-value-tag={tag}
                    >
                      {tag}
                    </span>
                  </span>
                </div>
                <div class="meta">
                  <a
                    phx-click="open-chat"
                    phx-value-id={blink.id}
                    style={Map.get(@chat_counts, room(blink), 0) > 0 && "color:#369;"}
                    data-joyride={i == 1 && "chat-link"}
                  >
                    <span :if={Map.get(@rooms_live, room(blink), 0) > 0} class="live-dot"></span>{comment_label(
                      Map.get(@chat_counts, room(blink), 0)
                    )}<span :if={Map.get(@rooms_live, room(blink), 0) > 0} class="live-n"> · {Map.get(@rooms_live, room(blink))} here now</span>
                  </a>
                  <a href={wayback(blink.url)} target="_blank" rel="noopener">wayback</a>
                  <a href={archive_ph(blink.url)} target="_blank" rel="noopener">archive.ph</a>
                  <a
                    phx-click="hide"
                    phx-value-id={blink.id}
                    title="hide this link on this device"
                    data-joyride={i == 1 && "hide-link"}
                  >
                    hide
                  </a>
                  <a
                    :if={@admin}
                    class="del"
                    phx-click="delete"
                    phx-value-id={blink.id}
                    data-confirm={"delete “#{blink.title || blink.url}” and its chat forever?"}
                  >
                    delete
                  </a>
                  <details :if={blink.description} class="notes">
                    <summary></summary>
                    <div class="desc">{blink.description}</div>
                  </details>
                  <details :if={length(blink.quotes) > 1} class="xd">
                    <summary class="pillbtn">{length(blink.quotes)} QUOTES</summary>
                    <div>
                      <div :for={quote <- blink.quotes} class="quote-item">“{quote}”</div>
                    </div>
                  </details>
                  <details :if={length(thread_posts(blink)) > 1} class="xd">
                    <summary class="threadmark" title="unroll the whole thread">
                      🧵 {length(thread_posts(blink))}
                    </summary>
                    <div class="thread-view">
                      <div :for={post <- thread_posts(blink)} class="tpost">
                        <b>{post["name"] || post["handle"]}</b>
                        <span class="thandle">@{post["handle"]}</span>
                        <div class="ttext">{post["text"]}</div>
                        <div :if={post["quote"]} class="tquote">
                          ↳ <b>@{post["quote"]["handle"]}</b>: “{post["quote"]["text"]}”
                        </div>
                      </div>
                    </div>
                  </details>
                </div>
              </div>
            </div>
          </div>

          <div :if={!@similar_to && (@has_more or @page > 1)} class="pager">
            <button :if={@page > 1} phx-click="prev-page">‹ BACK</button>
            <span :if={@page > 1} class="pageno">page {@page}</span>
            <button :if={@has_more} phx-click="more">MORE ›</button>
          </div>
        </div>

        <div class="sidebar">
          <div class="sidebox" data-joyride="tags-box">
            <h2>tags</h2>
            <div class="body" style="position:relative;">
              <div :if={@tags == []} style="color:#888;">no tags yet</div>
              <div class="tag-cloud">
                <span
                  :for={tag <- frequent_tags(@tags)}
                  class={["tag", tag.name in @selected_tags && "on"]}
                  phx-click="toggle-tag"
                  phx-value-tag={tag.name}
                >
                  {tag.name}<span class="tcount">{tag.count}</span>
                </span>
              </div>
              <div :if={single_tags(@tags) != []} style="margin-top:6px;">
                <span class="singles-link" phx-click="toggle-singles">
                  {if @singles_open, do: "▴ hide", else: "▾ show"} {length(single_tags(@tags))} one-offs
                </span>
                <div :if={@singles_open} class="singles-pop">
                  <span
                    :for={tag <- single_tags(@tags)}
                    class={["tag", tag.name in @selected_tags && "on"]}
                    phx-click="toggle-tag"
                    phx-value-tag={tag.name}
                  >
                    {tag.name}
                  </span>
                </div>
              </div>
            </div>
          </div>
          <div class="sidebox">
            <h2>feeds</h2>
            <div class="body">
              <a href={rss_href(@selected_tags)} style="color:#369;">rss</a>
              <span :if={@selected_tags != []} style="color:#888;">
                (for {Enum.join(@selected_tags, " + ")})
              </span>
            </div>
          </div>
          <div class="sidebox">
            <h2>admin</h2>
            <div class="body">
              <%= if @admin do %>
                <span style="color:#4a8000; font-weight:bold;">✓ unlocked</span>
                — delete links from their rows.
                <a phx-click="lock-admin" style="color:#369; cursor:pointer;">lock</a>
              <% else %>
                <form phx-submit="unlock-admin">
                  <input
                    type="password"
                    name="key"
                    placeholder="paste API key…"
                    style="width:100%; border:1px solid #5f99cf; font-size:11px; padding:3px; margin-bottom:4px;"
                  />
                  <button class="aim-send" type="submit">unlock</button>
                  <span :if={@admin_error} style="color:#c00; font-size:10px;">
                    {@admin_error}
                  </span>
                </form>
              <% end %>
            </div>
          </div>
          <div class="sidebox">
            <h2>about</h2>
            <div class="body" style="color:#555;">
              bobby's links. click tags to combine them — you'll see everything
              carrying any of them. every link is also a chat room.
            </div>
          </div>
        </div>
      </div>

      <div
        :if={@chat_blink}
        class={["win95", @chatter && "sized"]}
        id="blink-chat-window"
        phx-hook="Draggable"
        data-joyride="chat-window"
      >
        <div class="win95-titlebar title-bar">
          <span>💬</span>
          <span class="t">AOL Instant Messenger — {@chat_blink.title || domain(@chat_blink.url)}</span>
          <button class="win95-btn" phx-click="close-chat" title="Close">✕</button>
        </div>
        <div class="win95-menubar">
          <span>File</span><span>Edit</span><span>Insert</span>
          <span style="cursor:pointer; text-decoration:underline;" phx-click="toggle-buddies">
            People ({length(@buddies)})
          </span>
        </div>
        <div class="aim-link">
          re: <a href={@chat_blink.url} target="_blank" rel="noopener" style="color:#369;">{@chat_blink.url}</a>
        </div>

        <%= if @chatter do %>
          <div class="aim-messages" id="blink-chat-messages" phx-hook="ChatScroll">
            <div class="aim-msg">
              <span class="sn" style="color:#000080;">ChatBot</span>
              <div>This is both a comments section and a live discussion, join it</div>
            </div>
            <div :for={message <- top_messages(@chat_messages)} class="aim-msg">
              <div class="msg-main">
                <span
                  class="sn"
                  style={"color: #{sender_color(message)}; cursor: pointer;"}
                  phx-click="mention"
                  phx-value-name={sender_name(message)}
                >
                  {sender_name(message)}:
                </span>
                <span class="ts">{Calendar.strftime(message.inserted_at, "%I:%M %p")}</span>
                <a class="reply-link" phx-click="reply" phx-value-id={message.id}>reply</a>
                <div class="md">{render_md(message.content, @chatter)}</div>
                <span class="votes">
                  <a
                    class={[
                      my_vote(@my_votes, message.id) == 1 && "on",
                      elem(votes_for(@chat_votes, message.id), 0) > 0 && "haz"
                    ]}
                    phx-click="vote-msg"
                    phx-value-id={message.id}
                    phx-value-val="1"
                  >👍{elem(votes_for(@chat_votes, message.id), 0)}</a>
                  <a
                    class={[
                      my_vote(@my_votes, message.id) == -1 && "on",
                      elem(votes_for(@chat_votes, message.id), 1) > 0 && "haz"
                    ]}
                    phx-click="vote-msg"
                    phx-value-id={message.id}
                    phx-value-val="-1"
                  >👎{elem(votes_for(@chat_votes, message.id), 1)}</a>
                </span>
              </div>
              <div :for={reply <- replies_for(@chat_messages, message)} class="aim-reply">
                <span
                  class="sn"
                  style={"color: #{sender_color(reply)}; cursor: pointer;"}
                  phx-click="mention"
                  phx-value-name={sender_name(reply)}
                >
                  {sender_name(reply)}:
                </span>
                <span class="ts">{Calendar.strftime(reply.inserted_at, "%I:%M %p")}</span>
                <a class="reply-link" phx-click="reply" phx-value-id={reply.id}>reply</a>
                <div class="md">{render_md(reply.content, @chatter)}</div>
                <span class="votes">
                  <a
                    class={[
                      my_vote(@my_votes, reply.id) == 1 && "on",
                      elem(votes_for(@chat_votes, reply.id), 0) > 0 && "haz"
                    ]}
                    phx-click="vote-msg"
                    phx-value-id={reply.id}
                    phx-value-val="1"
                  >👍{elem(votes_for(@chat_votes, reply.id), 0)}</a>
                  <a
                    class={[
                      my_vote(@my_votes, reply.id) == -1 && "on",
                      elem(votes_for(@chat_votes, reply.id), 1) > 0 && "haz"
                    ]}
                    phx-click="vote-msg"
                    phx-value-id={reply.id}
                    phx-value-val="-1"
                  >👎{elem(votes_for(@chat_votes, reply.id), 1)}</a>
                </span>
              </div>
            </div>
          </div>

          <div :if={@replying_to} class="replying-bar">
            ↪ replying to <b>{sender_name(@replying_to)}</b>
            “{String.slice(@replying_to.content, 0, 40)}{if String.length(@replying_to.content) > 40, do: "…"}”
            <a phx-click="cancel-reply" style="cursor:pointer; color:#b33000; font-weight:bold;">✕</a>
          </div>

          <div :if={@mention_suggestions != []} class="mention-suggest">
            @…
            <button
              :for={name <- @mention_suggestions}
              type="button"
              class="tag"
              phx-click="complete-mention"
              phx-value-name={name}
            >
              {name}
            </button>
          </div>

          <form class="aim-compose" phx-submit="send-chat-message" phx-change="chat-typing">
            <textarea
              name="message"
              class="aim-box"
              placeholder={"chatting as #{@chatter.screen_name} — say something real"}
              maxlength="500"
            >{@chat_input}</textarea>
            <div class="aim-compose-row">
              <button type="button" class="aim-send" phx-click="toggle-buddies">
                Who's Here ({length(@buddies)})
              </button>
              <span style="font-size:9px; color:#666;">
                you're {@chatter.screen_name}
                <a phx-click="sign-off" style="color:#369; cursor:pointer;">(not you?)</a>
              </span>
              <button type="submit" class="aim-send">Send</button>
            </div>
          </form>
        <% else %>
          <div class="aim-signon">
            <div class="man">🏃</div>
            <b>{if @returning_name, do: "Welcome back — confirm your name", else: "Sign On to chat"}</b>
            <form phx-submit="sign-on">
              <input
                type="text"
                name="screen_name"
                value={@returning_name}
                placeholder="Screen Name"
                maxlength="30"
                autocomplete="off"
              />
              <br />
              <button type="submit" class="aim-send">Sign On</button>
            </form>
            <div style="color:#888; font-size:10px;">it'll stick around for next time</div>
          </div>
        <% end %>
      </div>

      <div
        :if={@chat_blink && @show_buddies}
        class="win95 buddies"
        id="buddies-window"
        phx-hook="Draggable"
      >
        <div class="win95-titlebar title-bar">
          <span>👥</span>
          <span class="t">Buddy List — {@chat_blink.title || domain(@chat_blink.url)}</span>
          <button class="win95-btn" phx-click="toggle-buddies" title="Close">✕</button>
        </div>
        <div class="buddy-panel">
          <b style="font-size:10px; color:#000080;">WHO'S HERE ({length(@buddies)})</b>
          <div :for={buddy <- @buddies}>
            <span class="buddy-dot"></span>
            <span
              style={"color: #{buddy.color}; cursor: pointer;"}
              phx-click="mention"
              phx-value-name={buddy.name}
              title="mention them"
            >
              {buddy.name}
            </span>
          </div>
          <div style="color:#888; font-size:9px; margin-top:6px;">
            click a name to @ them in the chat
          </div>
        </div>
      </div>
    </div>
    """
  end
end
