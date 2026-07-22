defmodule Blog.Blinks do
  @moduledoc """
  Saved links ("blinks") captured from the Safari extension, with tags.
  """

  import Ecto.Query
  alias Blog.Blinks.{Blink, Enricher}
  alias Blog.Repo

  @topic "blinks"

  @spec topic() :: String.t()
  def topic, do: @topic

  @doc "Announce a saved/updated blink to live /blinks viewers."
  @spec broadcast(Blink.t(), atom()) :: :ok
  def broadcast(%Blink{} = blink, event) do
    Phoenix.PubSub.broadcast(Blog.PubSub, @topic, {event, blink})
  end

  @doc """
  Saves a link. If the URL was already saved, merges the new tags into the
  existing record and refreshes the title/description (new values win when
  present).
  """
  @spec save_blink(map()) :: {:ok, Blink.t()} | {:error, Ecto.Changeset.t()}
  def save_blink(attrs) do
    changeset = Blink.changeset(%Blink{}, attrs)

    result =
      case Repo.get_by(Blink, url: Ecto.Changeset.get_field(changeset, :url) || "") do
        nil ->
          Repo.insert(changeset)

        %Blink{} = existing ->
          new_tags = Ecto.Changeset.get_field(changeset, :tags) || []
          new_quotes = Ecto.Changeset.get_field(changeset, :quotes) || []
          new_description = Ecto.Changeset.get_field(changeset, :description)

          existing
          |> Blink.changeset(%{
            title: attrs[:title] || attrs["title"] || existing.title,
            description: presence(new_description) || existing.description,
            tags: Enum.uniq(existing.tags ++ new_tags),
            quotes: Enum.uniq(existing.quotes ++ new_quotes)
          })
          |> Repo.update()
      end

    with {:ok, blink} <- result do
      broadcast(blink, :blink_saved)
      Enricher.enrich_async(blink)
    end

    result
  end

  @spec get_by_url(String.t()) :: Blink.t() | nil
  def get_by_url(url) when is_binary(url) and url != "", do: Repo.get_by(Blink, url: url)
  def get_by_url(_), do: nil

  @spec get_blink(integer() | String.t()) :: Blink.t() | nil
  def get_blink(id), do: Repo.get(Blink, id)

  @doc """
  Ranks other blinks by similarity to the given one: shared tags + trigram
  title similarity, all in Postgres.
  """
  @spec list_similar(Blink.t(), non_neg_integer()) :: [Blink.t()]
  def list_similar(%Blink{} = blink, limit \\ 10) do
    %{rows: rows} =
      Repo.query!(
        """
        SELECT id FROM blinks
        WHERE id != $1
        ORDER BY
          (SELECT count(*) FROM unnest(tags) t WHERE t = ANY($2)) * 2
            + similarity(coalesce(title, ''), $3) DESC,
          inserted_at DESC
        LIMIT $4
        """,
        [blink.id, blink.tags, blink.title || "", limit]
      )

    ids = List.flatten(rows)
    blinks = Blink |> where([b], b.id in ^ids) |> Repo.all() |> Map.new(&{&1.id, &1})
    ids |> Enum.map(&blinks[&1]) |> Enum.reject(&is_nil/1)
  end

  @doc """
  Lists blinks, newest first.

  Options:
    * `:tags` — list of tags; blinks carrying ANY of them are returned (union)
    * `:query` — full-text search (title/description/tags/url) with an
      ilike fallback for partial words
    * `:limit` — defaults to 100
  """
  @spec list_blinks(keyword()) :: [Blink.t()]
  def list_blinks(opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    offset = Keyword.get(opts, :offset, 0)
    query = Keyword.get(opts, :query)
    tags = Keyword.get(opts, :tags) || []
    exclude = Keyword.get(opts, :exclude_tags) || []

    Blink
    |> order_by(desc: :inserted_at, desc: :id)
    |> limit(^limit)
    |> offset(^offset)
    |> maybe_search(query)
    |> maybe_filter_tags(tags)
    |> maybe_exclude_tags(exclude)
    |> Repo.all()
  end

  # With embeddings enabled, append semantically-close blinks that keyword
  # search missed (still respecting any tag filter).
  defp maybe_exclude_tags(queryable, []), do: queryable

  defp maybe_exclude_tags(queryable, tags) do
    where(queryable, [b], fragment("NOT (? && ?)", b.tags, ^tags))
  end

  @doc """
  Returns tags with counts, most used first. When `selected` is non-empty,
  counts only tags co-occurring on blinks that carry ALL selected tags —
  so a tag cloud narrows as you click tags together.
  """
  @spec list_tags([String.t()], [String.t()]) :: [%{name: String.t(), count: non_neg_integer()}]
  def list_tags(selected \\ [], exclude \\ []) do
    %{rows: rows} =
      Repo.query!(
        """
        SELECT t.name, count(*)
        FROM blinks b CROSS JOIN LATERAL unnest(b.tags) AS t(name)
        WHERE b.tags @> $1 AND NOT (b.tags && $2)
        GROUP BY t.name
        ORDER BY count(*) DESC, t.name ASC
        """,
        [selected, exclude]
      )

    Enum.map(rows, fn [name, count] -> %{name: name, count: count} end)
  end

  @spec count_blinks() :: non_neg_integer()
  def count_blinks, do: Repo.aggregate(Blink, :count)

  @spec random_blink() :: Blink.t() | nil
  def random_blink do
    Blink |> order_by(fragment("random()")) |> limit(1) |> Repo.one()
  end

  @doc "Deletes a blink and its chat room's messages. Broadcasts :blink_deleted."
  @spec delete_blink(integer()) :: {:ok, Blink.t()} | {:error, :not_found}
  def delete_blink(id) do
    case Repo.get(Blink, id) do
      nil ->
        {:error, :not_found}

      %Blink{} = blink ->
        {:ok, _} = Repo.delete(blink)

        from(m in Blog.Chat.Message, where: m.room == ^"blink:#{blink.id}")
        |> Repo.delete_all()

        broadcast(blink, :blink_deleted)
        {:ok, blink}
    end
  end

  # ── bookmark review queue ────────────────────────────────────────────────

  alias Blog.Blinks.BookmarkCandidate

  @doc "Bulk-import bookmark candidates; skips urls already saved or queued."
  @spec import_candidates([map()]) :: non_neg_integer()
  def import_candidates(entries) do
    existing = Blink |> select([b], b.url) |> Repo.all() |> MapSet.new()
    now = NaiveDateTime.utc_now(:second)

    rows =
      entries
      |> Enum.filter(fn e ->
        is_binary(e["url"]) and String.starts_with?(e["url"], "http") and
          not MapSet.member?(existing, e["url"])
      end)
      |> Enum.map(fn e ->
        %{
          url: String.slice(e["url"], 0, 4096),
          title: e["title"] && String.slice(e["title"], 0, 1000),
          folder: e["folder"] && String.slice(e["folder"], 0, 200),
          status: "pending",
          inserted_at: now,
          updated_at: now
        }
      end)

    {count, _} =
      Repo.insert_all(BookmarkCandidate, rows, on_conflict: :nothing, conflict_target: :url)

    count
  end

  @spec pending_candidates() :: [BookmarkCandidate.t()]
  def pending_candidates do
    BookmarkCandidate
    |> where([c], c.status == "pending")
    |> order_by([c], asc: c.folder, asc: c.id)
    |> Repo.all()
  end

  @spec candidate_counts() :: %{String.t() => non_neg_integer()}
  def candidate_counts do
    BookmarkCandidate
    |> group_by([c], c.status)
    |> select([c], {c.status, count(c.id)})
    |> Repo.all()
    |> Map.new()
  end

  @doc "Upvote = becomes a blink (tagged bookmarks + its folder); downvote = dismissed."
  @spec review_candidate(integer(), :add | :dismiss) ::
          {:ok, BookmarkCandidate.t()} | {:error, term()}
  def review_candidate(id, verdict) do
    case Repo.get(BookmarkCandidate, id) do
      nil ->
        {:error, :not_found}

      %BookmarkCandidate{} = candidate ->
        with :add <- verdict,
             {:ok, _blink} <-
               save_blink(%{
                 "url" => candidate.url,
                 "title" => candidate.title,
                 "tags" => ["bookmarks" | folder_tag(candidate.folder)]
               }) do
          candidate |> Ecto.Changeset.change(status: "added") |> Repo.update()
        else
          :dismiss ->
            candidate |> Ecto.Changeset.change(status: "dismissed") |> Repo.update()

          {:error, reason} ->
            {:error, reason}
        end
    end
  end

  defp folder_tag(nil), do: []
  defp folder_tag("Favorites"), do: []

  defp folder_tag(folder) do
    tag =
      folder
      |> String.split("/")
      |> List.last()
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "-")
      |> String.trim("-")

    if tag == "", do: [], else: [tag]
  end

  # Always considered ultra nerdy stuff, no matter what the editable list says.
  @base_dork_tags ~w(code programming ai ml programming-languages tech-commentary)

  @doc """
  The ultra-nerdy-stuff list: tags excluded from /blinks when the hide button
  is on. A baseline set is always included; editable extras live in the
  blink_settings KV table.
  """
  @spec dork_tags() :: [String.t()]
  def dork_tags do
    stored =
      case Repo.query!("SELECT value FROM blink_settings WHERE key = 'dork_tags'").rows do
        [[tags]] -> tags
        [] -> []
      end

    Enum.uniq(@base_dork_tags ++ stored)
  end

  @spec set_dork_tags([String.t()]) :: :ok
  def set_dork_tags(tags) do
    tags =
      tags
      |> Enum.map(&(&1 |> String.trim() |> String.downcase()))
      |> Enum.reject(&(&1 == ""))
      |> Enum.uniq()

    Repo.query!(
      """
      INSERT INTO blink_settings (key, value, inserted_at, updated_at)
      VALUES ('dork_tags', $1, now(), now())
      ON CONFLICT (key) DO UPDATE SET value = $1, updated_at = now()
      """,
      [tags]
    )

    :ok
  end

  defp maybe_search(queryable, nil), do: queryable
  defp maybe_search(queryable, ""), do: queryable

  defp maybe_search(queryable, query) do
    pattern = "%#{query}%"

    where(
      queryable,
      [b],
      fragment("search_vector @@ websearch_to_tsquery('english', ?)", ^query) or
        ilike(b.title, ^pattern) or
        ilike(b.description, ^pattern) or
        ilike(b.url, ^pattern) or
        fragment("EXISTS (SELECT 1 FROM unnest(tags) tg WHERE tg ILIKE ?)", ^pattern)
    )
  end

  defp maybe_filter_tags(queryable, []), do: queryable

  defp maybe_filter_tags(queryable, tags) do
    where(queryable, [b], fragment("? && ?", b.tags, ^tags))
  end

  defp presence(nil), do: nil
  defp presence(""), do: nil
  defp presence(s), do: s
end
