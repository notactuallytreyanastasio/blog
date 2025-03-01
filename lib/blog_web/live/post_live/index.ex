defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view
  alias BlogWeb.Presence
  alias Blog.Content

  @presence_topic "blog_presence"

  # TODO add meta tags
  def mount(_params, _session, socket) do
    if connected?(socket) do
      reader_id = "reader_#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"

      {:ok, _} =
        Presence.track(self(), @presence_topic, reader_id, %{
          page: "index",
          joined_at: DateTime.utc_now()
        })

      Phoenix.PubSub.subscribe(Blog.PubSub, @presence_topic)
    end

    posts = Blog.Content.Post.all()
    %{tech: tech_posts, non_tech: non_tech_posts} = Content.categorize_posts(posts)
    total_readers = Presence.list(@presence_topic) |> map_size()

    {:ok,
     assign(socket,
       tech_posts: tech_posts,
       non_tech_posts: non_tech_posts,
       total_readers: total_readers,
       page_title: "Tidbits & Thoughts - A Retro Hacker Blog",
       cursor_position: nil
     )}
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    total_readers = Presence.list(@presence_topic) |> map_size()
    {:noreply, assign(socket, total_readers: total_readers)}
  end

  def handle_event("mousemove", %{"x" => x, "y" => y}, socket) do
    {:noreply, assign(socket, cursor_position: %{x: x, y: y})}
  end

  def render(assigns) do
    ~H"""
    <div
      class="py-12 px-4 sm:px-6 lg:px-8 min-h-screen"
      id="cursor-tracker-container"
      phx-hook="CursorTracker"
    >
      <%= if @cursor_position do %>
        <div class="fixed top-4 right-4 bg-gradient-to-r from-fuchsia-500 to-cyan-500 text-white px-3 py-1 rounded-lg shadow-md text-sm font-mono z-50">
          x: <%= @cursor_position.x %>, y: <%= @cursor_position.y %>
        </div>
      <% end %>
      <div class="max-w-7xl mx-auto">
        <!-- Header with retro styling -->
        <header class="mb-12 text-center">
          <div class="inline-block p-1 bg-gradient-to-r from-fuchsia-500 to-cyan-500 rounded-lg shadow-lg mb-6">
            <h1 class="text-4xl md:text-5xl font-bold bg-white px-6 py-3 rounded-md">
              <span class="text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-600 to-cyan-600">
                Thoughts & Tidbits
              </span>
            </h1>
          </div>

          <div class="flex justify-center items-center space-x-2 text-sm text-gray-600 mb-4">
            <div class="inline-flex items-center px-3 py-1 rounded-full bg-gradient-to-r from-fuchsia-100 to-cyan-100 border border-fuchsia-200">
              <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 mr-1 text-fuchsia-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
              </svg>
              <span><%= @total_readers %> <%= if @total_readers == 1, do: "person", else: "people" %> browsing</span>
            </div>
          </div>

          <p class="text-gray-600 max-w-2xl mx-auto">
            A collection of thoughts on technology, life, and weird little things I make.
          </p>
        </header>

        <!-- Two column layout for posts -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <!-- Tech Posts Column -->
          <div class="bg-gradient-to-br from-fuchsia-50 to-cyan-50 rounded-xl p-6 shadow-lg border border-fuchsia-100">
            <div class="flex items-center mb-6">
              <div class="w-3 h-3 rounded-full bg-fuchsia-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-cyan-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-indigo-400 mr-4"></div>
              <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-fuchsia-600 to-cyan-600">
                Tech & Programming
              </h2>
            </div>

            <div class="space-y-4">
              <%= for post <- @tech_posts do %>
                <div class="group bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-all duration-300 border-l-4 border-fuchsia-400">
                  <.link navigate={~p"/post/#{post.slug}"} class="block">
                    <h3 class="text-xl font-bold text-gray-800 group-hover:text-fuchsia-600 transition-colors">
                      <%= post.title %>
                    </h3>
                    <div class="flex flex-wrap gap-2 mt-2">
                      <%= for tag <- post.tags do %>
                        <span class="inline-block px-2 py-1 bg-gradient-to-r from-fuchsia-100 to-cyan-100 rounded-full text-xs font-medium text-gray-700">
                          <%= tag.name %>
                        </span>
                      <% end %>
                    </div>
                  </.link>
                </div>
              <% end %>
            </div>
          </div>

          <!-- Non-Tech Posts Column -->
          <div class="bg-gradient-to-br from-cyan-50 to-fuchsia-50 rounded-xl p-6 shadow-lg border border-cyan-100">
            <div class="flex items-center mb-6">
              <div class="w-3 h-3 rounded-full bg-cyan-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-fuchsia-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-indigo-400 mr-4"></div>
              <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-cyan-600 to-fuchsia-600">
                Life & Everything Else
              </h2>
            </div>

            <div class="space-y-4">
              <%= for post <- @non_tech_posts do %>
                <div class="group bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-all duration-300 border-l-4 border-cyan-400">
                  <.link navigate={~p"/post/#{post.slug}"} class="block">
                    <h3 class="text-xl font-bold text-gray-800 group-hover:text-cyan-600 transition-colors">
                      <%= post.title %>
                    </h3>
                    <div class="flex flex-wrap gap-2 mt-2">
                      <%= for tag <- post.tags do %>
                        <span class="inline-block px-2 py-1 bg-gradient-to-r from-cyan-100 to-fuchsia-100 rounded-full text-xs font-medium text-gray-700">
                          <%= tag.name %>
                        </span>
                      <% end %>
                    </div>
                  </.link>
                </div>
              <% end %>
            </div>
          </div>

                  <!-- Non-Tech Posts Column -->
          <div class="bg-gradient-to-br from-cyan-50 to-fuchsia-50 rounded-xl p-6 shadow-lg border border-cyan-100">
            <div class="flex items-center mb-6">
              <div class="w-3 h-3 rounded-full bg-cyan-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-fuchsia-400 mr-2"></div>
              <div class="w-3 h-3 rounded-full bg-indigo-400 mr-4"></div>
              <h2 class="text-2xl font-bold text-transparent bg-clip-text bg-gradient-to-r from-cyan-600 to-fuchsia-600">
                Tech Demos
              </h2>
            </div>

            <div class="space-y-4">
              <%= for post <- @non_tech_posts do %>
                <div class="group bg-white rounded-lg p-4 shadow-sm hover:shadow-md transition-all duration-300 border-l-4 border-cyan-400">
                  <.link navigate={~p"/post/#{post.slug}"} class="block">
                    <h3 class="text-xl font-bold text-gray-800 group-hover:text-cyan-600 transition-colors">
                      <%= "Reddit Links Feed" %>
                    </h3>
                  </.link>
                </div>
              <% end %>
            </div>
          </div>
        </div>
        </div>

        <!-- Retro footer -->
        <footer class="mt-16 text-center">
          <div class="inline-block px-4 py-2 bg-gradient-to-r from-fuchsia-100 to-cyan-100 rounded-full text-sm text-gray-700">
            <span class="font-mono">/* Crafted with ♥ and Elixir */</span>
          </div>
        </footer>
    </div>
    """
  end
end
