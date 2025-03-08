defmodule BlogWeb.Router do
  use BlogWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BlogWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug BlogWeb.Plugs.EnsureUserId
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BlogWeb do
    pipe_through :browser

    live "/", PostLive.Index
    live "/post/:slug", PostLive

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
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end

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
