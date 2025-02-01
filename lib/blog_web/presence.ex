defmodule BlogWeb.Presence do
  use Phoenix.Presence,
    otp_app: :blog,
    pubsub_server: Blog.PubSub
end
