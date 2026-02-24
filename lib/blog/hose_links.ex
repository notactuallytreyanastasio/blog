defmodule Blog.HoseLinks do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.HoseLinks.{Link, BreakthroughLink, URLNormalizer}

  require Logger

  @default_threshold 100
  @max_sample_urls 5
  @ttl_hours 2

  def record_link(normalized_url, raw_url) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    expires_at = DateTime.add(now, @ttl_hours, :hour)

    case Repo.insert(
           %Link{
             normalized_url: normalized_url,
             observations: 1,
             first_seen_at: now,
             last_seen_at: now,
             sample_raw_urls: [raw_url],
             expires_at: expires_at
           }
           |> Ecto.Changeset.change(),
           on_conflict: [
             set: [
               last_seen_at: now,
               updated_at: now
             ],
             inc: [observations: 1]
           ],
           conflict_target: :normalized_url,
           returning: true
         ) do
      {:ok, link} ->
        maybe_add_sample_url(link, raw_url)

        if link.observations >= current_threshold() do
          promote_to_breakthrough(link)
          :breakthrough
        else
          :ok
        end

      {:error, _changeset} ->
        :error
    end
  end

  def cleanup_expired do
    now = DateTime.utc_now()

    {count, _} =
      Link
      |> where([l], l.expires_at < ^now)
      |> Repo.delete_all()

    count
  end

  def promote_to_breakthrough(%Link{} = link) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)
    domain = URLNormalizer.extract_domain(link.normalized_url)

    on_conflict_query =
      from(b in BreakthroughLink,
        update: [
          set: [
            peak_observations:
              fragment("GREATEST(?, EXCLUDED.peak_observations)", b.peak_observations),
            updated_at: ^now
          ]
        ]
      )

    Repo.insert(
      %BreakthroughLink{
        normalized_url: link.normalized_url,
        observations_at_breakthrough: link.observations,
        peak_observations: link.observations,
        first_seen_at: link.first_seen_at,
        breakthrough_at: now,
        sample_raw_urls: link.sample_raw_urls,
        domain: domain
      }
      |> Ecto.Changeset.change(),
      on_conflict: on_conflict_query,
      conflict_target: :normalized_url
    )

    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      "hose_links:breakthrough",
      {:breakthrough, link.normalized_url, link.observations}
    )

    Logger.info("BREAKTHROUGH: #{link.normalized_url} (#{link.observations} observations)")
  end

  def list_breakthroughs(opts \\ []) do
    limit = opts[:limit] || 50

    BreakthroughLink
    |> order_by([b], desc: b.breakthrough_at)
    |> limit(^limit)
    |> Repo.all()
  end

  def top_links(limit \\ 20) do
    Link
    |> order_by([l], desc: l.observations)
    |> limit(^limit)
    |> Repo.all()
  end

  def stats do
    link_count = Repo.aggregate(Link, :count)
    breakthrough_count = Repo.aggregate(BreakthroughLink, :count)

    top =
      Link
      |> order_by([l], desc: l.observations)
      |> limit(5)
      |> select([l], %{url: l.normalized_url, observations: l.observations})
      |> Repo.all()

    %{
      active_links: link_count,
      total_breakthroughs: breakthrough_count,
      top_5: top
    }
  end

  def current_threshold do
    Application.get_env(:blog, :hose_links_threshold, @default_threshold)
  end

  defp maybe_add_sample_url(%Link{id: id, sample_raw_urls: samples}, raw_url) do
    if length(samples) < @max_sample_urls and raw_url not in samples do
      Link
      |> where([l], l.id == ^id)
      |> where(
        [l],
        fragment(
          "array_length(sample_raw_urls, 1) IS NULL OR array_length(sample_raw_urls, 1) < ?",
          ^@max_sample_urls
        )
      )
      |> Repo.update_all(push: [sample_raw_urls: raw_url])
    end
  end
end
