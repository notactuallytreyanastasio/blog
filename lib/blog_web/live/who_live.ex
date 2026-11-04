defmodule BlogWeb.WhoLive do
  @moduledoc """
  The Doctor Who knowledge graph with a chat beside it.

  The graph itself is browsed in full at the `danielle_who` explorer; this
  page carries enough of it (the Doctors, their stories, a node inspector
  and search) to follow what the chat is citing, and the chat is the point.
  Gated at the page level like `/lolly`: the chat spends model credits per
  message, and the graph is not sent down the wire until the gate opens.
  """

  use BlogWeb, :live_view

  alias Blog.{GraphChat, Who}

  @graph_key "who"
  @max_chat_messages 40
  @explorer_url "https://notactuallytreyanastasio.github.io/danielle_who/"

  @presets [
    "Which Doctor has the most stories, and across which media?",
    "What did the show decide about the Time War, and how many times did it change its mind?",
    "Walk me forward from Blink in broadcast order.",
    "Which TV stories are still missing from the archive?"
  ]

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     assign(socket,
       visitor_id: session["user_id"] || "",
       page_title: "Doctor Who: ask the graph",
       unlocked: false,
       password_error: nil,
       chat_enabled: chat_configured?(),
       chat_open: true,
       stats: nil,
       doctors: [],
       eras: [],
       doctor: nil,
       stories: [],
       query: "",
       results: [],
       node: nil,
       history: [],
       conversation_id: nil,
       conversations: [],
       chat_view: :chat,
       loading: false,
       chat_count: 0,
       presets: @presets,
       explorer_url: @explorer_url,
       provider: Blog.LLM.label()
     )}
  end

  defp unlock(socket) do
    conversation_id = GraphChat.latest_conversation_id(@graph_key) || GraphChat.new_conversation_id()

    assign(socket,
      unlocked: true,
      password_error: nil,
      conversation_id: conversation_id,
      history: GraphChat.history(@graph_key, conversation_id),
      stats: Who.stats(),
      doctors: Who.doctors(),
      eras: Who.eras()
    )
  end

  defp chat_password, do: Application.get_env(:blog, :who_chat_password)

  defp chat_configured? do
    case chat_password() do
      pw when is_binary(pw) and pw != "" -> true
      _ -> false
    end
  end

  @impl true
  def handle_event("unlock_page", %{"password" => pw}, socket) do
    cond do
      not chat_configured?() ->
        {:noreply,
         assign(socket,
           password_error: "This page is locked and no password is configured on this deploy."
         )}

      pw == chat_password() ->
        {:noreply, unlock(socket)}

      true ->
        {:noreply, assign(socket, password_error: "Wrong password.")}
    end
  end

  # Everything below the gate refuses to run until it is open, so a crafted
  # event cannot pull graph data through a locked page.
  def handle_event(_event, _params, %{assigns: %{unlocked: false}} = socket),
    do: {:noreply, socket}

  def handle_event("toggle_chat", _params, socket),
    do: {:noreply, assign(socket, chat_open: !socket.assigns.chat_open)}

  def handle_event("pick_doctor", %{"id" => id}, socket) do
    id = String.to_integer(id)

    if socket.assigns.doctor && socket.assigns.doctor.id == id do
      {:noreply, assign(socket, doctor: nil, stories: [])}
    else
      doctor = Enum.find(socket.assigns.doctors, &(&1.id == id))
      {:noreply, assign(socket, doctor: doctor, stories: Who.stories_of(id), node: nil)}
    end
  end

  def handle_event("search", %{"q" => q}, socket) do
    q = String.trim(q)
    results = if q == "", do: [], else: Who.search_nodes(q, limit: 30)
    {:noreply, assign(socket, query: q, results: results)}
  end

  def handle_event("inspect", %{"id" => id}, socket) do
    case Who.get_node(id) do
      nil ->
        {:noreply, socket}

      node ->
        {:noreply, assign(socket, node: Map.merge(Who.to_summary(node), Who.neighbors(node.id)))}
    end
  end

  def handle_event("close_node", _params, socket), do: {:noreply, assign(socket, node: nil)}

  def handle_event("send", %{"message" => text}, socket) do
    text = String.trim(text)
    a = socket.assigns

    cond do
      text == "" or a.loading ->
        {:noreply, socket}

      a.chat_count >= @max_chat_messages ->
        note =
          "This session has hit its #{@max_chat_messages}-message limit (keeps a runaway conversation from burning API credits). Refresh the page to start a new one."

        {:noreply, assign(socket, history: a.history ++ [%{"role" => "assistant", "content" => note}])}

      true ->
        history = a.history ++ [%{"role" => "user", "content" => text}]
        GraphChat.append(@graph_key, a.visitor_id, a.conversation_id, "user", text)

        # Only the tail goes to the model: the whole window is resent every
        # turn, so an unbounded history would grow the bill with the chat.
        window = GraphChat.context_window(history)

        {:noreply,
         socket
         |> assign(history: history, loading: true, chat_count: a.chat_count + 1, chat_open: true)
         |> start_async(:ask, fn -> Blog.Who.Chat.ask(window) end)}
    end
  end

  def handle_event("ask_preset", %{"q" => q}, socket), do: handle_event("send", %{"message" => q}, socket)

  def handle_event("ask_about", %{"title" => title}, socket),
    do: handle_event("send", %{"message" => "Tell me about #{title}."}, socket)

  def handle_event("new_chat", _params, socket) do
    {:noreply, assign(socket, conversation_id: GraphChat.new_conversation_id(), history: [], chat_view: :chat)}
  end

  def handle_event("show_history", _params, socket) do
    {:noreply, assign(socket, chat_view: :history, conversations: GraphChat.list_conversations(@graph_key))}
  end

  def handle_event("show_chat", _params, socket), do: {:noreply, assign(socket, chat_view: :chat)}

  def handle_event("open_conversation", %{"id" => id}, socket) do
    {:noreply,
     assign(socket, conversation_id: id, history: GraphChat.history(@graph_key, id), chat_view: :chat)}
  end

  def handle_event("delete_conversation", %{"id" => id}, socket) do
    a = socket.assigns
    GraphChat.delete_conversation(@graph_key, id)
    socket = assign(socket, conversations: GraphChat.list_conversations(@graph_key))

    socket =
      if id == a.conversation_id,
        do: assign(socket, conversation_id: GraphChat.new_conversation_id(), history: []),
        else: socket

    {:noreply, socket}
  end

  def handle_event("clear_history", _params, socket) do
    a = socket.assigns
    GraphChat.delete_conversation(@graph_key, a.conversation_id)

    {:noreply,
     assign(socket,
       history: [],
       conversation_id: GraphChat.new_conversation_id(),
       conversations: GraphChat.list_conversations(@graph_key)
     )}
  end

  @impl true
  def handle_async(:ask, {:ok, {:ok, reply}}, socket) do
    a = socket.assigns
    GraphChat.append(@graph_key, a.visitor_id, a.conversation_id, "assistant", reply)
    {:noreply, assign(socket, history: a.history ++ [%{"role" => "assistant", "content" => reply}], loading: false)}
  end

  def handle_async(:ask, {:ok, {:error, reason}}, socket) do
    history = socket.assigns.history ++ [%{"role" => "assistant", "content" => "Sorry, that did not go through: #{reason}"}]
    {:noreply, assign(socket, history: history, loading: false)}
  end

  def handle_async(:ask, {:exit, reason}, socket) do
    history = socket.assigns.history ++ [%{"role" => "assistant", "content" => "Sorry, something crashed (#{inspect(reason)})."}]
    {:noreply, assign(socket, history: history, loading: false)}
  end

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

  defp render_markdown(nil), do: ""

  defp render_markdown(text) do
    case Blog.Markdown.as_html(text) do
      {:ok, html, _} -> Phoenix.HTML.raw(html)
      _ -> Phoenix.HTML.raw(text |> Phoenix.HTML.html_escape() |> Phoenix.HTML.safe_to_string())
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <style>
      :root{
        --who-blue:#003b6f; --who-blue-deep:#001f3f; --who-ink:#0b1220; --who-dim:#5b6472;
        --who-line:#9aa6b8; --who-paper:#f4f6fa; --who-gold:#c9a227;
        --who-mono:"Courier New",Courier,monospace; --who-face:Chicago,Geneva,"Helvetica Neue",Helvetica,Arial,sans-serif;
      }
      .who-page{position:fixed; inset:0; display:flex; flex-direction:column; overflow:hidden; color:var(--who-ink); font-family:var(--who-face); font-size:12px;
        background:repeating-linear-gradient(0deg,#0d2a4d,#0d2a4d 1px,#113561 1px,#113561 2px)}
      .who-header{flex:0 0 auto; display:flex; align-items:center; gap:.7rem; padding:6px 12px; background:var(--who-blue); color:#fff; border-bottom:2px solid #000; flex-wrap:wrap}
      .who-header h1{font-size:14px; margin:0; font-weight:bold; letter-spacing:.02em}
      .who-meta{font-family:var(--who-mono); font-size:10px; opacity:.85}
      .who-header a{color:var(--who-gold)}
      .who-nav{margin-left:auto; display:flex; gap:4px}
      .who-btn{font-family:var(--who-face); font-size:11px; cursor:pointer; border-radius:0; padding:3px 9px; background:#dfe6f0; color:#000;
        border-top:1px solid #fff; border-left:1px solid #fff; border-right:1px solid #404040; border-bottom:1px solid #404040}
      .who-btn.on{background:var(--who-gold); font-weight:bold}
      .who-btn.primary{font-weight:bold}
      .who-main{flex:1; min-height:0; display:flex; background:var(--who-paper)}
      .who-browse{flex:1; min-width:0; overflow-y:auto; padding:.9rem 1rem}
      .who-browse h2{font-size:12px; margin:1rem 0 .4rem; text-transform:uppercase; letter-spacing:.08em; color:var(--who-dim)}
      .who-browse h2:first-child{margin-top:0}
      .who-eras{display:flex; flex-wrap:wrap; gap:.4rem}
      .who-era{font-family:var(--who-mono); font-size:10px; background:#fff; border:1px solid var(--who-line); padding:2px 6px}
      .who-doctors{display:grid; grid-template-columns:repeat(auto-fill,minmax(210px,1fr)); gap:.35rem}
      .who-doctor{text-align:left; background:#fff; border:1px solid var(--who-line); padding:.4rem .55rem; cursor:pointer; font-family:var(--who-face); font-size:11px; line-height:1.35}
      .who-doctor.on{background:var(--who-blue); color:#fff; border-color:#000}
      .who-doctor .a{display:block; font-family:var(--who-mono); font-size:10px; opacity:.8}
      .who-list{list-style:none; margin:0; padding:0; columns:2; column-gap:1.2rem}
      .who-list li{break-inside:avoid; margin:0 0 .15rem}
      .who-list button{background:none; border:none; padding:0; font:inherit; font-size:11px; color:var(--who-blue); cursor:pointer; text-align:left; text-decoration:underline dotted}
      .who-search{display:flex; gap:.4rem; margin:.3rem 0 .6rem}
      .who-search input{flex:1; font-family:var(--who-mono); font-size:12px; padding:.35rem .5rem; border:1px solid #000; background:#fff}
      .who-node{background:#fff; border:1px solid #000; box-shadow:3px 3px 0 #000; padding:.7rem .9rem; margin:.4rem 0 1rem}
      .who-node h3{margin:0 0 .3rem; font-size:13px}
      .who-node .t{font-family:var(--who-mono); font-size:10px; color:var(--who-dim)}
      .who-node ul{list-style:none; margin:.4rem 0 0; padding:0; font-size:11px; line-height:1.5; max-height:260px; overflow-y:auto}
      .who-node ul button{background:none; border:none; padding:0; font:inherit; color:var(--who-blue); cursor:pointer; text-decoration:underline dotted}
      .who-node li .r{font-family:var(--who-mono); font-size:10px; color:var(--who-dim); margin-right:.3rem}
      .who-node .bar{display:flex; gap:.4rem; margin-top:.5rem}
      .who-chat{flex:0 0 auto; width:0; overflow:hidden; background:#fff; border-left:2px solid #000; display:flex; flex-direction:column; transition:width .22s ease}
      .who-chat.open{width:640px}
      .who-chat-inner{width:640px; flex:1; min-height:0; display:flex; flex-direction:column}
      .who-chat-head{height:22px; flex:0 0 auto; background:repeating-linear-gradient(90deg,#fff 0,#fff 1px,var(--who-blue) 1px,var(--who-blue) 2px); display:flex; align-items:center; justify-content:center; border-bottom:2px solid #000}
      .who-chat-head strong{font-size:11px; background:#fff; padding:0 8px}
      .who-chat-bar{flex:0 0 auto; display:flex; flex-wrap:wrap; gap:.3rem; padding:.4rem .6rem; border-bottom:1px solid var(--who-line)}
      .who-chat-body{flex:1; min-height:0; padding:.8rem .9rem 1rem; overflow-y:auto}
      .who-msg{margin:.7rem 0; max-width:92%; line-height:1.5; font-size:.88rem}
      .who-msg.user{margin-left:auto; background:var(--who-blue); color:#fff; padding:.5rem .8rem; border:1px solid #000; white-space:pre-wrap}
      .who-msg.assistant{background:var(--who-paper); border:1px solid #000; padding:.5rem .8rem}
      .who-msg.assistant p{margin:0 0 .55em}
      .who-msg.assistant p:last-child{margin-bottom:0}
      .who-msg.assistant ul, .who-msg.assistant ol{margin:.2em 0 .55em 1.15em; padding:0}
      .who-msg.assistant a{color:var(--who-blue)}
      .who-empty{font-size:.84rem; line-height:1.5; color:var(--who-dim)}
      .who-presets{display:flex; flex-direction:column; gap:.3rem; margin-top:.7rem}
      .who-preset{text-align:left; background:#fff; border:1px solid var(--who-line); padding:.4rem .6rem; cursor:pointer; font:inherit; font-size:.8rem; color:var(--who-ink)}
      .who-preset:hover{border-color:#000}
      .who-thinking{font-family:var(--who-mono); font-size:10px; color:var(--who-dim); margin:.5rem 0}
      .who-form{flex:0 0 auto; border-top:2px solid #000; padding:.5rem .6rem; display:flex; gap:.4rem; background:#fff}
      .who-form textarea{flex:1; font-family:var(--who-face); font-size:.88rem; padding:.45rem .55rem; border:1px solid #000; resize:none; min-height:2.4rem}
      .who-send{font-family:var(--who-face); font-size:11px; font-weight:bold; padding:0 .9rem; background:var(--who-blue); color:#fff; border:1px solid #000; cursor:pointer}
      .who-send:disabled{opacity:.5; cursor:default}
      .who-convo{display:flex; align-items:stretch; border:1px solid var(--who-line); margin:.3rem 0; background:#fff}
      .who-convo.current{border-color:#000; box-shadow:2px 2px 0 #000}
      .who-convo-open{flex:1; text-align:left; background:none; border:none; padding:.45rem .6rem; cursor:pointer; font:inherit}
      .who-convo-open .t{display:block; font-size:.84rem}
      .who-convo-open .m{display:block; font-family:var(--who-mono); font-size:10px; color:var(--who-dim)}
      .who-convo-del{border:none; border-left:1px solid var(--who-line); background:none; cursor:pointer; padding:0 .7rem; font-size:14px}
      .who-gate{flex:1; display:flex; align-items:center; justify-content:center; padding:1.5rem}
      .who-gate-box{background:#fff; border:1px solid #000; box-shadow:3px 3px 0 #000; padding:1.6rem 1.8rem; max-width:440px; text-align:center}
      .who-gate-box h1{font-size:15px; margin:0 0 .3rem}
      .who-gate-box .sub{font-size:.72rem; color:var(--who-dim); margin:0 0 1.1rem; font-style:italic}
      .who-gate-box p{font-size:.84rem; line-height:1.5; margin:0 0 .9rem}
      .who-gate-box form{display:flex; gap:.5rem}
      .who-gate-box input{flex:1; font-family:var(--who-mono); font-size:12px; padding:.4rem .5rem; border:1px solid #000}
      .who-gate-box .err{color:#c00; font-size:.8rem; margin-top:.7rem}
      @media (max-width:900px){
        .who-chat{position:fixed; left:0; right:0; bottom:0; width:auto!important; max-height:0; border-left:none; border-top:2px solid #000; z-index:21; transition:max-height .22s ease}
        .who-chat.open{max-height:78vh}
        .who-chat-inner{width:auto; height:100%}
        .who-list{columns:1}
      }
    </style>

    <div class="who-page">
      <%= if not @unlocked do %>
        <div class="who-gate">
          <div class="who-gate-box">
            <h1>Doctor Who: ask the graph</h1>
            <p class="sub">A chat over a fan-built knowledge graph of the whole show.</p>
            <%= if @chat_enabled do %>
              <p>This page is password protected.</p>
              <form phx-submit="unlock_page">
                <input type="password" name="password" placeholder="Password" autocomplete="current-password" autofocus />
                <button type="submit" class="who-send">Unlock</button>
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
        <div class="who-header">
          <h1>Doctor Who: ask the graph</h1>
          <span class="who-meta">
            {@stats.nodes} nodes · {@stats.edges} edges · {@stats.doctors} Doctors · {@stats.stories} TV stories · {@stats.decisions} decisions
            · <a href={@explorer_url} target="_blank" rel="noopener">full explorer ↗</a>
          </span>
          <nav class="who-nav">
            <button class={"who-btn #{if @chat_open, do: "on"}"} phx-click="toggle_chat">💬 Chat</button>
          </nav>
        </div>

        <div class="who-main">
          <div class="who-browse">
            <h2>Eras</h2>
            <div class="who-eras">
              <%= for e <- @eras do %>
                <button class="who-era" phx-click="inspect" phx-value-id={e.id}>{e.title} · {e.size}</button>
              <% end %>
            </div>

            <h2>Search the graph</h2>
            <form phx-submit="search" phx-change="search" class="who-search">
              <input type="text" name="q" value={@query} placeholder="Daleks, Rose, Gallifrey, Virgin NA…" phx-debounce="300" autocomplete="off" />
            </form>
            <%= if @query != "" do %>
              <%= if @results == [] do %>
                <div class="who-empty">Nothing in the graph matches those words.</div>
              <% else %>
                <ul class="who-list">
                  <%= for n <- @results do %>
                    <li><button phx-click="inspect" phx-value-id={n.id}>{n.title}</button> <span class="who-era">{n.node_type}</span></li>
                  <% end %>
                </ul>
              <% end %>
            <% end %>

            <%= if @node do %>
              <div class="who-node" id={"who-node-#{@node.id}"}>
                <h3>{@node.title}</h3>
                <div class="t">node {@node.id} · {@node.type} · {length(@node.outgoing)} out · {length(@node.incoming)} in</div>
                <ul>
                  <%= for e <- @node.outgoing do %>
                    <li><span class="r">→ {e.relation}</span><button class="who-list-btn" phx-click="inspect" phx-value-id={e.id}>{e.title}</button></li>
                  <% end %>
                  <%= for e <- @node.incoming do %>
                    <li><span class="r">← {e.relation}</span><button phx-click="inspect" phx-value-id={e.id}>{e.title}</button></li>
                  <% end %>
                </ul>
                <div class="bar">
                  <button class="who-btn primary" phx-click="ask_about" phx-value-title={@node.title}>Ask the chat about this</button>
                  <button class="who-btn" phx-click="close_node">Close</button>
                </div>
              </div>
            <% end %>

            <h2>The Doctors</h2>
            <div class="who-doctors">
              <%= for d <- @doctors do %>
                <button class={"who-doctor #{if @doctor && @doctor.id == d.id, do: "on"}"} phx-click="pick_doctor" phx-value-id={d.id}>
                  The {d.ordinal} Doctor
                  <span class="a">{d.actor} · {d.years}</span>
                </button>
              <% end %>
            </div>

            <%= if @doctor do %>
              <h2>{length(@stories)} stories filed under the {@doctor.ordinal} Doctor</h2>
              <ul class="who-list">
                <%= for s <- @stories do %>
                  <li><button phx-click="inspect" phx-value-id={s.id}>{s.title}</button></li>
                <% end %>
              </ul>
            <% end %>
          </div>

          <div class={"who-chat #{if @chat_open, do: "open"}"}>
            <div class="who-chat-inner">
              <div class="who-chat-head"><strong>Ask the TARDIS · {@provider}</strong></div>
              <%= if @chat_view == :history do %>
                <div class="who-chat-bar">
                  <button class="who-btn" phx-click="show_chat">&larr; Back to chat</button>
                  <button class="who-btn primary" phx-click="new_chat">+ New chat</button>
                </div>
                <div class="who-chat-body">
                  <%= if @conversations == [] do %>
                    <div class="who-empty">No earlier chats on this graph yet.</div>
                  <% else %>
                    <%= for c <- @conversations do %>
                      <div class={"who-convo #{if c.id == @conversation_id, do: "current"}"}>
                        <button class="who-convo-open" phx-click="open_conversation" phx-value-id={c.id}>
                          <span class="t">{c.title}</span>
                          <span class="m">{c.count} message(s) · {format_when(c.last_at)}{if c.id == @conversation_id, do: " · current"}</span>
                        </button>
                        <button class="who-convo-del" phx-click="delete_conversation" phx-value-id={c.id} title="Delete this chat">×</button>
                      </div>
                    <% end %>
                  <% end %>
                </div>
              <% else %>
                <div class="who-chat-bar">
                  <button class="who-btn primary" phx-click="new_chat">+ New chat</button>
                  <button class="who-btn" phx-click="show_history">Past chats</button>
                  <%= if @history != [] do %>
                    <button class="who-btn" phx-click="clear_history">Delete this chat</button>
                  <% end %>
                </div>
                <div class="who-chat-body" id="who-chat-body">
                  <%= if @history == [] do %>
                    <div class="who-empty">
                      Ask about a Doctor, a story, a companion, a villain, or one of the show's own decisions and the times it went back on them. Answers come from the graph and the wiki records, not from memory, and every chat here is shared and remembered.
                      <div class="who-presets">
                        <%= for q <- @presets do %>
                          <button class="who-preset" phx-click="ask_preset" phx-value-q={q}>{q}</button>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                  <%= for {msg, idx} <- Enum.with_index(@history) do %>
                    <div class={"who-msg #{msg["role"]}"} id={"who-msg-#{idx}"}>
                      <%= if msg["role"] == "assistant" do %>
                        {render_markdown(msg["content"])}
                      <% else %>
                        {msg["content"]}
                      <% end %>
                    </div>
                  <% end %>
                  <%= if @loading do %>
                    <div class="who-thinking">reading the graph…</div>
                  <% end %>
                </div>
                <form phx-submit="send" class="who-form">
                  <textarea name="message" id="who-chat-input" rows="2" placeholder="Ask the graph…" disabled={@loading}></textarea>
                  <button type="submit" class="who-send" disabled={@loading}>Send</button>
                </form>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
