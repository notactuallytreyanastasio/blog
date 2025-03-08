defmodule Blog.RedditBookmarkProcessor do
  use GenServer
  alias Blog.Bookmarks.Store
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{count: 0}, name: __MODULE__)
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Blog.PubSub, "reddit_firehose")
    {:ok, state}
  end

  def handle_info({:reddit_link, {link, record}}, %{count: count} = state) do
    IO.puts("Received reddit link: #{link}")
    new_count = count + 1

    # if rem(new_count, 5) == 0 do
      create_bookmark_from_reddit_link(link, record)
      IO.inspect(record, label: "Record for post")
    # end

    {:noreply, %{state | count: new_count}}
  end

  defp create_bookmark_from_reddit_link(url, record) do
    tags = extract_subreddit(url)
    title = Map.get(record, "record", %{}) |> Map.get("embed", %{}) |> Map.get("external", %{}) |> Map.get("title", "Reddit")
    IO.inspect(title, label: "Title derived")
    bookmark = %{
      url: url,
      title: title || "Reddit: #{tags}",
      description: "Auto-generated bookmark from Reddit link",
      tags: [tags, "reddit"],
      user_id: "reddit_bot",
      favicon_url: "https://www.reddit.com/favicon.ico",
      inserted_at: DateTime.utc_now()
    }

    Store.add_bookmark(bookmark)
  end

  defp extract_subreddit(url) do
    case Regex.run(~r/reddit\.com\/r\/([^\/\?]+)/i, url) do
      [_, subreddit] -> "r/#{subreddit}"
      nil -> "reddit"
    end
  end
end
