defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias Blog.Content

  @presence_topic "blog_presence"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      reader_id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

      {:ok, _} = Presence.track(self(), @presence_topic, reader_id, %{
        page: "index",
        joined_at: DateTime.utc_now()
      })

      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
    end

    posts = Blog.Content.Post.all()
    %{tech: tech_posts, non_tech: non_tech_posts} = Content.categorize_posts(posts)
    total_readers = Presence.list(@presence_topic) |> map_size()

    {:ok, assign(socket,
      tech_posts: tech_posts,
      non_tech_posts: non_tech_posts,
      total_readers: total_readers
    )}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    total_readers = Presence.list(@presence_topic) |> map_size()
    {:noreply, assign(socket, total_readers: total_readers)}
  end

  def render(assigns) do
    ~H"""
    <div class="px-8 py-12">
      <div class="max-w-7xl mx-auto">
        <div class="mb-4 text-sm text-gray-500">
          <%= @total_readers %> <%= if @total_readers == 1, do: "person", else: "people" %> browsing the blog
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <%!-- Tech Posts Column --%>
          <div>
            <h2 class="text-2xl font-bold mb-6 pb-2 border-b">Tech & Programming</h2>
            <div class="space-y-6">
              <div :for={post <- @tech_posts} class="mb-8">
                <.link navigate={~p"/post/#{post.slug}"}>
                  <h3 class="text-xl font-bold hover:text-blue-600 transition-colors"><%= post.title %></h3>
                  <p class="text-sm text-gray-600 mt-1">
                    <%= post.tags |> Enum.map(& &1.name) |> Enum.join(", ") %>
                  </p>
                </.link>
              </div>
            </div>
          </div>

          <%!-- Non-Tech Posts Column --%>
          <div>
            <h2 class="text-2xl font-bold mb-6 pb-2 border-b">Life & Everything Else</h2>
            <div class="space-y-6">
              <div :for={post <- @non_tech_posts} class="mb-8">
                <.link navigate={~p"/post/#{post.slug}"}>
                  <h3 class="text-xl font-bold hover:text-blue-600 transition-colors"><%= post.title %></h3>
                  <p class="text-sm text-gray-600 mt-1">
                    <%= post.tags |> Enum.map(& &1.name) |> Enum.join(", ") %>
                  </p>
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
