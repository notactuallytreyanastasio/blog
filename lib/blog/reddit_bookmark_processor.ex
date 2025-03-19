defmodule Blog.RedditBookmarkProcessor do
  use GenServer
  alias Blog.Bookmarks.{Store, Bookmark}
  require Logger

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{count: 0}, name: __MODULE__)
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Blog.PubSub, "reddit_firehose")
    {:ok, state}
  end

  def handle_info({:reddit_link, {link, record}}, %{count: count} = state) do
    new_count = count + 1
    create_bookmark_from_reddit_link(link, record)
    {:noreply, %{state | count: new_count}}
  end

  defp create_bookmark_from_reddit_link(url, record) do
    subreddit = extract_subreddit(url)

    title =
      Map.get(record, "record", %{})
      |> Map.get("embed", %{})
      |> Map.get("external", %{})
      |> Map.get("title", "Reddit")

    bookmark =
      Bookmark.new(%{
        url: url,
        title: title || "Reddit: #{subreddit}",
        description: "Auto-generated bookmark from Reddit link",
        tags: [subreddit],
        user_id: "reddit_bot",
        favicon_url: "https://www.reddit.com/favicon.ico"
      })

    case Store.add_bookmark(bookmark) do
      {:ok, bookmark} -> bookmark
      {:error, reason} -> Logger.error("Failed to create bookmark: #{reason}")
    end
  end

  defp extract_subreddit(url) when is_binary(url) do
    # Handle various Reddit URL formats
    cond do
      # Handle old.reddit.com URLs
      Regex.match?(~r{(?:old\.)?reddit\.com/r/([^/\s]+)}, url) ->
        [_, subreddit] = Regex.run(~r{(?:old\.)?reddit\.com/r/([^/\s]+)}, url)
        "r/#{String.downcase(subreddit)}"

      # Handle reddit.com URLs
      Regex.match?(~r{reddit\.com/r/([^/\s]+)}, url) ->
        [_, subreddit] = Regex.run(~r{reddit\.com/r/([^/\s]+)}, url)
        "r/#{String.downcase(subreddit)}"

      # Handle reddi.it short URLs by following them
      String.contains?(url, "redd.it") ->
        # For now just return reddit, we could follow the URL if needed
        "reddit"

      true ->
        "reddit"
    end
  end

  defp extract_subreddit(_), do: "reddit"
end
