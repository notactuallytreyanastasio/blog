defmodule BlogWeb.MuensterLive do
  use BlogWeb, :live_view
  require Logger

  @max_posts 500

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Blog.PubSub, "muenster_posts")
    end
    import Ecto.Query
    # skeets no longer just contain muenster...
    posts = Blog.Repo.all(
      from s in Blog.Social.Skeet,
      where: ilike(s.skeet, "%muenster%"),
      order_by: [desc: s.inserted_at],
      limit: 3,
      select: %{text: s.skeet, timestamp: s.inserted_at}
    )
    # get the most recent ten muenster skeets from the database
    {:ok, assign(socket,
      posts: posts,
      total_count: Enum.count(posts),
      page_title: "Thoughts and Tidbits Blog: Bobby Experiment - muenster cheese skeet detection",
      meta_attrs: [
        %{name: "title", content: "Detect muenster cheese skeets coming across the wire, live from your back yard or device"},
        %{name: "description", content: "Try it, skeet something with the word muenster in it, and see if it appears here!"},
        %{property: "og:title", content: "Detect muenster cheese skeets coming across the wire, live from your back yard or device"},
        %{property: "og:description", content: "Try it, skeet something with the word muenster in it, and see if it appears here!"},
        %{property: "og:type", content: "website"}
      ]
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
    <.head_tags meta_attrs={@meta_attrs} page_title={@page_title} />
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

  def head_tags(assigns) do
    ~H"""
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <%= for meta <- @meta_attrs do %>
      <%= if Map.has_key?(meta, :name) do %>
        <meta name={meta.name} content={meta.content}/>
      <% else %>
        <meta property={meta.property} content={meta.content}/>
      <% end %>
    <% end %>
    <title><%= @page_title %></title>
    """
  end
end
