defmodule BlogWeb.KeyloggerLive do
  use BlogWeb, :live_view
  import BlogWeb.CoreComponents
  require Logger
  alias Phoenix.LiveView.JS
  @meta_attrs [
         %{name: "title", content: "See what key you are pressing, and have it remembered"},
         %{name: "description", content: "See what key you are pressing. It also will keep what you type on hand to print if you want"},
         %{property: "og:title", content: "See what key you are pressing, and have it remembered"},
         %{property: "og:description", content: "See what key you are pressing. It also will keep what you type on hand to print if you want"},
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
          <<_last_character::binary-size(1), rest::binary>> = String.reverse(socket.assigns.pressed_keys)
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
        _ -> socket.assigns.pressed_keys <> key
      end
    {:noreply, assign(socket, pressed_key: key, pressed_keys: pressed_keys) |> assign(show_modal: false)}
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
      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }

      #content-of-letter {
        font-family: "Courier New", Courier, monospace;
        line-height: 1.5;
        white-space: pre-wrap;
        word-wrap: break-word;
      }

      .text-container {
        white-space: pre-wrap;
        font-family: monospace;
      }

      .letter-animate {
        display: inline;
        opacity: 0;
        animation: fadeIn 0.2s ease-out forwards;
      }

      @media print {
        /* Hide everything by default */
        body * {
          visibility: hidden;
        }

        /* Only show the content we want to print */
        #content-of-letter,
        #content-of-letter * {
          visibility: visible;
        }

        /* Position the content at the top of the page */
        #content-of-letter {
          position: absolute;
          left: 0;
          top: 0;
          width: 100%;
          text-align: left;
          white-space: pre-wrap;
          font-family: "Courier New", Courier, monospace;
          font-size: 14px;
          line-height: 1.5;
          color: #333;
          padding: 2rem;
        }
      }

      .cursor {
        display: inline-block;
        width: 2px;
        height: 1em;
        background-color: #333;
        margin-left: 1px;
        animation: blink 1s step-end infinite;
      }
    </style>

    <.head_tags meta_attrs={@meta_attrs} page_title={@page_title} />
    <h1 class="text-[75px]">Pressing: <%= @pressed_key %></h1>
    <%= if @show_modal do %>
      <div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center" phx-click="toggle_modal">
        <div class="bg-white p-8 rounded-lg shadow-lg max-w-lg" phx-click-away="toggle_modal">
          <div class="prose">
            <p class="font-mono text-gray-800">
            This is met to simulate a typewriter. You can type a message out.

            Backspace is supported to fix text. As are newlines.

            Otherwise you must type deliberately and precisely.

            If you print preview the page with ctrl/cmd + p, you get a nice format of document to print this and mail it like a letter.

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
    <div id="content-of-letter" class="mt-4 text-gray-500" phx-window-keydown="keydown">
      <div class="mb-4">
        THIS COPY IS PROVIDED WITH NO COPY AND PASTE AND IS ALL HAND WRITTEN BY YOUR COMMON HUMAN FRIEND
      </div>
      <div class="text-container"><%= for {char, index} <- String.split(@pressed_keys, "") |> Enum.with_index() do %><span class="letter-animate" style={"animation-delay: #{index * 0.005}s"}><%= char %></span><% end %></div>
    </div>
    """
  end

  def fade_in(js \\ %JS{}) do
    JS.transition(js,
      {"transition-all transform ease-out duration-200",
       "opacity-0 translate-y-2",
       "opacity-100 translate-y-0"})
  end
end
