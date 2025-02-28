defmodule Blog.Chat.Presence do
  @moduledoc """
  Tracks presence information for connected chat users.

  Uses Phoenix.Presence to maintain a real-time list of connected users
  and provides functions for tracking and querying user presence.
  """

  use Phoenix.Presence,
    otp_app: :blog,
    pubsub_server: Blog.PubSub

  alias Blog.Chat.Presence

  @presence_topic "allowed_chat:presence"

  @doc """
  Returns the topic used for presence tracking.
  """
  def topic, do: @presence_topic

  @doc """
  Tracks a user's presence when they connect to the chat.
  """
  def track_user(user_id) do
    Presence.track(
      self(),
      @presence_topic,
      user_id,
      %{
        online_at: DateTime.utc_now(),
        status: "online"
      }
    )
  end

  @doc """
  Gets the current count of online users.
  """
  def list_online_users do
    Presence.list(@presence_topic)
  end

  @doc """
  Returns the count of online users.
  """
  def count_online_users do
    @presence_topic
    |> Presence.list()
    |> map_size()
  end
end
