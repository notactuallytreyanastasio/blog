defmodule BlogWeb.MuseumLive do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    apps = [
      %{
        title: "MTA Bus Tracker",
        description: "Real-time NYC MTA bus tracking with live updates",
        path: "/mta-bus",
        category: "Data Visualization",
        tags: ["Real-time", "NYC", "Transit"]
      },
      %{
        title: "MTA Bus Map",
        description: "Interactive map showing NYC bus routes and locations",
        path: "/mta-bus-map",
        category: "Maps",
        tags: ["Interactive", "Maps", "Transit"]
      },
      %{
        title: "Keylogger",
        description: "Tracks and visualizes your keystrokes in real-time",
        path: "/keylogger",
        category: "Analytics",
        tags: ["Tracking", "Visualization", "Real-time"]
      },
      %{
        title: "Gay Chaos",
        description: "Rainbow chaos generator with animated colors",
        path: "/gay_chaos",
        category: "Art",
        tags: ["Animation", "Colors", "Chaos"]
      },
      %{
        title: "Mirror",
        description: "A simple mirror application",
        path: "/mirror",
        category: "Utility",
        tags: ["Camera", "Mirror"]
      },
      %{
        title: "Reddit Links",
        description: "Curated Reddit links and discussions",
        path: "/reddit-links",
        category: "Social",
        tags: ["Reddit", "Links", "Social"]
      },
      %{
        title: "Cursor Tracker",
        description: "Tracks and visualizes mouse movement patterns",
        path: "/cursor-tracker",
        category: "Analytics",
        tags: ["Mouse", "Tracking", "Visualization"]
      },
      %{
        title: "Emoji Skeets",
        description: "BlueSky social media emoji timeline",
        path: "/emoji-skeets",
        category: "Social",
        tags: ["BlueSky", "Emoji", "Social"]
      },
      %{
        title: "Allowed Chats",
        description: "Chat moderation and allowlist management",
        path: "/allowed-chats",
        category: "Moderation",
        tags: ["Chat", "Moderation", "Admin"]
      },
      %{
        title: "Hacker News",
        description: "Hacker News reader with live updates",
        path: "/hacker-news",
        category: "News",
        tags: ["HN", "Tech News", "Reader"]
      },
      %{
        title: "Python Playground",
        description: "Interactive Python code execution environment",
        path: "/python-demo",
        category: "Development",
        tags: ["Python", "Code", "Interactive"]
      },
      %{
        title: "Wordle",
        description: "The classic word guessing game",
        path: "/wordle",
        category: "Games",
        tags: ["Word Game", "Puzzle", "Daily"]
      },
      %{
        title: "Wordle God Mode",
        description: "Wordle with unlimited plays and custom words",
        path: "/wordle_god",
        category: "Games",
        tags: ["Word Game", "Unlimited", "Custom"]
      },
      %{
        title: "Bookmarks",
        description: "Personal bookmark collection and manager",
        path: "/bookmarks",
        category: "Productivity",
        tags: ["Bookmarks", "Organization", "Personal"]
      },
      %{
        title: "Bookmarks Firehose",
        description: "Real-time stream of all bookmarks being added",
        path: "/bookmarks/firehose",
        category: "Productivity",
        tags: ["Real-time", "Stream", "Bookmarks"]
      },
      %{
        title: "Pong",
        description: "Classic Pong game with modern twist",
        path: "/pong",
        category: "Games",
        tags: ["Classic", "Arcade", "Multiplayer"]
      },
      %{
        title: "Pong God Mode",
        description: "Pong with enhanced features and god powers",
        path: "/pong/god",
        category: "Games",
        tags: ["Enhanced", "God Mode", "Arcade"]
      },
      %{
        title: "Generative Art",
        description: "Dynamic generative art with interactive elements",
        path: "/generative-art",
        category: "Art",
        tags: ["Generative", "Interactive", "Canvas"]
      },
      %{
        title: "Bezier Triangles",
        description: "Animated bezier curves creating triangle patterns",
        path: "/bezier-triangles",
        category: "Art",
        tags: ["Animation", "Math", "Triangles"]
      },
      %{
        title: "Blackjack",
        description: "Classic casino blackjack card game",
        path: "/blackjack",
        category: "Games",
        tags: ["Cards", "Casino", "Strategy"]
      },
      %{
        title: "War Card Game",
        description: "The simple card game of War",
        path: "/war",
        category: "Games",
        tags: ["Cards", "Simple", "Luck"]
      },
      %{
        title: "Skeet Timeline",
        description: "BlueSky social media timeline viewer",
        path: "/skeet-timeline",
        category: "Social",
        tags: ["BlueSky", "Timeline", "Social"]
      },
      %{
        title: "Markdown Editor",
        description: "Live markdown editor with real-time preview",
        path: "/markdown-editor",
        category: "Productivity",
        tags: ["Markdown", "Editor", "Preview"]
      },
      %{
        title: "Bubble Game",
        description: "Interactive bubble popping game",
        path: "/bubble-game",
        category: "Games",
        tags: ["Bubbles", "Interactive", "Casual"]
      },
      %{
        title: "Nathan Fielder Styles",
        description: "Various Nathan Fielder-inspired content presentations",
        path: "/nathan",
        category: "Comedy",
        tags: ["Nathan Fielder", "Parody", "Content"]
      },
      %{
        title: "Nathan Harpers Style",
        description: "Harper's Magazine style Nathan content",
        path: "/nathan_harpers",
        category: "Comedy",
        tags: ["Nathan Fielder", "Harpers", "Magazine"]
      },
      %{
        title: "Nathan Teen Vogue Style",
        description: "Teen Vogue style Nathan content",
        path: "/nathan_teen_vogue",
        category: "Comedy",
        tags: ["Nathan Fielder", "Teen Vogue", "Magazine"]
      },
      %{
        title: "Nathan BuzzFeed Style",
        description: "BuzzFeed style Nathan content",
        path: "/nathan_buzzfeed",
        category: "Comedy",
        tags: ["Nathan Fielder", "BuzzFeed", "Lists"]
      },
      %{
        title: "Nathan Usenet Style",
        description: "Usenet/forum style Nathan discussions",
        path: "/nathan_usenet",
        category: "Comedy",
        tags: ["Nathan Fielder", "Usenet", "Forum"]
      },
      %{
        title: "Nathan Content Farm",
        description: "Content farm style Nathan articles",
        path: "/nathan_content_farm",
        category: "Comedy",
        tags: ["Nathan Fielder", "Content Farm", "SEO"]
      },
      %{
        title: "Nathan Style Comparison",
        description: "Compare different Nathan content styles side by side",
        path: "/nathan_comparison",
        category: "Comedy",
        tags: ["Nathan Fielder", "Comparison", "Styles"]
      },
      %{
        title: "Nathan ASCII Art",
        description: "ASCII art representation of Nathan content",
        path: "/nathan_ascii",
        category: "Comedy",
        tags: ["Nathan Fielder", "ASCII", "Art"]
      }
    ]

    socket =
      socket
      |> assign(:apps, apps)
      |> assign(:selected_category, "All")
      |> assign(:selected_tag, nil)
      |> assign(:categories, get_categories(apps))

    {:ok, socket}
  end

  def handle_event("filter_category", %{"category" => category}, socket) do
    socket = 
      socket
      |> assign(:selected_category, category)
      |> assign(:selected_tag, nil)
    {:noreply, socket}
  end

  def handle_event("filter_tag", %{"tag" => tag}, socket) do
    socket = 
      socket
      |> assign(:selected_tag, tag)
      |> assign(:selected_category, "All")
    {:noreply, socket}
  end

  defp get_categories(apps) do
    ["All" | apps |> Enum.map(& &1.category) |> Enum.uniq() |> Enum.sort()]
  end

  defp filter_apps(apps, "All", nil), do: apps
  defp filter_apps(apps, category, nil), do: Enum.filter(apps, &(&1.category == category))
  defp filter_apps(apps, _category, tag), do: Enum.filter(apps, &(tag in &1.tags))

  def render(assigns) do
    ~H"""
    <div class="p-6">
      <h1 class="text-3xl font-bold mb-6">🏛️ Museum of Weird Apps</h1>

      <!-- Category Filter -->
      <div class="flex flex-wrap gap-2 mb-6">
        <%= for category <- @categories do %>
          <button
            phx-click="filter_category"
            phx-value-category={category}
            class={[
              "px-3 py-1 rounded text-sm",
              if(@selected_category == category,
                do: "bg-blue-600 text-white",
                else: "bg-gray-200 text-gray-700 hover:bg-gray-300"
              )
            ]}
          >
            {category}
          </button>
        <% end %>
      </div>

      <!-- Apps Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <%= for app <- filter_apps(@apps, @selected_category, @selected_tag) do %>
          <div class="border rounded-lg p-4 hover:shadow-lg transition-shadow">
            <div class="flex justify-between items-start mb-2">
              <h3 class="font-bold text-lg">{app.title}</h3>
              <span class="text-xs bg-blue-100 text-blue-800 px-2 py-1 rounded">{app.category}</span>
            </div>
            
            <p class="text-gray-600 text-sm mb-3">{app.description}</p>
            
            <div class="flex flex-wrap gap-1 mb-3">
              <%= for tag <- app.tags do %>
                <button
                  phx-click="filter_tag"
                  phx-value-tag={tag}
                  class={[
                    "text-xs px-2 py-1 rounded hover:bg-gray-200 transition-colors",
                    if(@selected_tag == tag,
                      do: "bg-green-200 text-green-800",
                      else: "bg-gray-100 text-gray-600"
                    )
                  ]}
                >
                  {tag}
                </button>
              <% end %>
            </div>
            
            <a
              href={app.path}
              class="inline-block w-full text-center bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition-colors"
            >
              Visit
            </a>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end