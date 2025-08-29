defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BlogWeb.Plugs.RemoteIp
    plug BlogWeb.Plugs.EnsureUserId
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlogWeb do
    pipe_through :browser

    live "/", PostLive.Index
    live "/post/:slug", PostLive
    live "/museum", MuseumLive, :index
    live "/mta-bus", MtaBusLive, :index
    live "/mta-bus-map", MtaBusMapLive, :index
    live "/mta-train", MtaTrainLive, :index

    live "/keylogger", KeyloggerLive
    live "/gay_chaos", RainbowLive, :index
    live "/mirror", MirrorLive, :index
    live "/reddit-links", RedditLinksLive, :index
    live "/cursor-tracker", CursorTrackerLive, :index
    live "/emoji-skeets", EmojiSkeetsLive, :index
    live "/allowed-chats", AllowedChatsLive, :index
    live "/hacker-news", HackerNewsLive, :index
    live "/python", PythonLive.Index, :index
    live "/python-demo", PythonDemoLive, :index
    live "/wordle", WordleLive, :index
    live "/wordle_god", WordleGodLive, :index
    live "/bookmarks", BookmarksLive, :index
    live "/bookmarks/firehose", BookmarksFirehoseLive, :index
    live "/pong", PongLive, :index
    live "/pong/god", PongGodLive, :index
    live "/chaos-typing", ChaosTypingLive, :index
    live "/generative-art", GenerativeArtLive, :index
    live "/bezier-triangles", BezierTrianglesLive, :index
    # live "/breakout", BreakoutLive, :index
    live "/blackjack", BlackjackLive, :index
    live "/war", WarLive, :index
    live "/skeet-timeline", SkeetTimelineLive, :index
    live "/markdown-editor", MarkdownEditorLive, :index
    live "/lumon-celebration", LumonCelebrationLive, :index
    live "/bubble-game", BubbleGameLive
    live "/article/my-custom-article", ArticleLive, :show
    live "/untitled-ai-dev-blogpost", AiDevLive, :index
    live "/nathan", NathanLive, :index
    live "/nathan_harpers", NathanHarpersLive, :index
    live "/nathan_teen_vogue", NathanTeenVogueLive, :index
    live "/nathan_buzzfeed", NathanBuzzfeedLive, :index
    live "/nathan_usenet", NathanUsenetLive, :index
    live "/nathan_content_farm", NathanContentFarmLive, :index
    live "/nathan_comparison", NathanComparisonLive, :index
    live "/nathan_ascii", NathanAsciiLive, :index
    live "/trees", TreesLive, :index
    live "/learn", LessonReplLive, :index
    live "/map", MapLive
    live "/very_direct_message", ReceiptMessageLive, :index
    live "/jetstream_comparison", JetstreamComparisonLive, :index
  end

  # API endpoints for receipt printer
  scope "/api", BlogWeb.Api do
    pipe_through :api
    
    get "/receipt_messages/pending", ReceiptMessageController, :pending
    post "/receipt_messages/:id/printed", ReceiptMessageController, :mark_printed
    post "/receipt_messages/:id/failed", ReceiptMessageController, :mark_failed
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BlogWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
