defmodule Blog.Blinks.Comments do
  @moduledoc """
  Anonymous comments on blinks — the live "chat room" under each saved link.

  Posting is public but guarded (rate limits, honeypot + min-age token in the
  controller, link budget + blocklist in the changeset). Readers can report a
  comment; enough reports auto-hide it pending admin review. Every mutation is
  broadcast on `topic(blink_id)` so open rooms update live.
  """
  import Ecto.Query
  alias Blog.Blinks.{Comment, CommentReaction}
  alias Blog.Repo

  @auto_hide_reports 3
  @allowed_emojis ~w(❤️ 😂 🔥 👍 💀 👀)

  @spec allowed_emojis() :: [String.t()]
  def allowed_emojis, do: @allowed_emojis

  @spec topic(integer()) :: String.t()
  def topic(blink_id), do: "blink_comments:#{blink_id}"

  @spec list_comments(integer(), keyword()) :: [Comment.t()]
  def list_comments(blink_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 200)

    comments =
      Comment
      |> where([c], c.blink_id == ^blink_id and is_nil(c.hidden_at))
      |> order_by([c], asc: c.inserted_at, asc: c.id)
      |> limit(^limit)
      |> Repo.all()

    reactions = reactions_for(Enum.map(comments, & &1.id))
    Enum.map(comments, &%{&1 | reactions: Map.get(reactions, &1.id, %{})})
  end

  # ── reactions ────────────────────────────────────────────────────────────

  @spec reactions_for([integer()]) :: %{integer() => %{String.t() => non_neg_integer()}}
  def reactions_for([]), do: %{}

  def reactions_for(comment_ids) do
    CommentReaction
    |> where([r], r.comment_id in ^comment_ids)
    |> group_by([r], [r.comment_id, r.emoji])
    |> select([r], {r.comment_id, r.emoji, count(r.id)})
    |> Repo.all()
    |> Enum.reduce(%{}, fn {id, emoji, count}, acc ->
      Map.update(acc, id, %{emoji => count}, &Map.put(&1, emoji, count))
    end)
  end

  @spec react(integer(), String.t(), String.t()) ::
          {:ok, map()} | {:error, :not_found | :bad_emoji}
  def react(comment_id, emoji, device_hash) do
    toggle_reaction(comment_id, emoji, device_hash, :add)
  end

  @spec unreact(integer(), String.t(), String.t()) ::
          {:ok, map()} | {:error, :not_found | :bad_emoji}
  def unreact(comment_id, emoji, device_hash) do
    toggle_reaction(comment_id, emoji, device_hash, :remove)
  end

  defp toggle_reaction(comment_id, emoji, device_hash, op) do
    cond do
      emoji not in @allowed_emojis ->
        {:error, :bad_emoji}

      is_nil(get_comment(comment_id)) ->
        {:error, :not_found}

      true ->
        case op do
          :add ->
            now = NaiveDateTime.utc_now(:second)

            Repo.insert_all(
              CommentReaction,
              [
                %{
                  comment_id: comment_id,
                  emoji: emoji,
                  device_hash: device_hash,
                  inserted_at: now,
                  updated_at: now
                }
              ],
              on_conflict: :nothing,
              conflict_target: [:comment_id, :emoji, :device_hash]
            )

          :remove ->
            from(r in CommentReaction,
              where:
                r.comment_id == ^comment_id and r.emoji == ^emoji and
                  r.device_hash == ^device_hash
            )
            |> Repo.delete_all()
        end

        reactions = reactions_for([comment_id]) |> Map.get(comment_id, %{})
        comment = get_comment(comment_id)

        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          topic(comment.blink_id),
          {:reactions_updated, comment_id, reactions}
        )

        {:ok, reactions}
    end
  end

  @spec create_comment(map()) :: {:ok, Comment.t()} | {:error, Ecto.Changeset.t() | :duplicate}
  def create_comment(attrs) do
    if duplicate?(attrs) do
      {:error, :duplicate}
    else
      %Comment{}
      |> Comment.changeset(attrs)
      |> Repo.insert()
      |> tap_broadcast(:new_comment)
    end
  end

  # The same body on the same blink inside 10 minutes is a stuck retry or a bot.
  defp duplicate?(%{"blink_id" => blink_id, "content" => content})
       when is_integer(blink_id) and is_binary(content) do
    cutoff = NaiveDateTime.add(NaiveDateTime.utc_now(), -600)

    Comment
    |> where([c], c.blink_id == ^blink_id and c.content == ^String.trim(content))
    |> where([c], c.inserted_at > ^cutoff)
    |> Repo.exists?()
  end

  defp duplicate?(_), do: false

  @spec get_comment(integer()) :: Comment.t() | nil
  def get_comment(id), do: Repo.get(Comment, id)

  @doc "Reader flagged a comment. Auto-hides once enough distinct reports pile up."
  @spec report_comment(integer()) :: {:ok, Comment.t()} | {:error, :not_found}
  def report_comment(id) do
    case Repo.get(Comment, id) do
      nil ->
        {:error, :not_found}

      comment ->
        updates = [report_count: comment.report_count + 1]

        updates =
          if comment.report_count + 1 >= @auto_hide_reports and is_nil(comment.hidden_at),
            do: Keyword.put(updates, :hidden_at, NaiveDateTime.utc_now(:second)),
            else: updates

        {:ok, updated} = comment |> Ecto.Changeset.change(updates) |> Repo.update()

        if updated.hidden_at, do: broadcast(updated, :comment_hidden)
        {:ok, updated}
    end
  end

  @spec delete_comment(integer()) :: {:ok, Comment.t()} | {:error, :not_found}
  def delete_comment(id) do
    case Repo.get(Comment, id) do
      nil ->
        {:error, :not_found}

      comment ->
        {:ok, deleted} = Repo.delete(comment)
        broadcast(deleted, :comment_deleted)
        {:ok, deleted}
    end
  end

  defp tap_broadcast({:ok, comment} = result, event) do
    broadcast(comment, event)
    result
  end

  defp tap_broadcast(result, _event), do: result

  defp broadcast(%Comment{} = comment, event) do
    Phoenix.PubSub.broadcast(Blog.PubSub, topic(comment.blink_id), {event, comment})
  end
end
