defmodule BlogWeb.HackerNewsLive do
  use BlogWeb, :live_view
  require Logger

  @hn_api_base "https://hacker-news.firebaseio.com/v0"
  @topic "hacker_news:stories"
  # 3 minutes in milliseconds
  @refresh_interval 3 * 60 * 1000

  @impl true
  def mount(_params, _session, socket) do
    # lib/blog_web/components/.elixir-tools/# Get initial stories
    initial_stories = fetch_top_stories(50)

    if connected?(socket) do
      # Subscribe to the Hacker News stories topic
      Phoenix.PubSub.subscribe(Blog.PubSub, @topic)

      # Start timer to periodically refresh stories
      Process.send_after(self(), :refresh_stories, @refresh_interval)
    end

    {:ok,
     assign(socket,
       page_title: "Top Hacker News Stories",
       stories: initial_stories,
       stories_by_id: index_stories_by_id(initial_stories),
       last_updated: DateTime.utc_now(),
       meta_attrs: [
         %{name: "description", content: "Real-time feed of top Hacker News stories"},
         %{property: "og:title", content: "Top Hacker News Stories"},
         %{property: "og:description", content: "Real-time feed of top Hacker News stories"},
         %{property: "og:type", content: "website"}
       ]
     )}
  end

  @impl true
  def handle_info(:refresh_stories, socket) do
    # Fetch fresh stories
    Task.start(fn ->
      stories = fetch_top_stories(50)
      send(self(), {:stories_refreshed, stories})
    end)

    # Schedule next refresh
    if connected?(socket) do
      Process.send_after(self(), :refresh_stories, @refresh_interval)
    end

    {:noreply, socket}
  end

  @impl true
  def handle_info({:stories_refreshed, stories}, socket) do
    # Update socket with new stories
    stories_by_id = index_stories_by_id(stories)

    # Broadcast updates to all clients
    for story <- stories do
      Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {:story_update, story})
    end

    {:noreply,
     assign(socket,
       stories: stories,
       stories_by_id: stories_by_id,
       last_updated: DateTime.utc_now()
     )}
  end

  @impl true
  def handle_info({:story_update, story}, socket) do
    # Update stories map first to ensure stable rendering
    updated_stories_by_id = Map.put(socket.assigns.stories_by_id, story.id, story)

    # Get all stories, preserving order by rank
    updated_stories =
      (socket.assigns.stories ++ [story])
      |> Enum.uniq_by(& &1.id)
      |> Enum.sort_by(& &1.rank)
      |> Enum.take(50)

    {:noreply,
     assign(socket,
       stories: updated_stories,
       stories_by_id: updated_stories_by_id
     )}
  end

  # Fetch top stories directly from Hacker News API
  defp fetch_top_stories(limit) do
    # Get IDs of top stories
    {:ok, response} = Req.get("#{@hn_api_base}/topstories.json")
    story_ids = Enum.take(response.body, limit)

    # Fetch story details in parallel
    story_ids
    # Add rank starting from 1
    |> Enum.with_index(1)
    |> Enum.map(fn {id, rank} ->
      Task.async(fn -> fetch_story_details(id, rank) end)
    end)
    |> Enum.map(&Task.await/1)
    # Remove nils if any requests failed
    |> Enum.filter(& &1)
  end

  # Fetch details for a specific story
  defp fetch_story_details(id, rank) do
    case Req.get("#{@hn_api_base}/item/#{id}.json") do
      {:ok, response} ->
        # Format the story from the API response
        format_story(response.body, rank)

      {:error, error} ->
        Logger.error("Failed to fetch story #{id}: #{inspect(error)}")
        nil
    end
  end

  # Format raw story data from the API
  defp format_story(story_data, rank) do
    story_id = story_data["id"]
    default_url = "https://news.ycombinator.com/item?id=#{story_id}"

    %{
      id: story_id,
      title: story_data["title"],
      url: story_data["url"] || default_url,
      score: story_data["score"],
      by: story_data["by"],
      time: story_data["time"],
      descendants: story_data["descendants"] || 0,
      rank: rank,
      timestamp: DateTime.utc_now()
    }
  end

  # Index stories by ID for efficient updates
  defp index_stories_by_id(stories) do
    stories |> Enum.map(&{&1.id, &1}) |> Map.new()
  end

  # Format Unix timestamp as a human-readable date
  defp format_time(unix_time) when is_integer(unix_time) do
    unix_time
    |> DateTime.from_unix!()
    |> Calendar.strftime("%b %d, %Y %H:%M")
  end

  defp format_time(_), do: ""

  # Format the domain from a URL
  defp format_domain(nil), do: ""

  defp format_domain(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{host: nil} -> ""
      %URI{host: host} -> host
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="max-w-5xl mx-auto py-8 px-4">
        <header class="mb-8">
          <div class="flex items-center justify-between">
            <h1 class="text-3xl font-bold text-gray-900">Top Hacker News Stories</h1>
            <div class="flex items-center">
              <span class="bg-orange-100 text-orange-800 text-xs font-medium me-2 px-2.5 py-0.5 rounded-full">
                Live Updates
              </span>
              <span class="text-xs text-gray-500">
                Last updated: {if assigns[:last_updated],
                  do: Calendar.strftime(@last_updated, "%H:%M:%S"),
                  else: "loading..."}
              </span>
            </div>
          </div>
          <p class="text-gray-600 mt-2">
            Real-time feed of the top 50 stories from Hacker News, updated every 3 minutes.
          </p>
        </header>

        <div class="bg-white rounded-lg shadow divide-y">
          <%= for story <- @stories do %>
            <article id={"story-#{story.id}"} class="p-4 hover:bg-orange-50 transition-colors">
              <div class="flex items-baseline space-x-2">
                <span class="text-orange-500 font-mono font-semibold">{story.rank}.</span>
                <h2 class="text-lg font-medium text-gray-900 flex-grow">
                  <a
                    href={story.url}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="hover:underline"
                  >
                    {story.title}
                  </a>
                </h2>
              </div>

              <div class="ml-6 mt-1 flex flex-wrap text-sm text-gray-500 gap-x-4">
                <%= if domain = format_domain(story.url) do %>
                  <span class="inline-flex items-center">
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-4 w-4 mr-1"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
                      />
                    </svg>
                    {domain}
                  </span>
                <% end %>

                <span class="inline-flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 mr-1"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"
                    />
                  </svg>
                  {story.by}
                </span>

                <span class="inline-flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 mr-1"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M7 11l5-5m0 0l5 5m-5-5v12"
                    />
                  </svg>
                  {story.score}
                </span>

                <span class="inline-flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 mr-1"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"
                    />
                  </svg>
                  {story.descendants}
                </span>

                <span class="inline-flex items-center">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 mr-1"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                  {format_time(story.time)}
                </span>

                <a
                  href={"https://news.ycombinator.com/item?id=#{story.id}"}
                  target="_blank"
                  rel="noopener noreferrer"
                  class="inline-flex items-center text-orange-600 hover:underline"
                >
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-4 w-4 mr-1"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"
                    />
                  </svg>
                  Comments
                </a>
              </div>
            </article>
          <% end %>

          <%= if Enum.empty?(@stories) do %>
            <div class="p-8 text-center">
              <p class="text-gray-500">Loading Hacker News stories...</p>
              <p class="text-sm text-gray-400 mt-2">
                This could take a moment to fetch data from the API.
              </p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
