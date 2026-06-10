defmodule Blog.Chat do
  @moduledoc """
  Context module for chat functionality with Postgres persistence.
  """
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Chat.{Chatter, Message}

  @pubsub_topic "terminal_chat"

  @spec topic() :: String.t()
  def topic, do: @pubsub_topic

  # ============================================================================
  # Chatter Functions
  # ============================================================================

  @doc """
  Find an existing chatter by IP hash, or create a new one.

  Sticky screenname logic:
  1. Look for existing chatter with this IP hash
  2. If found, optionally update their screen_name if they want to change it
  3. If screen_name is taken by different IP, append number suffix
  4. Create new chatter if none exists for this IP
  """
  @spec find_or_create_chatter(String.t(), String.t() | nil) ::
          {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def find_or_create_chatter(screen_name, ip_address) do
    ip_hash = hash_ip(ip_address)
    screen_name = String.trim(screen_name)

    case get_chatter_by_ip(ip_hash) do
      nil ->
        # New visitor - create chatter with unique screen_name
        create_chatter_with_unique_name(screen_name, ip_hash)

      existing_chatter ->
        # Returning visitor - update name if they changed it
        if existing_chatter.screen_name == screen_name do
          {:ok, existing_chatter}
        else
          update_chatter_name(existing_chatter, screen_name)
        end
    end
  end

  @doc "Get a chatter by their IP hash (for returning visitor detection)"
  @spec get_chatter_by_ip(String.t() | nil) :: struct() | nil
  def get_chatter_by_ip(ip_hash) do
    Repo.get_by(Chatter, ip_hash: ip_hash)
  end

  @doc "Get a chatter by screen name"
  @spec get_chatter_by_name(String.t()) :: struct() | nil
  def get_chatter_by_name(screen_name) do
    Repo.get_by(Chatter, screen_name: screen_name)
  end

  defp create_chatter_with_unique_name(screen_name, ip_hash) do
    unique_name = ensure_unique_name(screen_name)

    %Chatter{}
    |> Chatter.changeset(%{
      screen_name: unique_name,
      ip_hash: ip_hash,
      color: Chatter.random_color()
    })
    |> Repo.insert()
  end

  defp update_chatter_name(chatter, new_name) do
    unique_name = ensure_unique_name(new_name, chatter.id)

    chatter
    |> Chatter.changeset(%{screen_name: unique_name})
    |> Repo.update()
  end

  defp ensure_unique_name(name, exclude_id \\ nil) do
    query = from(c in Chatter, where: c.screen_name == ^name)
    query = if exclude_id, do: where(query, [c], c.id != ^exclude_id), else: query

    if Repo.exists?(query) do
      find_available_name(name, 2, exclude_id)
    else
      name
    end
  end

  defp find_available_name(base_name, suffix, exclude_id) do
    candidate = "#{base_name}#{suffix}"
    query = from(c in Chatter, where: c.screen_name == ^candidate)
    query = if exclude_id, do: where(query, [c], c.id != ^exclude_id), else: query

    if Repo.exists?(query) do
      find_available_name(base_name, suffix + 1, exclude_id)
    else
      candidate
    end
  end

  @doc "Hash an IP address for privacy (SHA256)"
  @spec hash_ip(term()) :: String.t() | nil
  def hash_ip(ip_address) when is_binary(ip_address) do
    :crypto.hash(:sha256, ip_address)
    |> Base.encode16(case: :lower)
    # Just use first 16 chars
    |> String.slice(0, 16)
  end

  def hash_ip(_), do: nil

  # ============================================================================
  # Message Functions
  # ============================================================================

  @doc "List recent messages for a room with preloaded chatters"
  @spec list_messages(String.t(), non_neg_integer()) :: [struct()]
  def list_messages(room \\ "terminal", limit \\ 50) do
    Message
    |> where([m], m.room == ^room)
    |> order_by([m], desc: m.inserted_at, desc: m.id)
    |> limit(^limit)
    |> preload(:chatter)
    |> Repo.all()
    |> Enum.reverse()
  end

  @doc "Create a new message and broadcast it"
  @spec create_message(struct(), String.t(), String.t()) ::
          {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create_message(%Chatter{} = chatter, content, room \\ "terminal") do
    attrs = %{
      content: String.trim(content),
      room: room,
      chatter_id: chatter.id
    }

    case %Message{} |> Message.changeset(attrs) |> Repo.insert() do
      {:ok, message} ->
        message = Repo.preload(message, :chatter)
        broadcast_message(message)
        {:ok, message}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp broadcast_message(message) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @pubsub_topic, {:new_chat_message, message})
  end

  # ============================================================================
  # Presence Support
  # ============================================================================

  @doc "Get online chatters (for buddy list display)"
  @spec list_online_chatters(map()) :: [map()]
  def list_online_chatters(presence_list) do
    presence_list
    |> Enum.map(fn {_id, %{metas: [meta | _]}} -> meta end)
  end

  # ============================================================================
  # Backwards Compatibility (for post_live/index.ex using old API)
  # ============================================================================

  @doc "Backwards compatibility - no-op, Postgres doesn't need ETS initialization"
  @spec ensure_started() :: :ok
  def ensure_started, do: :ok

  @doc "Backwards compatibility - alias for list_messages"
  @spec get_messages(String.t()) :: [struct()]
  def get_messages(room), do: list_messages(room)

  @doc "Backwards compatibility - banned words stub (not implemented in Postgres version)"
  @spec add_banned_word(term()) :: {:ok, String.t()}
  def add_banned_word(_word), do: {:ok, ""}

  @doc "Backwards compatibility - banned words check stub"
  @spec check_for_banned_words(term()) :: {:ok, term()}
  def check_for_banned_words(message), do: {:ok, message}

  @doc "Backwards compatibility - save message from old format"
  @spec save_message(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def save_message(%{sender_name: name, sender_color: color, content: content, room: room}) do
    # For backwards compat, create an anonymous chatter if needed
    {:ok, chatter} = find_or_create_anonymous_chatter(name, color)
    create_message(chatter, content, room)
  end

  defp find_or_create_anonymous_chatter(name, color) do
    case Repo.get_by(Chatter, screen_name: name) do
      nil ->
        %Chatter{}
        |> Chatter.changeset(%{screen_name: name, color: color})
        |> Repo.insert()

      chatter ->
        {:ok, chatter}
    end
  end
end
