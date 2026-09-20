defmodule BlogWeb.ZiggyLive do
  use BlogWeb, :live_view

  @max_chat_messages 40

  @impl true
  def mount(_params, _session, socket) do
    stats = Blog.Ziggy.stats()
    graph_json = Blog.Ziggy.graph_export() |> Jason.encode!()

    {:ok,
     assign(socket,
       page_title: "The Ziggy Account",
       view: :overview,
       stats: stats,
       graph_json: graph_json,
       chat_enabled: chat_configured?(),
       chat_open: false,
       chat_unlocked: false,
       chat_password_error: nil,
       history: [],
       draft: "",
       loading: false,
       chat_count: 0
     )}
  end

  defp chat_configured? do
    case Application.get_env(:blog, :ziggy_chat_password) do
      pw when is_binary(pw) and pw != "" -> true
      _ -> false
    end
  end

  defp to_view("overview"), do: :overview
  defp to_view("plot"), do: :plot
  defp to_view("characters"), do: :characters
  defp to_view("themes"), do: :themes
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
  # chapter/mode/q/node/char live entirely client-side (inside the
  # phx-update="ignore" explorer) and are synced straight to the URL via
  # history.replaceState, bypassing the server. Since this server-side patch
  # would otherwise rebuild the query string from scratch and wipe them, the
  # client stamps its current values onto the triggering event (see
  # ziggy_app.js's nav click listener / closeChatIfNarrow) so they can be
  # preserved here.
  @keep_params ~w(chapter mode q node char)

  defp ziggy_path(socket, event_params \\ %{}) do
    kept =
      event_params
      |> Map.take(@keep_params)
      |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)
      |> Enum.into(%{})

    params = Map.put(kept, "view", Atom.to_string(socket.assigns.view))
    params = if socket.assigns.chat_open, do: Map.put(params, "chat", "1"), else: params
    "/ziggy?" <> URI.encode_query(params)
  end

  @impl true
  def handle_event("set_view", %{"view" => v} = params, socket) do
    socket = assign(socket, view: to_view(v))
    {:noreply, push_patch(socket, to: ziggy_path(socket, params), replace: true)}
  end

  def handle_event("toggle_chat", params, socket) do
    open = !socket.assigns.chat_open
    socket = assign(socket, chat_open: open)
    socket = if open, do: push_event(socket, "ziggy-close-inspector", %{}), else: socket
    {:noreply, push_patch(socket, to: ziggy_path(socket, params), replace: true)}
  end

  def handle_event("close_chat", params, socket) do
    socket = assign(socket, chat_open: false)
    {:noreply, push_patch(socket, to: ziggy_path(socket, params), replace: true)}
  end

  def handle_event("check_chat_password", %{"password" => pw}, socket) do
    expected = Application.get_env(:blog, :ziggy_chat_password)

    cond do
      not chat_configured?() ->
        {:noreply, assign(socket, chat_password_error: "Chat is disabled on this deploy.")}

      pw == expected ->
        {:noreply, assign(socket, chat_unlocked: true, chat_password_error: nil)}

      true ->
        {:noreply, assign(socket, chat_password_error: "Wrong password.")}
    end
  end

  def handle_event("send", %{"message" => text}, socket) do
    text = String.trim(text)
    a = socket.assigns

    cond do
      not a.chat_unlocked ->
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

        socket =
          socket
          |> assign(history: history, draft: "", loading: true, chat_count: a.chat_count + 1)
          |> start_async(:ask, fn -> Blog.Ziggy.OpenAI.ask(history) end)

        {:noreply, socket}
    end
  end

  def handle_event("ask_preset", %{"q" => q}, socket) do
    handle_event("send", %{"message" => q}, socket)
  end

  def handle_event("suggest", %{"text" => text}, socket) do
    if socket.assigns.chat_unlocked and String.trim(text) != "" do
      {:noreply, start_async(socket, :suggest, fn -> {text, Blog.Ziggy.OpenAI.suggest(text)} end)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_async(:ask, {:ok, {:ok, reply}}, socket) do
    history = socket.assigns.history ++ [%{"role" => "assistant", "content" => reply}]
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
      {:noreply, push_event(socket, "ziggy-suggestion", %{"for" => text, "suggestion" => suggestion})}
    else
      {:noreply, socket}
    end
  end

  def handle_async(:suggest, {:ok, {_text, {:error, _reason}}}, socket), do: {:noreply, socket}
  def handle_async(:suggest, {:exit, _reason}, socket), do: {:noreply, socket}

  @presets [
    "What's the deal with the Willis/Wallace mixup?",
    "Why does Beth end up vetting Willis for Garrett?",
    "What's the golden-handcuffs theme about?",
    "Where does the draft actually end?"
  ]

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :presets, @presets)

    ~H"""
    <style>
      :root{
        --zg-bg:#ffffff; --zg-bg-elev:#c0c0c0; --zg-ink:#000000; --zg-ink-dim:#555555;
        --zg-line:#888888; --zg-accent:#000080; --zg-accent-ink:#fff;
        --zg-mono:"Courier New",Courier,monospace; --zg-face:Chicago,Geneva,"Helvetica Neue",Helvetica,Arial,sans-serif;
      }
      .zg-page{
        position:fixed; inset:0; color:var(--zg-ink); font-family:var(--zg-face); font-size:12px;
        display:flex; flex-direction:column; overflow:hidden;
        background:repeating-linear-gradient(0deg,#a8a8a8,#a8a8a8 1px,#b8b8b8 1px,#b8b8b8 2px);
      }
      .zg-header{display:flex; align-items:center; gap:.6rem; padding:5px 10px; border-bottom:1px solid #000; background:#fff; flex-wrap:wrap; flex:0 0 auto; row-gap:4px}
      .zg-header h1{font-size:13px; font-weight:bold; margin:0; white-space:nowrap}
      .zg-meta{font-size:10px; color:var(--zg-ink-dim); font-family:var(--zg-mono); white-space:nowrap}
      .zg-nav{display:flex; gap:4px; margin-left:auto; flex-wrap:wrap}
      .zg-nav button{
        font-family:var(--zg-face); font-size:11px; background:#c0c0c0; color:#000; cursor:pointer; border-radius:0;
        padding:3px 9px;
        border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
        box-shadow:inset 1px 1px 0 #dfdfdf;
      }
      .zg-nav button.on{
        background:var(--zg-accent); color:#fff; font-weight:bold;
        border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #000050;
      }
      .zg-nav button:not(.on):active{
        border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #808080;
      }
      .zg-main{flex:1; position:relative; overflow:hidden; display:flex; min-height:0; background:#dcdcdc}
      .zge-wrap{position:relative; flex:1; min-width:0; overflow:hidden}

      /* explorer (ported from the static graph browser) */
      .zge-view{position:absolute; inset:0; display:none; overflow:auto; background:#dcdcdc}
      .zge-view.active{display:block}
      #zge-overview .wrap, #zge-themes .wrap, #zge-search .wrap{max-width:760px; margin:0 auto; padding:1.5rem 1.25rem 4rem}
      .zge-stats{display:flex; flex-wrap:wrap; gap:.6rem; margin:1rem 0 1.4rem}
      .zge-stat{background:#fff; border:1px solid #000; box-shadow:2px 2px 0 #000; padding:.6rem .9rem; min-width:6.5rem}
      .zge-stat .n{font-size:1.3rem; font-weight:700; font-family:var(--zg-mono)}
      .zge-stat .l{font-size:.65rem; color:var(--zg-ink-dim); text-transform:uppercase; letter-spacing:.05em}
      .zge-badge{display:inline-block; font-size:.62rem; font-family:var(--zg-mono); text-transform:uppercase; padding:.15rem .5rem; border:1px solid #000; color:#fff; margin:0 .3rem .3rem 0}
      .zge-hover-tip{
        display:none; position:fixed; z-index:50; max-width:320px; background:#fff; border:1px solid #000;
        box-shadow:2px 2px 0 #000; padding:.5rem .6rem; font-size:.74rem; pointer-events:none; line-height:1.4;
      }
      .zge-hover-tip .tip-title{font-weight:bold; margin:.35rem 0 .2rem}
      .zge-hover-tip .tip-desc{color:var(--zg-ink-dim)}
      .zge-hover-tip .tip-themes{margin-top:.3rem}
      .zge-chapter-row{display:flex; align-items:center; gap:.6rem; padding:.45rem 0; border-bottom:1px dashed var(--zg-line); cursor:pointer}
      .zge-chapter-row:hover{background:#eaeaea}
      .zge-chapter-row .bar{height:8px; background:var(--zg-accent)}
      .zge-chapter-row .label{font-family:var(--zg-mono); font-size:.75rem; width:5.5rem; flex:0 0 auto; color:var(--zg-ink-dim)}
      .zge-chapter-row .count{font-family:var(--zg-mono); font-size:.7rem; color:var(--zg-ink-dim); width:2rem; text-align:right}
      .zge-view.active#zge-plot, .zge-view.active#zge-characters{display:flex; flex-direction:column}
      .zge-toolbar{
        position:static; flex:0 0 auto; z-index:4; background:#fff; border-bottom:1px solid #000;
        padding:.4rem .6rem; font-size:.68rem;
        display:flex; flex-wrap:wrap; align-items:center; gap:.9rem; row-gap:.3rem;
      }
      .zge-toolbar > div{display:flex; align-items:center; gap:.4rem}
      .zge-chips{display:flex; flex-wrap:wrap; gap:.3rem; margin-top:.3rem}
      .zge-chip{
        border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
        padding:.16rem .5rem; cursor:pointer; background:#c0c0c0; color:#000; font-family:var(--zg-mono); font-size:.64rem;
      }
      .zge-chip.on{
        background:var(--zg-accent); color:#fff;
        border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff;
      }
      .zge-svg-holder{position:relative; flex:1; min-height:0}
      .zge-svg-holder svg{width:100%; height:100%; display:block; cursor:grab}
      .zge-svg-holder.tree-scroll{overflow:auto; -webkit-overflow-scrolling:touch; cursor:grab}
      .zge-link{stroke-opacity:.55}
      .zge-node-label{font-family:var(--zg-face); font-size:12px; fill:var(--zg-ink); cursor:pointer}
      .zge-legend{position:static; flex:0 0 auto; z-index:4; background:#fff; border-bottom:1px solid #000; padding:.35rem .6rem; font-size:.62rem; color:var(--zg-ink-dim); display:flex; flex-wrap:wrap; align-items:center; gap:.15rem .7rem; max-width:none}
      .zge-legend .row{display:flex; align-items:center; gap:.4rem}
      .zge-legend .sw{width:9px; height:9px; flex:0 0 auto; border:1px solid #000}
      #zge-inspector{position:absolute; top:0; right:0; bottom:0; width:340px; max-width:88vw; background:#fff; border-left:2px solid #000; box-shadow:-3px 0 0 #000; transform:translateX(105%); transition:transform .2s ease; z-index:6; overflow:auto; display:flex; flex-direction:column}
      #zge-inspector.open{transform:translateX(0)}
      .zg-mini-titlebar{height:20px; flex:0 0 auto; background:repeating-linear-gradient(90deg,#fff 0px,#fff 1px,#000 1px,#000 2px); display:flex; align-items:center; padding:0 6px; border-bottom:2px solid #000}
      .zg-mini-close{width:11px; height:11px; border:1px solid #000; background:#fff; flex-shrink:0; cursor:pointer; padding:0}
      .zg-mini-title{flex:1; text-align:center; font-size:11px; font-weight:bold; background:#fff; padding:0 6px; margin:0 34px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis}
      #zge-inspector-body{padding:.9rem 1rem 2rem; overflow:auto}
      #zge-inspector .desc{font-size:.84rem; line-height:1.5; white-space:pre-wrap}
      #zge-inspector .src{color:var(--zg-ink-dim); font-size:.76rem; font-style:italic}
      #zge-inspector .rel-title{font-size:.68rem; text-transform:uppercase; letter-spacing:.05em; color:var(--zg-ink-dim); margin:.9rem 0 .3rem}
      #zge-inspector .rel{display:block; font-size:.78rem; padding:.3rem 0; border-bottom:1px dashed var(--zg-line); cursor:pointer}
      #zge-inspector .rel:hover{color:var(--zg-accent)}
      #zge-inspector .rtype{font-family:var(--zg-mono); font-size:.63rem; color:var(--zg-ink-dim); margin-right:.35rem}
      .zge-theme-card{border:1px solid #000; background:#fff; box-shadow:2px 2px 0 #000; padding:.9rem 1rem; margin-bottom:1rem; border-left:6px solid var(--zg-accent); cursor:pointer}
      .zge-theme-card h3{margin:0 0 .3rem; font-size:.95rem}
      .zge-theme-card p{margin:0 0 .4rem; font-size:.82rem; line-height:1.5; color:var(--zg-ink-dim)}
      .zge-theme-card .count{font-family:var(--zg-mono); font-size:.68rem; color:var(--zg-ink-dim)}
      .zge-search-input{
        width:100%; font-family:var(--zg-face); font-size:.9rem; padding:.5rem .7rem; background:#fff; color:var(--zg-ink); margin-bottom:1rem;
        border-top:1px solid #808080; border-left:1px solid #808080; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #404040; box-sizing:border-box;
      }
      .zge-result{border-bottom:1px dashed var(--zg-line); padding:.7rem 0; cursor:pointer}
      .zge-result:hover{background:#eaeaea}
      .zge-result h4{margin:0 0 .2rem; font-size:.9rem}
      .zge-result p{margin:0; font-size:.78rem; color:var(--zg-ink-dim); line-height:1.4}

      /* chat — a right-hand "window" that splits the screen vertically,
         sitting beside the graph rather than covering it. Collapses to a
         bottom sheet on narrow screens where a side-by-side split won't fit. */
      .zg-chat-panel{flex:0 0 auto; width:0; overflow:hidden; background:#fff; border-left:2px solid #000; display:flex; flex-direction:column; transition:width .22s ease}
      .zg-chat-panel.open{width:760px}
      .zg-chat-panel-inner{width:760px; flex:1; min-height:0; display:flex; flex-direction:column}
      .zg-chat-head{height:20px; flex:0 0 auto; background:repeating-linear-gradient(90deg,#fff 0px,#fff 1px,#000 1px,#000 2px); display:flex; align-items:center; padding:0 6px; border-bottom:2px solid #000}
      .zg-chat-head strong{flex:1; text-align:center; font-size:11px; font-weight:bold; background:#fff; padding:0 6px; margin:0 34px; white-space:nowrap}
      .zg-chat-body{flex:1; min-height:0; width:100%; padding:.8rem .9rem 1rem; overflow-y:auto; background:#fff}
      .zg-empty{color:var(--zg-ink-dim); font-size:.86rem; padding:.5rem 0 1rem}
      .zg-presets{display:flex; flex-wrap:wrap; gap:.4rem; margin-top:.7rem}
      .zg-preset{font-family:var(--zg-face); font-size:.76rem; background:#c0c0c0; border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040; padding:.32rem .6rem; cursor:pointer; text-align:left}
      .zg-preset:hover{color:var(--zg-accent)}
      .zg-msg{margin:.7rem 0; max-width:92%; line-height:1.5; font-size:.88rem}
      .zg-msg.user{margin-left:auto; background:var(--zg-accent); color:#fff; padding:.5rem .8rem; border:1px solid #000; white-space:pre-wrap}
      .zg-msg.assistant{background:#f0f0f0; border:1px solid #000; padding:.5rem .8rem}
      .zg-msg.assistant p{margin:0 0 .55em}
      .zg-msg.assistant p:last-child{margin-bottom:0}
      .zg-msg.assistant ul, .zg-msg.assistant ol{margin:.2em 0 .55em 1.15em; padding:0}
      .zg-msg.assistant li{margin:.15em 0}
      .zg-msg.assistant code{background:#dcdcdc; padding:.08em .3em; font-size:.85em}
      .zg-msg.assistant pre{background:#dcdcdc; padding:.5em .7em; overflow-x:auto}
      .zg-msg.assistant pre code{background:none; padding:0}
      .zg-msg.assistant a{color:var(--zg-accent)}
      .zg-msg.assistant strong{font-weight:700}
      .zg-copy-btn{
        display:block; margin-top:.5rem; font-family:var(--zg-face); font-size:.65rem; background:#c0c0c0; color:#000; cursor:pointer;
        padding:.15rem .5rem; border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
      }
      .zg-copy-btn:active{border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff}
      .zg-thinking{color:var(--zg-ink-dim); font-size:.82rem; font-style:italic}
      .zg-form{flex:0 0 auto; background:#c0c0c0; border-top:2px solid #000; padding:.55rem .8rem calc(.55rem + env(safe-area-inset-bottom))}
      .zg-form-inner{display:flex; gap:.5rem; align-items:flex-end}
      .zg-input-wrap{position:relative; flex:1}
      .zg-ghost{position:absolute; inset:0; margin:0; padding:.5rem .6rem; font-family:var(--zg-face); font-size:.85rem; line-height:1.4; white-space:pre-wrap; word-wrap:break-word; pointer-events:none; overflow:hidden; border:1px solid transparent; box-sizing:border-box; background:#fff}
      .zg-ghost .typed{color:transparent}
      .zg-ghost .suggestion{color:#888}
      .zg-input{
        position:relative; z-index:1; width:100%; display:block; font-family:var(--zg-face); font-size:.85rem; line-height:1.4;
        padding:.5rem .6rem; background:transparent; color:var(--zg-ink); resize:none; overflow:hidden; box-sizing:border-box;
        min-height:5.5rem; max-height:16rem;
        border-top:1px solid #808080; border-left:1px solid #808080; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #404040;
      }
      .zg-input-hint{font-size:.62rem; color:var(--zg-ink-dim); margin-top:.3rem}
      .zg-send{
        font-family:var(--zg-face); font-size:.8rem; font-weight:bold; background:#c0c0c0; color:#000; cursor:pointer; flex:0 0 auto;
        padding:.5rem 1rem; border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040;
      }
      .zg-send:active{border-top:1px solid #404040; border-left:1px solid #404040; border-right:1px solid #fff; border-bottom:1px solid #fff}
      .zg-send:disabled{opacity:.5; cursor:default}
      .zg-lock{max-width:300px; margin:1.5rem auto; padding:1.2rem; text-align:center}
      .zg-lock form{display:flex; gap:.5rem; margin-top:.8rem}
      .zg-lock input{
        flex:1; font-family:var(--zg-face); padding:.5rem .6rem; background:#fff; color:var(--zg-ink);
        border-top:1px solid #808080; border-left:1px solid #808080; border-right:1px solid #fff; border-bottom:1px solid #fff;
        box-shadow:inset 1px 1px 0 #404040;
      }
      .zg-lock .err{color:#c00; font-size:.8rem; margin-top:.5rem}

      @media (max-width:1300px){
        .zg-chat-panel{position:fixed; left:0; right:0; bottom:0; top:auto; width:auto!important; max-height:0; border-left:none; border-top:2px solid #000; box-shadow:0 -3px 0 #000; z-index:21; transition:max-height .22s ease}
        .zg-chat-panel.open{max-height:78vh}
        .zg-chat-panel-inner{width:auto; height:100%}
        #zge-inspector{width:300px}
      }

      @media (max-width:640px){
        #zge-inspector{width:100%; max-width:100%; top:auto; height:70vh; transform:translateY(105%); border-left:none; border-top:2px solid #000}
        #zge-inspector.open{transform:translateY(0)}
        .zg-header h1{font-size:12px}
        .zg-nav button{padding:3px 6px; font-size:10px}
      }
    </style>

    <div class="zg-page">
      <div class="zg-header">
        <h1>The Ziggy Account</h1>
        <span class="zg-meta">{@stats.nodes} nodes · {@stats.edges} edges · {@stats.themes} themes</span>
        <nav class="zg-nav">
          <button class={nav_class(@view, :overview)} phx-click="set_view" phx-value-view="overview">Overview</button>
          <button class={nav_class(@view, :plot)} phx-click="set_view" phx-value-view="plot">Plot</button>
          <button class={nav_class(@view, :characters)} phx-click="set_view" phx-value-view="characters">Characters</button>
          <button class={nav_class(@view, :themes)} phx-click="set_view" phx-value-view="themes">Themes</button>
          <button class={nav_class(@view, :search)} phx-click="set_view" phx-value-view="search">Search</button>
          <button class={if @chat_open, do: "on", else: ""} phx-click="toggle_chat">💬 Chat</button>
        </nav>
      </div>

      <div class="zg-main">
        <div class="zge-wrap">
          <div
            id="ziggy-explorer"
            phx-update="ignore"
            phx-hook="ZiggyApp"
            data-graph={@graph_json}
            data-active-view={@view}
          >
            <div class="zge-view" id="zge-overview"><div class="wrap" id="zge-overview-content"></div></div>

            <div class="zge-view" id="zge-plot">
              <div class="zge-toolbar" id="zge-plot-toolbar">
                <div><strong>Filter by chapter</strong></div>
                <div class="zge-chips" id="zge-plot-chips"></div>
              </div>
              <div class="zge-legend" id="zge-plot-legend"></div>
              <div class="zge-svg-holder"><svg id="zge-plot-svg"></svg></div>
            </div>

            <div class="zge-view" id="zge-characters">
              <div class="zge-toolbar"><div><strong>Who shares a scene</strong></div></div>
              <div class="zge-legend" id="zge-char-legend"></div>
              <div class="zge-svg-holder"><svg id="zge-char-svg"></svg></div>
            </div>

            <div class="zge-view" id="zge-themes"><div class="wrap" id="zge-themes-content"></div></div>

            <div class="zge-view" id="zge-search">
              <div class="wrap">
                <input type="text" id="zge-search-input" class="zge-search-input" placeholder="Search story beats…" autocomplete="off" />
                <div id="zge-search-results"></div>
              </div>
            </div>

            <aside id="zge-inspector">
              <div class="zg-mini-titlebar">
                <button class="zg-mini-close" id="zge-inspector-close"></button>
                <span class="zg-mini-title">Details</span>
              </div>
              <div id="zge-inspector-body"></div>
            </aside>
          </div>
        </div>


        <div class={"zg-chat-panel #{if @chat_open, do: "open"}"}>
          <div class="zg-chat-panel-inner">
            <div class="zg-chat-head">
              <strong>Ask the Graph</strong>
            </div>
            <%= cond do %>
              <% not @chat_enabled -> %>
                <div class="zg-lock">
                  <p>Chat isn't configured on this deploy (no password set).</p>
                </div>
              <% not @chat_unlocked -> %>
                <div class="zg-lock">
                  <p>This chat spends real API credits per message, so it's password-gated.</p>
                  <form phx-submit="check_chat_password">
                    <input type="password" name="password" placeholder="Password" autocomplete="current-password" />
                    <button type="submit" class="zg-send">Unlock</button>
                  </form>
                  <%= if @chat_password_error do %>
                    <div class="err">{@chat_password_error}</div>
                  <% end %>
                </div>
              <% true -> %>
                <div class="zg-chat-body">
                  <%= if @history == [] do %>
                    <div class="zg-empty">
                      Ask about a character, a decision, a theme, or how two chapters connect — grounded in the decision graph, not guesses. Browse the map beside this panel while you chat.
                      <div class="zg-presets">
                        <%= for q <- @presets do %>
                          <button class="zg-preset" phx-click="ask_preset" phx-value-q={q}>{q}</button>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                  <%= for {msg, idx} <- Enum.with_index(@history) do %>
                    <div class={"zg-msg #{msg["role"]}"}>
                      <%= if msg["role"] == "assistant" do %>
                        {render_markdown(msg["content"])}
                        <button class="zg-copy-btn" phx-hook="ZiggyCopy" id={"zg-copy-#{idx}"} data-text={msg["content"]}>Copy</button>
                      <% else %>
                        {msg["content"]}
                      <% end %>
                    </div>
                  <% end %>
                  <%= if @loading do %>
                    <div class="zg-thinking">reading the graph…</div>
                  <% end %>
                </div>
                <div class="zg-form">
                  <form phx-submit="send" class="zg-form-inner">
                    <div class="zg-input-wrap">
                      <div class="zg-ghost" id="zg-ghost"><span class="typed"></span><span class="suggestion"></span></div>
                      <textarea
                        name="message"
                        id="zg-chat-input"
                        class="zg-input"
                        rows="1"
                        placeholder="Ask something — write a full thought, not a fragment."
                        phx-hook="ZiggyChatInput"
                        disabled={@loading}
                      >{@draft}</textarea>
                    </div>
                    <button type="submit" class="zg-send" disabled={@loading}>Ask</button>
                  </form>
                  <div class="zg-input-hint">Tab accepts a suggestion · Shift+Enter for a new line</div>
                </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
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
