defmodule BlogWeb.VimTweetsLive do
  use BlogWeb, :live_view
  import BlogWeb.CoreComponents
  @meta_attrs [
        %{name: "title", content: "Browse Bluesky: In Vim Mode!"},
        %{name: "description", content: "Use j and k to navigate skeets"},
        %{property: "og:title", content: "Browse Bluesky: In Vim Mode!"},
        %{property: "og:description", content: "Use j and k to navigate skeets"},
        %{property: "og:type", content: "website"}
      ]

  @window_size 12
  def mount(_params, _session, socket) do
    tweets = Blog.Skeets.Sampler.sample(100) |> Enum.map(& &1.skeet)

    socket = socket
    |> assign(
      cursor: 0,
      tweets: tweets,
      visible_tweets: Enum.take(tweets, @window_size),
      page_title: "Thoughts and Tidbits Blog: Bobby Experiment - vim navigation",
      meta_attrs: @meta_attrs
    )

    {:ok, socket}
  end

  def handle_event("keydown", %{"key" => "j"}, socket) do
    new_cursor = min(socket.assigns.cursor + 1, length(socket.assigns.tweets) - 1)
    visible_tweets = get_visible_tweets(socket.assigns.tweets, new_cursor)
    {:noreply, assign(socket, cursor: new_cursor, visible_tweets: visible_tweets)}
  end

  def handle_event("keydown", %{"key" => "k"}, socket) do
    new_cursor = max(socket.assigns.cursor - 1, 0)
    visible_tweets = get_visible_tweets(socket.assigns.tweets, new_cursor)
    {:noreply, assign(socket, cursor: new_cursor, visible_tweets: visible_tweets)}
  end

  def handle_event("keydown", _key, socket), do: {:noreply, socket}

  defp get_visible_tweets(tweets, cursor) do
    start_idx = max(0, cursor - 2)
    Enum.slice(tweets, start_idx, @window_size)
  end

  def render(assigns) do
    ~H"""
    <.head_tags meta_attrs={@meta_attrs} page_title={@page_title} />
    <div class="mt-4 text-gray-500">
      Cursor position: <%= @cursor %>
    </div>
    <div class="p-4" phx-window-keydown="keydown">
      <div class="space-y-4">
        <%= for {tweet, index} <- Enum.with_index(@visible_tweets) do %>
          <div class={"p-4 border rounded #{if index == 2, do: 'bg-blue-100'}"}>
            <%= tweet %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
