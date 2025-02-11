defmodule BlogWeb.MuensterLive do
  use BlogWeb, :live_view
  require Logger

  @max_posts 500

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "muenster_posts")
    end
    posts = Blog.Repo.all(Blog.Social.Skeet) |> Enum.map(fn(skeet) -> %{text: skeet.skeet, timestamp: skeet.inserted_at} end)
    # get the most recent ten muenster skeets from the database
    {:ok, assign(socket,
      posts: posts,
      total_count: Enum.count(posts)
    )}
  end

  def handle_info({:new_post, skeet}, socket) do
    posts = [%{
      text: skeet,
      timestamp: NaiveDateTime.local_now()
    } | socket.assigns.posts] |> Enum.take(@max_posts)

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
