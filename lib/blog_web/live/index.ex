defmodule BlogWeb.PostLive.Index do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    posts = Blog.Content.Post.all()
    {:ok, assign(socket, posts: posts)}
  end

  def render(assigns) do
    ~H"""
    <div class="px-8 py-12">
      <div class="max-w-7xl mx-auto">
        <h1 class="text-4xl font-bold text-gray-900 mb-8">All Posts</h1>

        <div class="space-y-10">
          <%= for post <- @posts do %>
            <article class="p-6 bg-white rounded-lg border-2 border-gray-200">
              <h2 class="text-2xl font-bold text-gray-900 mb-2">
                <.link href={~p"/post/#{post.slug}"} class="hover:text-blue-600 transition-colors">
                  <%= post.title %>
                </.link>
              </h2>

              <div class="flex items-center space-x-4 text-sm text-gray-500 mb-4">
                <time datetime={post.written_on}>
                  <%= Calendar.strftime(post.written_on, "%B %d, %Y") %>
                </time>
                <div class="flex items-center space-x-2">
                  <%= for tag <- post.tags do %>
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100">
                      <%= tag.name %>
                    </span>
                  <% end %>
                </div>
              </div>

              <div class="prose prose-lg max-w-none">
                <%= # Show first paragraph or excerpt %>
                <%= String.split(post.body, "\n\n") |> List.first() %>
              </div>

              <div class="mt-4">
                <.link href={~p"/post/#{post.slug}"} class="text-blue-600 hover:text-blue-800 transition-colors">
                  Read more →
                </.link>
              </div>
            </article>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
