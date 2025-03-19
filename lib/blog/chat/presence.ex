defmodule Blog.Chat.Presence do
  @moduledoc """
  Tracks presence information for connected chat users.

  Uses Phoenix.Presence to maintain a real-time list of connected users
  and provides functions for tracking and querying user presence.
  """

  use Phoenix.Presence,
    otp_app: :blog,
    pubsub_server: Blog.PubSub

  @presence_topic "allowed_chat:presence"

  @doc """
  Returns the topic used for presence tracking.
  """
  def topic, do: @presence_topic

  @doc """
  Tracks a user's presence when they connect to the chat.
  """
  def track_user(user_id) do
    __MODULE__.track(
      self(),
      @presence_topic,
      user_id,
      %{
        online_at: DateTime.utc_now() |> DateTime.to_iso8601(),
        status: "online"
      }
    )
  end

  @doc """
  Gets the list of online users with their metadata.
  """
  def list_online_users do
    __MODULE__.list(@presence_topic)
  end

  @doc """
  Returns the count of online users.

  Safely handles the case where the presence tracker is not yet initialized.
  """
  def count_online_users do
    try do
      @presence_topic
      |> __MODULE__.list()
      |> map_size()
    rescue
      # Return 0 if the presence tracker is not initialized
      ArgumentError -> 0
    end
  end
end
