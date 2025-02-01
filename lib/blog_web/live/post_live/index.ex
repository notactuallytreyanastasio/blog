defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view
  alias BlogWeb.Presence

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
    total_readers = Presence.list(@presence_topic) |> map_size()

    {:ok, assign(socket, posts: posts, total_readers: total_readers)}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    total_readers = Presence.list(@presence_topic) |> map_size()
    {:noreply, assign(socket, total_readers: total_readers)}
  end

  # Add this to your index template:
  def render(assigns) do
    ~H"""
    <div class="px-8 py-12">
      <div class="max-w-7xl mx-auto">
        <div class="mb-4 text-sm text-gray-500">
          <%= @total_readers %> <%= if @total_readers == 1, do: "person", else: "people" %> browsing the blog
        </div>
        <!-- Rest of your template... -->
      </div>
    </div>
    """
  end
end
