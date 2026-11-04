defmodule BlogWeb.RootedLive do
  use BlogWeb, :live_view

  @max_chat_messages 40
  @graph_key "rooted"

  @impl true
  def mount(_params, session, socket) do
    # The manuscript is a confidential draft, so nothing about it — not the
    # graph, not even the node counts — is assigned until the visitor unlocks
    # the page. Keeping graph_json nil is the point: an assign would otherwise
    # ship the whole book into the DOM for anyone who views source.
    {:ok,
     assign(socket,
       visitor_id: session["user_id"] || "",
       page_title: "The RootedInGood Method",
       view: :overview,
       unlocked: false,
       password_error: nil,
       stats: nil,
       graph_json: nil,
       chat_enabled: chat_configured?(),
       chat_open: false,
       chat_unlocked: false,
       chat_password_error: nil,
       history: [],
       conversation_id: nil,
       conversations: [],
       chat_view: :chat,
       memory_stats: %{exchanges: 0, topics: 0, nodes: 0, edges: 0},
       memory_topics: [],
       memory_exchanges: [],
       memory_topic_id: nil,
       draft: "",
       loading: false,
       chat_count: 0
     )}
  end

  defp unlock(socket) do
    # Chats are shared, so opening the page drops you into whichever
    # conversation was most recently active — anyone's — rather than a blank
    # one. A graph nobody has chatted on yet gets a fresh id.
    conversation_id =
      Blog.GraphChat.latest_conversation_id(@graph_key) ||
        Blog.GraphChat.new_conversation_id()

    assign(socket,
      unlocked: true,
      password_error: nil,
      chat_unlocked: true,
      conversation_id: conversation_id,
      history: Blog.GraphChat.history(@graph_key, conversation_id),
      stats: Blog.Rooted.stats(),
      graph_json: Blog.Rooted.graph_export() |> Jason.encode!()
    )
  end

  defp chat_password, do: Application.get_env(:blog, :rooted_chat_password)

  defp chat_configured? do
    case chat_password() do
      pw when is_binary(pw) and pw != "" -> true
      _ -> false
    end
  end

  defp to_view("overview"), do: :overview
  defp to_view("plot"), do: :plot
  defp to_view("notes"), do: :notes
  defp to_view("themes"), do: :themes
  defp to_view("memory"), do: :memory
  defp to_view("search"), do: :search
  defp to_view(_), do: :overview

  @impl true
  def handle_params(params, _uri, socket) do
    {:noreply,
     assign(socket,
       view: to_view(params["view"] || "overview"),
       chat_open: params["chat"] == "1"
     )}
  end

  # The URL is the source of truth for view/chat — every change patches it
  # (replacing, not pushing, so tab/chat clicks don't spam browser history)
  # so the current tab and chat state survive a reload and can be shared.
  #
  # part/mode/q/node live entirely client-side (inside the phx-update="ignore"
  # explorer) and are synced straight to the URL via history.replaceState,
  # bypassing the server. Since this server-side patch would otherwise rebuild
  # the query string from scratch and wipe them, the client stamps its current
  # values onto the triggering event (see rooted_app.js's nav click listener /
  # closeChatIfNarrow) so they can be preserved here.
  @keep_params ~w(part mode q node)

  defp rooted_path(socket, event_params \\ %{}) do
    kept =
      event_params
      |> Map.take(@keep_params)
      |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)
      |> Enum.into(%{})

    params = Map.put(kept, "view", Atom.to_string(socket.assigns.view))
    params = if socket.assigns.chat_open, do: Map.put(params, "chat", "1"), else: params
    "/rooted_in_good?" <> URI.encode_query(params)
  end

  @impl true
  def handle_event("set_view", %{"view" => v} = params, socket) do
    socket = if socket.assigns.unlocked, do: assign(socket, view: to_view(v)), else: socket
    # the memory graph changes as you chat, so reload it every time the tab
    # is opened rather than caching it at mount
    socket = if socket.assigns.view == :memory, do: load_memory(socket), else: socket
    {:noreply, push_patch(socket, to: rooted_path(socket, params), replace: true)}
  end

  def handle_event("toggle_chat", params, socket) do
    open = !socket.assigns.chat_open
    socket = assign(socket, chat_open: open)
    socket = if open, do: push_event(socket, "rooted-close-inspector", %{}), else: socket
    {:noreply, push_patch(socket, to: rooted_path(socket, params), replace: true)}
  end

  def handle_event("close_chat", params, socket) do
    socket = assign(socket, chat_open: false)
    {:noreply, push_patch(socket, to: rooted_path(socket, params), replace: true)}
  end

  def handle_event("unlock_page", %{"password" => pw}, socket) do
    cond do
      not chat_configured?() ->
        {:noreply,
         assign(socket, password_error: "This page is locked and no password is configured on this deploy.")}

      pw == chat_password() ->
        {:noreply, unlock(socket)}

      true ->
        {:noreply, assign(socket, password_error: "Wrong password.")}
    end
  end

  def handle_event("check_chat_password", %{"password" => pw}, socket) do
    cond do
      not chat_configured?() ->
        {:noreply, assign(socket, chat_password_error: "Chat is disabled on this deploy.")}

      pw == chat_password() ->
        {:noreply, assign(socket, chat_unlocked: true, chat_password_error: nil)}

      true ->
        {:noreply, assign(socket, chat_password_error: "Wrong password.")}
    end
  end

  def handle_event("send", %{"message" => text}, socket) do
    text = String.trim(text)
    a = socket.assigns

    cond do
      not (a.unlocked and a.chat_unlocked) ->
        {:noreply, socket}

      text == "" or a.loading ->
        {:noreply, socket}

      a.chat_count >= @max_chat_messages ->
        history =
          a.history ++
            [
              %{
                "role" => "assistant",
                "content" =>
                  "This session has hit its #{@max_chat_messages}-message limit (keeps a runaway conversation from burning API credits). Refresh the page to start a new one."
              }
            ]

        {:noreply, assign(socket, history: history)}

      true ->
        history = a.history ++ [%{"role" => "user", "content" => text}]
        Blog.GraphChat.append(@graph_key, a.visitor_id, a.conversation_id, "user", text)

        # Only the tail goes to the model: the whole window is resent every
        # turn, so an unbounded history would grow the bill with the chat.
        window = Blog.GraphChat.context_window(history)

        socket =
          socket
          |> assign(history: history, draft: "", loading: true, chat_count: a.chat_count + 1)
          |> start_async(:ask, fn -> Blog.Rooted.OpenAI.ask(window) end)

        {:noreply, socket}
    end
  end

  def handle_event("memory_topic", %{"id" => ""}, socket) do
    {:noreply, socket |> assign(memory_topic_id: nil) |> load_memory()}
  end

  def handle_event("memory_topic", %{"id" => id}, socket) do
    topic_id = String.to_integer(id)

    topic_id =
      if socket.assigns.memory_topic_id == topic_id, do: nil, else: topic_id

    {:noreply, socket |> assign(memory_topic_id: topic_id) |> load_memory()}
  end

  def handle_event("new_chat", _params, socket) do
    {:noreply,
     assign(socket,
       conversation_id: Blog.GraphChat.new_conversation_id(),
       history: [],
       chat_view: :chat
     )}
  end

  def handle_event("show_history", _params, socket) do
    {:noreply,
     assign(socket,
       chat_view: :history,
       conversations:
         Blog.GraphChat.list_conversations(@graph_key)
     )}
  end

  def handle_event("show_chat", _params, socket) do
    {:noreply, assign(socket, chat_view: :chat)}
  end

  def handle_event("open_conversation", %{"id" => id}, socket) do
    {:noreply,
     assign(socket,
       conversation_id: id,
       history: Blog.GraphChat.history(@graph_key, id),
       chat_view: :chat
     )}
  end

  def handle_event("delete_conversation", %{"id" => id}, socket) do
    a = socket.assigns
    Blog.GraphChat.delete_conversation(@graph_key, id)

    socket =
      assign(socket, conversations: Blog.GraphChat.list_conversations(@graph_key))

    # deleting the chat you are sitting in drops you into a fresh one
    socket =
      if id == a.conversation_id do
        assign(socket, conversation_id: Blog.GraphChat.new_conversation_id(), history: [])
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("clear_history", _params, socket) do
    a = socket.assigns
    Blog.GraphChat.delete_conversation(@graph_key, a.conversation_id)

    {:noreply,
     assign(socket,
       history: [],
       conversation_id: Blog.GraphChat.new_conversation_id(),
       conversations: Blog.GraphChat.list_conversations(@graph_key)
     )}
  end

  def handle_event("ask_preset", %{"q" => q}, socket) do
    handle_event("send", %{"message" => q}, socket)
  end

  def handle_event("suggest", %{"text" => text}, socket) do
    if socket.assigns.unlocked and socket.assigns.chat_unlocked and String.trim(text) != "" do
      {:noreply, start_async(socket, :suggest, fn -> {text, Blog.Rooted.OpenAI.suggest(text)} end)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_async(:ask, {:ok, {:ok, reply}}, socket) do
    a = socket.assigns
    history = a.history ++ [%{"role" => "assistant", "content" => reply}]
    remember(a, reply)
    Blog.GraphChat.append(@graph_key, a.visitor_id, a.conversation_id, "assistant", reply)
    {:noreply, assign(socket, history: history, loading: false)}
  end

  def handle_async(:ask, {:ok, {:error, reason}}, socket) do
    history =
      socket.assigns.history ++
        [%{"role" => "assistant", "content" => "Sorry — I hit an error: #{reason}"}]

    {:noreply, assign(socket, history: history, loading: false)}
  end

  def handle_async(:ask, {:exit, reason}, socket) do
    history =
      socket.assigns.history ++
        [%{"role" => "assistant", "content" => "Sorry — something crashed (#{inspect(reason)})."}]

    {:noreply, assign(socket, history: history, loading: false)}
  end

  def handle_async(:suggest, {:ok, {text, {:ok, suggestion}}}, socket) do
    if suggestion && String.trim(suggestion) != "" do
      {:noreply, push_event(socket, "rooted-suggestion", %{"for" => text, "suggestion" => suggestion})}
    else
      {:noreply, socket}
    end
  end

  def handle_async(:suggest, {:ok, {_text, {:error, _reason}}}, socket), do: {:noreply, socket}
  def handle_async(:suggest, {:exit, _reason}, socket), do: {:noreply, socket}

  defp load_memory(socket) do
    a = socket.assigns

    exchanges =
      if a.memory_topic_id do
        Blog.Memory.exchanges_for_topic(@graph_key, a.memory_topic_id)
        |> Enum.map(&%{question: nil, answer: &1.body, at: &1.at, topics: []})
      else
        Blog.Memory.recent_exchanges(@graph_key)
      end

    assign(socket,
      memory_stats: Blog.Memory.stats(@graph_key),
      memory_topics: Blog.Memory.topics(@graph_key),
      memory_exchanges: exchanges
    )
  end

  # The exchange goes into the living memory graph: the question/answer pair
  # deterministically, then a detached pass that names what it was about.
  defp remember(assigns, reply) do
    question =
      assigns.history
      |> Enum.reverse()
      |> Enum.find(&(&1["role"] == "user"))
      |> case do
        %{"content" => c} -> c
        _ -> nil
      end

    if is_binary(question) do
      case Blog.Memory.record_exchange(
             @graph_key,
             assigns.visitor_id,
             assigns.conversation_id,
             question,
             reply
           ) do
        {:ok, %{question: q, answer: a}} ->
          Blog.Memory.Distiller.distill_async(@graph_key, assigns.visitor_id, [q, a], question, reply)

        :error ->
          :ok
      end
    end

    :ok
  end

  @presets [
    "What is the method actually asking a parent to decide?",
    "How do the three touchpoints differ, and why that order?",
    "Where does the content strain against the book's own promises?",
    "What do the AI notes say the book gets wrong?"
  ]

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :presets, @presets)

    ~H"""
    <style>
      :root{
        --rg-bg:#ffffff; --rg-bg-elev:#c0c0c0; --rg-ink:#000000; --rg-ink-dim:#555555;
        --rg-line:#888888; --rg-accent:#7a4b2a; --rg-accent-ink:#fff;
        --rg-mono:"Courier New",Courier,monospace; --rg-face:Chicago,Geneva,"Helvetica Neue",Helvetica,Arial,sans-serif;
      }
      .rg-page{
        position:fixed; inset:0; color:var(--rg-ink); font-family:var(--rg-face); font-size:12px;
        display:flex; flex-direction:column; overflow:hidden;
        background:repeating-linear-gradient(0deg,#a8a8a8,#a8a8a8 1px,#b8b8b8 1px,#b8b8b8 2px);
      }
      .rg-header{display:flex; align-items:center; gap:.6rem; padding:5px 10px; border-bottom:1px solid #000; background:#fff; flex-wrap:wrap; flex:0 0 auto; row-gap:4px}
      .rg-header h1{font-size:13px; font-weight:bold; margin:0; white-space:nowrap}
      .rg-meta{font-size:10px; color:var(--rg-ink-dim); font-family:var(--rg-mono); white-space:nowrap}
      .rg-nav{display:flex; gap:4px; margin-left:auto; flex-wrap:wrap}
      .rg-nav button{
        font-family:var(--rg-face); font-size:11px; background:#c0c0c0; color:#000; cursor:pointer; border-radius:0;
        padding:3px 9px;
        border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
        box-shadow:inset 1px 1px 0 #dfdfdf;
      }
      .rg-nav button.on{
        background:var(--rg-accent); color:#fff; font-weight:bold;
        border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #3a2413;
      }
      .rg-nav button:not(.on):active{
        border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #808080;
      }
      .rg-main{flex:1; position:relative; overflow:hidden; display:flex; min-height:0; background:#dcdcdc}
      .rge-wrap{position:relative; flex:1; min-width:0; overflow:hidden}

      .rge-view{position:absolute; inset:0; display:none; overflow:auto; background:#dcdcdc}
      .rge-view.active{display:block}
      #rge-overview .wrap, #rge-themes .wrap, #rge-notes .wrap, #rge-search .wrap{max-width:780px; margin:0 auto; padding:1.5rem 1.25rem 4rem}
      .rge-stats{display:flex; flex-wrap:wrap; gap:.6rem; margin:1rem 0 1.4rem}
      .rge-stat{background:#fff; border:1px solid #000; box-shadow:2px 2px 0 #000; padding:.6rem .9rem; min-width:6.5rem}
      .rge-stat .n{font-size:1.3rem; font-weight:700; font-family:var(--rg-mono)}
      .rge-stat .l{font-size:.65rem; color:var(--rg-ink-dim); text-transform:uppercase; letter-spacing:.05em}
      .rge-badge{display:inline-block; font-size:.62rem; font-family:var(--rg-mono); text-transform:uppercase; padding:.15rem .5rem; border:1px solid #000; color:#fff; margin:0 .3rem .3rem 0}
      .rge-hover-tip{
        display:none; position:fixed; z-index:50; max-width:330px; background:#fff; border:1px solid #000;
        box-shadow:2px 2px 0 #000; padding:.5rem .6rem; font-size:.74rem; pointer-events:none; line-height:1.4;
      }
      .rge-hover-tip .tip-title{font-weight:bold; margin:.35rem 0 .2rem}
      .rge-hover-tip .tip-desc{color:var(--rg-ink-dim)}
      .rge-hover-tip .tip-themes{margin-top:.3rem}

      /* the book-level spine, as a horizontal strip of steps */
      .rge-spine{display:flex; gap:.4rem; overflow-x:auto; padding:.2rem 0 .6rem}
      .rge-spine .rge-step{flex:0 0 auto; background:#fff; border:1px solid #000; box-shadow:2px 2px 0 #000; padding:.45rem .6rem; max-width:13rem; cursor:pointer; font-size:.74rem; line-height:1.35}
      .rge-spine .rge-step:hover{background:#eaeaea}
      .rge-spine .rge-step .t{font-size:.58rem; text-transform:uppercase; letter-spacing:.05em; font-family:var(--rg-mono); font-weight:bold}

      .rge-part-row{display:flex; align-items:center; gap:.6rem; padding:.45rem 0; border-bottom:1px dashed var(--rg-line); cursor:pointer}
      .rge-part-row:hover{background:#eaeaea}
      .rge-part-row .bar{height:8px; background:var(--rg-accent)}
      .rge-part-row .label{font-family:var(--rg-mono); font-size:.72rem; width:9rem; flex:0 0 auto; color:var(--rg-ink-dim)}
      .rge-part-row .count{font-family:var(--rg-mono); font-size:.7rem; color:var(--rg-ink-dim); margin-left:auto}

      .rge-view.active#rge-plot{display:flex; flex-direction:column}
      .rge-toolbar{
        position:static; flex:0 0 auto; z-index:4; background:#fff; border-bottom:1px solid #000;
        padding:.4rem .6rem; font-size:.68rem;
        display:flex; flex-wrap:wrap; align-items:center; gap:.9rem; row-gap:.3rem;
      }
      .rge-toolbar > div{display:flex; align-items:center; gap:.4rem; flex-wrap:wrap}
      .rge-chips{display:flex; flex-wrap:wrap; gap:.3rem}
      .rge-chip{
        border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
        padding:.16rem .5rem; cursor:pointer; background:#c0c0c0; color:#000; font-family:var(--rg-mono); font-size:.64rem;
      }
      .rge-chip.on{
        background:var(--rg-accent); color:#fff;
        border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff;
      }
      .rge-zoom{margin-left:auto}
      .rge-svg-holder{position:relative; flex:1; min-height:0}
      .rge-svg-holder svg{width:100%; height:100%; display:block; cursor:grab}
      .rge-svg-holder.tree-scroll{overflow:auto; -webkit-overflow-scrolling:touch; cursor:grab}
      .rge-link{stroke-opacity:.55}
      .rge-node-label{font-family:var(--rg-face); font-size:12px; fill:var(--rg-ink); cursor:pointer}
      .rge-legend{position:static; flex:0 0 auto; z-index:4; background:#fff; border-bottom:1px solid #000; padding:.35rem .6rem; font-size:.62rem; color:var(--rg-ink-dim); display:flex; flex-wrap:wrap; align-items:center; gap:.15rem .7rem; max-width:none}
      .rge-legend .row{display:flex; align-items:center; gap:.4rem}
      .rge-legend .sw{width:9px; height:9px; flex:0 0 auto; border:1px solid #000}
      .rge-legend .sw.bar{width:15px; height:3px}

      #rge-inspector{position:absolute; top:0; right:0; bottom:0; width:340px; max-width:88vw; background:#fff; border-left:2px solid #000; box-shadow:-3px 0 0 #000; transform:translateX(105%); transition:transform .2s ease; z-index:6; overflow:auto; display:flex; flex-direction:column}
      #rge-inspector.open{transform:translateX(0)}
      .rg-mini-titlebar{height:20px; flex:0 0 auto; background:repeating-linear-gradient(90deg,#fff 0px,#fff 1px,#000 1px,#000 2px); display:flex; align-items:center; padding:0 6px; border-bottom:2px solid #000}
      .rg-mini-close{width:11px; height:11px; border:1px solid #000; background:#fff; flex-shrink:0; cursor:pointer; padding:0}
      .rg-mini-title{flex:1; text-align:center; font-size:11px; font-weight:bold; background:#fff; padding:0 6px; margin:0 34px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis}
      #rge-inspector-body{padding:.9rem 1rem 2rem; overflow:auto}
      #rge-inspector h3{margin:.5rem 0 .3rem; font-size:1rem; line-height:1.35}
      #rge-inspector .desc{font-size:.84rem; line-height:1.55; white-space:pre-wrap}
      #rge-inspector .src{color:var(--rg-ink-dim); font-size:.75rem; font-style:italic; margin-top:.6rem; padding-left:.6rem; border-left:2px solid var(--rg-line)}
      #rge-inspector .prompt{font-size:.75rem; line-height:1.5; color:var(--rg-ink-dim); white-space:pre-wrap; background:#f0f0f0; border:1px solid var(--rg-line); padding:.5rem .6rem; margin-top:.3rem}
      #rge-inspector .rel-title{font-size:.68rem; text-transform:uppercase; letter-spacing:.05em; color:var(--rg-ink-dim); margin:.9rem 0 .3rem}
      #rge-inspector .rel{display:block; font-size:.78rem; padding:.3rem 0; border-bottom:1px dashed var(--rg-line); cursor:pointer}
      #rge-inspector .rel:hover{color:var(--rg-accent)}
      #rge-inspector .rtype{font-family:var(--rg-mono); font-size:.63rem; color:var(--rg-ink-dim); margin-right:.35rem}

      .rge-theme-card{border:1px solid #000; background:#fff; box-shadow:2px 2px 0 #000; padding:.9rem 1rem; margin-bottom:1rem; border-left:6px solid var(--rg-accent); cursor:pointer}
      .rge-theme-card h3{margin:0 0 .3rem; font-size:.95rem}
      .rge-theme-card p{margin:0 0 .4rem; font-size:.82rem; line-height:1.5; color:var(--rg-ink-dim)}
      .rge-theme-card .count{font-family:var(--rg-mono); font-size:.68rem; color:var(--rg-ink-dim)}
      .rge-note-card{border:1px solid #000; background:#fff; box-shadow:2px 2px 0 #000; padding:.9rem 1rem; margin-bottom:1rem; border-left:6px solid #db2777; cursor:pointer}
      .rge-note-card h3{margin:0 0 .35rem; font-size:.92rem; line-height:1.35}
      .rge-note-card p{margin:0 0 .4rem; font-size:.82rem; line-height:1.55; color:var(--rg-ink-dim)}
      .rge-note-card .count{font-family:var(--rg-mono); font-size:.66rem; color:var(--rg-ink-dim)}

      .rge-search-input{
        width:100%; font-family:var(--rg-face); font-size:.9rem; padding:.5rem .7rem; background:#fff; color:var(--rg-ink); margin-bottom:1rem;
        border-top:1px solid #808080; border-left:1px solid #808080; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #404040; box-sizing:border-box;
      }
      .rge-result{border-bottom:1px dashed var(--rg-line); padding:.7rem 0; cursor:pointer}
      .rge-result:hover{background:#eaeaea}
      .rge-result h4{margin:0 0 .2rem; font-size:.9rem}
      .rge-result p{margin:0; font-size:.78rem; color:var(--rg-ink-dim); line-height:1.4}
      .rge-result .where{font-family:var(--rg-mono); font-size:.63rem; color:var(--rg-ink-dim); margin-top:.25rem}

      /* chat — a right-hand "window" that splits the screen vertically,
         sitting beside the graph rather than covering it. Collapses to a
         bottom sheet on narrow screens where a side-by-side split won't fit. */
      .rg-chat-panel{flex:0 0 auto; width:0; overflow:hidden; background:#fff; border-left:2px solid #000; display:flex; flex-direction:column; transition:width .22s ease}
      .rg-chat-panel.open{width:760px}
      .rg-chat-panel-inner{width:760px; flex:1; min-height:0; display:flex; flex-direction:column}
      .rg-chat-head{height:20px; flex:0 0 auto; background:repeating-linear-gradient(90deg,#fff 0px,#fff 1px,#000 1px,#000 2px); display:flex; align-items:center; padding:0 6px; border-bottom:2px solid #000}
      .rg-chat-bar{flex:0 0 auto; display:flex; flex-wrap:wrap; gap:.3rem; padding:.4rem .6rem;
        background:#c0c0c0; border-bottom:1px solid #000}
      .rg-chat-btn{font-family:var(--rg-face); font-size:.72rem; background:#c0c0c0; color:#000; cursor:pointer;
        padding:.25rem .6rem;
        border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040}
      .rg-chat-btn:active{border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff}
      .rg-chat-btn.primary{font-weight:bold}
      .rg-convo-hint{font-size:.7rem; color:var(--rg-ink-dim); margin:0 0 .6rem}
      .rg-convo{display:flex; align-items:stretch; gap:.3rem; margin-bottom:.4rem}
      .rg-convo-open{flex:1; text-align:left; font-family:var(--rg-face); background:#fff; color:#000; cursor:pointer;
        border:1px solid #000; box-shadow:2px 2px 0 #000; padding:.45rem .6rem; display:block}
      .rg-convo-open:hover{background:#eaeaea}
      .rg-convo.current .rg-convo-open{border-left:4px solid var(--rg-accent)}
      .rg-convo-open .t{display:block; font-size:.82rem; line-height:1.35}
      .rg-convo-open .m{display:block; font-size:.66rem; color:var(--rg-ink-dim); font-family:var(--rg-mono); margin-top:.2rem}
      .rg-convo-del{flex:0 0 auto; width:22px; font-family:var(--rg-face); font-size:12px; background:#c0c0c0; color:#000; cursor:pointer;
        border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040}
      .rg-convo-del:hover{color:#c00}
      .rg-clear{position:absolute; right:5px; font-family:var(--rg-face); font-size:9px; background:#c0c0c0; color:#000; cursor:pointer; padding:0 .35rem; line-height:14px; border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040}
      .rg-clear:active{border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff}
      .rg-chat-head strong{flex:1; text-align:center; font-size:11px; font-weight:bold; background:#fff; padding:0 6px; margin:0 34px; white-space:nowrap}
      .rg-chat-body{flex:1; min-height:0; width:100%; box-sizing:border-box; padding:.8rem .9rem 1rem; overflow-y:auto; background:#fff}
      .rg-empty{color:var(--rg-ink-dim); font-size:.86rem; padding:.5rem 0 1rem}
      .rg-presets{display:flex; flex-wrap:wrap; gap:.4rem; margin-top:.7rem}
      .rg-preset{font-family:var(--rg-face); font-size:.76rem; background:#c0c0c0; border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040; padding:.32rem .6rem; cursor:pointer; text-align:left}
      .rg-preset:hover{color:var(--rg-accent)}
      .rg-msg{margin:.7rem 0; max-width:92%; line-height:1.5; font-size:.88rem}
      .rg-msg.user{margin-left:auto; background:var(--rg-accent); color:#fff; padding:.5rem .8rem; border:1px solid #000; white-space:pre-wrap}
      .rg-msg.assistant{background:#f0f0f0; border:1px solid #000; padding:.5rem .8rem}
      .rg-msg.assistant p{margin:0 0 .55em}
      .rg-msg.assistant p:last-child{margin-bottom:0}
      .rg-msg.assistant ul, .rg-msg.assistant ol{margin:.2em 0 .55em 1.15em; padding:0}
      .rg-msg.assistant li{margin:.15em 0}
      .rg-msg.assistant code{background:#dcdcdc; padding:.08em .3em; font-size:.85em}
      .rg-msg.assistant pre{background:#dcdcdc; padding:.5em .7em; overflow-x:auto}
      .rg-msg.assistant pre code{background:none; padding:0}
      .rg-msg.assistant a{color:var(--rg-accent)}
      .rg-msg.assistant strong{font-weight:700}
      .rg-copy-btn{
        display:block; margin-top:.5rem; font-family:var(--rg-face); font-size:.65rem; background:#c0c0c0; color:#000; cursor:pointer;
        padding:.15rem .5rem; border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
      }
      .rg-copy-btn:active{border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff}
      .rg-thinking{color:var(--rg-ink-dim); font-size:.82rem; font-style:italic}
      .rg-form{flex:0 0 auto; background:#c0c0c0; border-top:2px solid #000; padding:.55rem .8rem calc(.55rem + env(safe-area-inset-bottom))}
      .rg-form-inner{display:flex; gap:.5rem; align-items:flex-end}
      .rg-input-wrap{position:relative; flex:1}
      .rg-ghost{position:absolute; inset:0; margin:0; padding:.5rem .6rem; font-family:var(--rg-face); font-size:.85rem; line-height:1.4; white-space:pre-wrap; word-wrap:break-word; pointer-events:none; overflow:hidden; border:1px solid transparent; box-sizing:border-box; background:#fff}
      .rg-ghost .typed{color:transparent}
      .rg-ghost .suggestion{color:#888}
      .rg-input{
        position:relative; z-index:1; width:100%; display:block; font-family:var(--rg-face); font-size:.85rem; line-height:1.4;
        padding:.5rem .6rem; background:transparent; color:var(--rg-ink); resize:none; overflow:hidden; box-sizing:border-box;
        min-height:5.5rem; max-height:16rem;
        border-top:1px solid #808080; border-left:1px solid #808080; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #404040;
      }
      .rg-input-hint{font-size:.62rem; color:var(--rg-ink-dim); margin-top:.3rem}
      .rg-send{
        font-family:var(--rg-face); font-size:.8rem; font-weight:bold; background:#c0c0c0; color:#000; cursor:pointer; flex:0 0 auto;
        padding:.5rem 1rem; border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
      }
      .rg-send:active{border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff}
      .rg-send:disabled{opacity:.5; cursor:default}
      .rg-memory{position:absolute; inset:0; display:none; overflow:auto; background:#dcdcdc; z-index:3}
      .rg-memory.active{display:block}
      .rg-memory .wrap{max-width:780px; margin:0 auto; padding:1.5rem 1.25rem 4rem}
      .rg-memory-lede{color:var(--rg-ink-dim); font-size:.86rem; line-height:1.55; max-width:56ch; margin:.3rem 0 0}
      .rg-memory-h{font-size:.78rem; text-transform:uppercase; letter-spacing:.05em; color:var(--rg-ink-dim);
        margin:1.6rem 0 .6rem; display:flex; align-items:center; gap:.6rem}
      .rg-memory-note{font-size:.8rem; color:var(--rg-ink-dim)}
      .rg-topics{display:flex; flex-wrap:wrap; gap:.35rem}
      .rg-topic{font-family:var(--rg-face); font-size:.76rem; background:#fff; color:#000; cursor:pointer;
        border:1px solid #000; box-shadow:2px 2px 0 #000; padding:.25rem .55rem}
      .rg-topic:hover{background:#eaeaea}
      .rg-topic.on{background:var(--rg-accent); color:#fff}
      .rg-topic .c{font-family:var(--rg-mono); font-size:.66rem; opacity:.7; margin-left:.25rem}
      .rg-xchg{background:#fff; border:1px solid #000; box-shadow:2px 2px 0 #000; padding:.7rem .85rem; margin-bottom:.7rem}
      .rg-xchg .q{font-size:.84rem; font-weight:bold; line-height:1.4; margin-bottom:.35rem}
      .rg-xchg .a{font-size:.82rem; line-height:1.55; color:var(--rg-ink); white-space:pre-wrap;
        max-height:11rem; overflow:auto}
      .rg-xchg .m{font-family:var(--rg-mono); font-size:.64rem; color:var(--rg-ink-dim); margin-top:.45rem}
      .rg-gate{flex:1; display:flex; align-items:center; justify-content:center; padding:1.5rem}
      .rg-gate-box{background:#fff; border:1px solid #000; box-shadow:3px 3px 0 #000; padding:1.6rem 1.8rem; max-width:420px; text-align:center}
      .rg-gate-box h1{font-size:15px; margin:0 0 .3rem}
      .rg-gate-box .rg-gate-sub{font-size:.72rem; color:var(--rg-ink-dim); margin:0 0 1.1rem; font-style:italic}
      .rg-gate-box p{font-size:.84rem; line-height:1.5; margin:0 0 .9rem}
      .rg-gate-box form{display:flex; gap:.5rem}
      .rg-gate-box input{
        flex:1; font-family:var(--rg-face); padding:.5rem .6rem; background:#fff; color:var(--rg-ink);
        border-top:1px solid #808080; border-left:1px solid #808080; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #404040;
      }
      .rg-gate-box .err{color:#c00; font-size:.8rem; margin-top:.7rem}
      .rg-lock{max-width:300px; margin:1.5rem auto; padding:1.2rem; text-align:center}
      .rg-lock form{display:flex; gap:.5rem; margin-top:.8rem}
      .rg-lock input{
        flex:1; font-family:var(--rg-face); padding:.5rem .6rem; background:#fff; color:var(--rg-ink);
        border-top:1px solid #808080; border-left:1px solid #808080; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #404040;
      }
      .rg-lock .err{color:#c00; font-size:.8rem; margin-top:.5rem}

      @media (max-width:1300px){
        .rg-chat-panel{position:fixed; left:0; right:0; bottom:0; top:auto; width:auto!important; max-height:0; border-left:none; border-top:2px solid #000; box-shadow:0 -3px 0 #000; z-index:21; transition:max-height .22s ease}
        .rg-chat-panel.open{max-height:78vh}
        .rg-chat-panel-inner{width:auto; height:100%}
        #rge-inspector{width:300px}
      }

      @media (max-width:640px){
        #rge-inspector{width:100%; max-width:100%; top:auto; height:70vh; transform:translateY(105%); border-left:none; border-top:2px solid #000}
        #rge-inspector.open{transform:translateY(0)}
        .rg-header h1{font-size:12px}
        .rg-nav button{padding:3px 6px; font-size:10px}
        .rge-legend{display:none}
      }
    </style>

    <div class="rg-page">
      <%= if not @unlocked do %>
        <div class="rg-gate">
          <div class="rg-gate-box">
            <h1>The RootedInGood™ Method</h1>
            <p class="rg-gate-sub">Confidential draft — unpublished manuscript, shared for review only.</p>
            <%= if @chat_enabled do %>
              <p>This explorer is password protected.</p>
              <form phx-submit="unlock_page">
                <input type="password" name="password" placeholder="Password" autocomplete="current-password" autofocus />
                <button type="submit" class="rg-send">Unlock</button>
              </form>
            <% else %>
              <p>This page is locked and no password is configured on this deploy.</p>
            <% end %>
            <%= if @password_error do %>
              <div class="err">{@password_error}</div>
            <% end %>
          </div>
        </div>
      <% else %>
      <div class="rg-header">
        <h1>The RootedInGood™ Method</h1>
        <span class="rg-meta">
          {@stats.nodes} nodes · {@stats.edges} edges · {@stats.themes} themes · {@stats.notes} ai notes
        </span>
        <nav class="rg-nav">
          <button class={nav_class(@view, :overview)} phx-click="set_view" phx-value-view="overview">Overview</button>
          <button class={nav_class(@view, :plot)} phx-click="set_view" phx-value-view="plot">Plot</button>
          <button class={nav_class(@view, :notes)} phx-click="set_view" phx-value-view="notes">AI Notes</button>
          <button class={nav_class(@view, :themes)} phx-click="set_view" phx-value-view="themes">Themes</button>
          <button class={nav_class(@view, :search)} phx-click="set_view" phx-value-view="search">Search</button>
          <button class={nav_class(@view, :memory)} phx-click="set_view" phx-value-view="memory">Memory</button>
          <button class={if @chat_open, do: "on", else: ""} phx-click="toggle_chat">💬 Chat</button>
        </nav>
      </div>

      <div class="rg-main">
        <div class="rge-wrap">
          <div class={"rg-memory" <> if(@view == :memory, do: " active", else: "")}>
            <div class="wrap">
              <h2>Living memory</h2>
              <p class="rg-memory-lede">
                A decision graph of what you and the assistant have actually worked through here —
                written as you chat, not exported ahead of time. Every exchange becomes a question
                and an answer node; a background pass names what each was about. The assistant can
                query this while answering, which is how it remembers across sessions.
              </p>
              <div class="rge-stats">
                <div class="rge-stat"><div class="n">{@memory_stats.exchanges}</div><div class="l">exchanges</div></div>
                <div class="rge-stat"><div class="n">{@memory_stats.topics}</div><div class="l">topics</div></div>
                <div class="rge-stat"><div class="n">{@memory_stats.nodes}</div><div class="l">nodes</div></div>
                <div class="rge-stat"><div class="n">{@memory_stats.edges}</div><div class="l">edges</div></div>
              </div>

              <%= if @memory_stats.nodes == 0 do %>
                <div class="rg-empty">
                  Nothing remembered yet. Ask the assistant something and it starts building.
                </div>
              <% else %>
                <h3 class="rg-memory-h">What keeps coming up</h3>
                <%= if @memory_topics == [] do %>
                  <div class="rg-memory-note">No topics distilled yet — they appear a moment after each answer.</div>
                <% else %>
                  <div class="rg-topics">
                    <%= for t <- @memory_topics do %>
                      <button
                        class={"#rg-topic" <> if(@memory_topic_id == t.id, do: " on", else: "")}
                        phx-click="memory_topic"
                        phx-value-id={t.id}
                      >{t.title} <span class="c">{t.mentions}</span></button>
                    <% end %>
                  </div>
                <% end %>

                <h3 class="rg-memory-h">
                  <%= if @memory_topic_id, do: "Exchanges on that topic", else: "Recent exchanges" %>
                  <%= if @memory_topic_id do %>
                    <button class="rg-chat-btn" phx-click="memory_topic" phx-value-id="">Show all</button>
                  <% end %>
                </h3>
                <%= for x <- @memory_exchanges do %>
                  <div class="rg-xchg">
                    <div class="q">{x.question}</div>
                    <div class="a">{x.answer}</div>
                    <div class="m">
                      {format_when(x.at)}<%= if x[:topics] && x.topics != [] do %> · {Enum.join(x.topics, " · ")}<% end %>
                    </div>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
          <div
            id="rooted-explorer"
            phx-update="ignore"
            phx-hook="RootedApp"
            data-graph={@graph_json}
            data-active-view={@view}
          >
            <div class="rge-view" id="rge-overview"><div class="wrap" id="rge-overview-content"></div></div>

            <div class="rge-view" id="rge-plot">
              <div class="rge-toolbar" id="rge-plot-toolbar">
                <div><strong>View</strong><span class="rge-chips" id="rge-plot-mode"></span></div>
                <div><strong>Part</strong><span class="rge-chips" id="rge-plot-chips"></span></div>
                <div class="rge-zoom">
                  <span class="rge-chip" id="rge-zoom-out">−</span>
                  <span class="rge-chip" id="rge-zoom-in">+</span>
                  <span class="rge-chip" id="rge-zoom-reset">reset</span>
                </div>
              </div>
              <div class="rge-legend" id="rge-plot-legend"></div>
              <div class="rge-svg-holder"><svg id="rge-plot-svg"></svg></div>
            </div>

            <div class="rge-view" id="rge-notes"><div class="wrap" id="rge-notes-content"></div></div>
            <div class="rge-view" id="rge-themes"><div class="wrap" id="rge-themes-content"></div></div>

            <div class="rge-view" id="rge-search">
              <div class="wrap">
                <input type="text" id="rge-search-input" class="rge-search-input" placeholder="Search the manuscript…" autocomplete="off" />
                <div id="rge-search-results"></div>
              </div>
            </div>

            <aside id="rge-inspector">
              <div class="rg-mini-titlebar">
                <button class="rg-mini-close" id="rge-inspector-close"></button>
                <span class="rg-mini-title">Details</span>
              </div>
              <div id="rge-inspector-body"></div>
            </aside>
          </div>
        </div>

        <div class={"rg-chat-panel #{if @chat_open, do: "open"}"}>
          <div class="rg-chat-panel-inner">
            <div class="rg-chat-head">
              <strong>Ask the Method</strong>
            </div>
            <%= cond do %>
              <% not @chat_enabled -> %>
                <div class="rg-lock">
                  <p>Chat isn't configured on this deploy (no password set).</p>
                </div>
              <% not @chat_unlocked -> %>
                <div class="rg-lock">
                  <p>This chat spends real API credits per message, so it's password-gated.</p>
                  <form phx-submit="check_chat_password">
                    <input type="password" name="password" placeholder="Password" autocomplete="current-password" />
                    <button type="submit" class="rg-send">Unlock</button>
                  </form>
                  <%= if @chat_password_error do %>
                    <div class="err">{@chat_password_error}</div>
                  <% end %>
                </div>
              <% @chat_view == :history -> %>
                <div class="rg-chat-bar">
                  <button class="rg-chat-btn" phx-click="show_chat">&larr; Back to chat</button>
                  <button class="rg-chat-btn primary" phx-click="new_chat">+ New chat</button>
                </div>
                <div class="rg-chat-body">
                  <%= if @conversations == [] do %>
                    <div class="rg-empty">No earlier chats on this graph yet.</div>
                  <% else %>
                    <div class="rg-convo-hint">{length(@conversations)} earlier chat(s). Open one to keep going where you left off.</div>
                    <%= for c <- @conversations do %>
                      <div class={"rg-convo" <> if(c.id == @conversation_id, do: " current", else: "")}>
                        <button class="rg-convo-open" phx-click="open_conversation" phx-value-id={c.id}>
                          <span class="t">{c.title}</span>
                          <span class="m">{c.count} message(s) · {format_when(c.last_at)}{if c.id == @conversation_id, do: " · current"}</span>
                        </button>
                        <button class="rg-convo-del" phx-click="delete_conversation" phx-value-id={c.id} title="Delete this chat">×</button>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              <% true -> %>
                <div class="rg-chat-bar">
                  <button class="rg-chat-btn primary" phx-click="new_chat">+ New chat</button>
                  <button class="rg-chat-btn" phx-click="show_history">Past chats</button>
                  <%= if @history != [] do %>
                    <button class="rg-chat-btn" phx-click="clear_history">Delete this chat</button>
                  <% end %>
                </div>
                <div class="rg-chat-body">
                  <%= if @history == [] do %>
                    <div class="rg-empty">
                      Ask about a lesson, a tool, a family story, a theme, or where the course contradicts itself — grounded in the decision graph, not guesses. Browse the map beside this panel while you chat. This conversation is remembered between visits.
                      <div class="rg-presets">
                        <%= for q <- @presets do %>
                          <button class="rg-preset" phx-click="ask_preset" phx-value-q={q}>{q}</button>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                  <%= for {msg, idx} <- Enum.with_index(@history) do %>
                    <div class={"rg-msg #{msg["role"]}"}>
                      <%= if msg["role"] == "assistant" do %>
                        {render_markdown(msg["content"])}
                        <button class="rg-copy-btn" phx-hook="ZiggyCopy" id={"rg-copy-#{idx}"} data-text={msg["content"]}>Copy</button>
                      <% else %>
                        {msg["content"]}
                      <% end %>
                    </div>
                  <% end %>
                  <%= if @loading do %>
                    <div class="rg-thinking">reading the graph…</div>
                  <% end %>
                </div>
                <div class="rg-form">
                  <form phx-submit="send" class="rg-form-inner">
                    <div class="rg-input-wrap">
                      <div class="rg-ghost" id="rg-ghost"><span class="typed"></span><span class="suggestion"></span></div>
                      <textarea
                        name="message"
                        id="rg-chat-input"
                        class="rg-input"
                        rows="1"
                        placeholder="Ask something — write a full thought, not a fragment."
                        phx-hook="ZiggyChatInput"
                        disabled={@loading}
                      >{@draft}</textarea>
                    </div>
                    <button type="submit" class="rg-send" disabled={@loading}>Ask</button>
                  </form>
                  <div class="rg-input-hint">Tab accepts a suggestion · Shift+Enter for a new line</div>
                </div>
            <% end %>
          </div>
        </div>
      </div>
      <% end %>
    </div>
    """
  end

  # Conversations are listed newest-first, so a relative stamp reads better
  # than a date for the ones people actually reach for.
  defp format_when(nil), do: "unknown"

  defp format_when(%NaiveDateTime{} = at) do
    diff = NaiveDateTime.diff(NaiveDateTime.utc_now(), at, :second)

    cond do
      diff < 60 -> "just now"
      diff < 3600 -> "#{div(diff, 60)}m ago"
      diff < 86_400 -> "#{div(diff, 3600)}h ago"
      diff < 604_800 -> "#{div(diff, 86_400)}d ago"
      true -> Calendar.strftime(at, "%b %-d")
    end
  end

  defp nav_class(current, this), do: if(current == this, do: "on", else: "")

  defp render_markdown(nil), do: ""

  defp render_markdown(text) do
    case Blog.Markdown.as_html(text) do
      {:ok, html, _} -> Phoenix.HTML.raw(html)
      _ -> Phoenix.HTML.raw(text |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string())
    end
  end
end
