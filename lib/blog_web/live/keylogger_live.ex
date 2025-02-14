defmodule BlogWeb.KeyloggerLive do
  use BlogWeb, :live_view
  import BlogWeb.CoreComponents
  require Logger
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
              Simulate a typewriter. We server this up so that when you type out a letter its as if it were on a typewriter, and we package it up to print for whoever you would like if you press the right key shortcut or button
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
    THIS COPY IS PROVIDED WITH NO COPY AND PASTE AND IS ALL HAND WRITTEN BY YOUR COMMON HUMAN FRIEND
        <br>
      <div class="whitespace-pre-wrap"><%= @pressed_keys %></div>
    </div>
    """
  end

end
