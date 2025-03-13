defmodule BlogWeb.KeyloggerLive do
  use BlogWeb, :live_view
  import BlogWeb.CoreComponents
  require Logger
  alias Phoenix.LiveView.JS

  @meta_attrs [
    %{name: "title", content: "See what key you are pressing, and have it remembered"},
    %{
      name: "description",
      content:
        "See what key you are pressing. It also will keep what you type on hand to print if you want"
    },
    %{property: "og:title", content: "See what key you are pressing, and have it remembered"},
    %{
      property: "og:description",
      content:
        "See what key you are pressing. It also will keep what you type on hand to print if you want"
    },
    %{property: "og:type", content: "website"}
  ]

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       pressed_key: "",
       pressed_keys: "",
       show_modal: true,
       page_title: "Experiment - sorta typewriter",
       meta_attrs: @meta_attrs
     )}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    Logger.info("Key pressed: #{key}")

    pressed_keys =
      case key do
        "Backspace" ->
          # first we reverse the string, and take the firts character
          <<_last_character::binary-size(1), rest::binary>> =
            String.reverse(socket.assigns.pressed_keys)

          # then since its reversed, and just that one sliced off, we have
          # effectively "backspaced" and we can now reverse the list again, and
          # we have the copy that the user desires, successfuly having reached their
          # backspace escape hatch
          String.reverse(rest)

        "Meta" ->
          # If it is the meta key, they aren't going to be able to
          # type a character, so we just skip it too
          socket.assigns.pressed_keys

        "Shift" ->
          # if its shift, we skip because the character that shift creates comes next,
          # e.g, shift + A comes along when shift and a are pressed but we just want the A
          # so, since we know its coming here, we skip the key itself and
          # trust that the next event will come
          socket.assigns.pressed_keys

        "Enter" ->
          socket.assigns.pressed_keys <> "\r\n"

        _ ->
          socket.assigns.pressed_keys <> key
      end

    {:noreply,
     assign(socket, pressed_key: key, pressed_keys: pressed_keys) |> assign(show_modal: false)}
  end

  def handle_event("toggle_modal", %{"value" => _}, socket) do
    {:noreply, assign(socket, show_modal: !socket.assigns.show_modal)}
  end

  def handle_event("toggle_modal", _, socket) do
    {:noreply, assign(socket, show_modal: !socket.assigns.show_modal)}
  end

  def render(assigns) do
    ~H"""
    <style>
      html, body {
        background-color: white !important;
        color: black !important;
      }

      body > div, main, section, article {
        background-color: white !important;
      }

      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }

      #content-of-letter {
        font-family: "Courier New", Courier, monospace;
        line-height: 1.5;
        color: black;
        background-color: white;
      }

      .typewriter-text {
        font-family: "Courier New", Courier, monospace;
        white-space: pre-wrap;
        margin: 0;
        padding: 0;
        color: black;
        background-color: white;
      }

      /* Hide print-only content during normal viewing */
      .print-only {
        display: none;
      }

      @media print {
        /* Hide everything except print content */
        body * {
          visibility: hidden;
        }

        /* Show only our print content */
        .print-only {
          display: block !important;
          visibility: visible !important;
          position: absolute;
          left: 0;
          top: 0;
          width: 100%;
          padding: 2rem;
          font-family: "Courier New", Courier, monospace;
          font-size: 14px;
          line-height: 1.5;
          white-space: pre-wrap;
          color: black;
          background-color: white;
        }
      }
    </style>
    <div class="print-only">
      THIS COPY IS PROVIDED WITH NO COPY AND PASTE AND IS ALL HAND WRITTEN BY YOUR COMMON HUMAN FRIEND {@pressed_keys}
    </div>
    <.head_tags meta_attrs={@meta_attrs} page_title={@page_title} />
    <h1 class="text-[75px] text-black">Pressing: {@pressed_key}</h1>
    <%= if @show_modal do %>
      <div
        class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center"
        phx-click="toggle_modal"
      >
        <div class="bg-white p-8 rounded-lg shadow-lg max-w-lg" phx-click-away="toggle_modal">
          <div class="prose">
            <p class="font-mono text-gray-800">
              Write a truly from-the-heart, manual Valentine's letter to your love. <br />
              This is met to simulate a typewriter. You can type a message out. <br />
              It Even prints like one, try pressing ctrl/cmd + P, then printing the letter for your love.
              <br /> Backspace is supported to fix text. As are newlines.

              Otherwise you must type deliberately and precisely.

              If you print preview the page with ctrl/cmd + p, you get a nice format of document to print this and mail it like a letter.
              <br />
              <br />
              It comes with a guarantee from me that you manually typed it on this website character by character, doing the real work.
            </p>
          </div>
          <div class="mt-6 flex justify-end">
            <button
              phx-click="toggle_modal"
              class="px-4 py-2 bg-gray-800 text-gray-100 rounded hover:bg-gray-700 font-mono"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    <% end %>
    <div id="content-of-letter" class="mt-4 bg-white" phx-window-keydown="keydown">
      <div class="mb-4 bg-white">
        <div class="text-black font-mono mb-2 bg-white">THIS COPY IS PROVIDED WITH NO COPY AND PASTE AND IS ALL HAND WRITTEN BY YOUR COMMON HUMAN FRIEND</div>
        <pre class="typewriter-text bg-white"><%= @pressed_keys %></pre>
      </div>
    </div>
    """
  end

  def fade_in(js \\ %JS{}) do
    JS.transition(
      js,
      {"transition-all transform ease-out duration-200", "opacity-0 translate-y-2",
       "opacity-100 translate-y-0"}
    )
  end
end
