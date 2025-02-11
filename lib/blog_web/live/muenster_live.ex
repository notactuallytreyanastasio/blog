defmodule BlogWeb.MuensterLive do
  use BlogWeb, :live_view
  require Logger
  alias Blog.Social.Skeet
  alias Blog.Repo

  @max_posts 500

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "muenster_posts")
    end

    posts = Repo.all(from s in Skeet, order_by: [desc: s.inserted_at])
            |> Enum.map(fn skeet -> %{text: skeet.skeet, timestamp: skeet.inserted_at} end)

    {:ok, assign(socket,
      posts: posts,
      total_count: Enum.count(posts)
    )}
  end

  def handle_info({:new_post, skeet}, socket) do
    # Don't update the UI here - the database insert will trigger a new DB query
    # This prevents double-display of posts
    {:noreply, socket}
  end

  # Handle the successful database insert
  def handle_info({:skeet_saved, skeet, timestamp}, socket) do
    posts = [%{text: skeet, timestamp: timestamp} | socket.assigns.posts]
            |> Enum.take(@max_posts)

    {:noreply, assign(socket,
      posts: posts,
      total_count: socket.assigns.total_count + 1
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="p-4">
      <h1 class="text-2xl font-bold mb-4">Muenster Mentions</h1>
      <div class="text-sm text-gray-500 mb-4">
        Total mentions: <%= @total_count %>
      </div>
      <div class="space-y-4">
        <%= for post <- @posts do %>
          <div class="p-4 bg-white shadow rounded-lg border border-gray-200">
            <p class="text-gray-800 whitespace-pre-wrap"><%= post.text %></p>
            <div class="mt-2 text-xs text-gray-500">
              <%= Calendar.strftime(post.timestamp, "%Y-%m-%d %H:%M:%S") %>
            </div>
          </div>
        <% end %>
        <%= if Enum.empty?(@posts) do %>
          <p class="text-gray-500 italic">Waiting for posts mentioning muenster...</p>
        <% end %>
      </div>
    </div>
    """
  end
end
