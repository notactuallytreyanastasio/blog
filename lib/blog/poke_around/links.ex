defmodule Blog.PokeAround.Links do
  @moduledoc """
  The Links context - manages stumble-able links.
  """

  import Ecto.Query
  alias Blog.Repo
  alias Blog.PokeAround.Link

  @doc """
  Store a new link from the extractor.

  Returns `{:ok, link}` or `{:error, changeset}`.
  If the link already exists (by URL hash), returns `{:ok, :exists}`.
  """
  def store_link(attrs) do
    url = attrs[:url] || attrs["url"]
    url_hash = Link.hash_url(url)
    domain = Link.extract_domain(url)

    attrs =
      attrs
      |> Map.put(:url_hash, url_hash)
      |> Map.put(:domain, domain)

    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
    |> case do
      {:ok, %Link{id: nil}} ->
        {:ok, :exists}

      {:ok, link} = result ->
        # Broadcast new link for live ingestion view
        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          "poke_around:links:new",
          {:new_link, link}
        )
        result

      error ->
        error
    end
  end

  @doc """
  Get a random link for stumbling.

  Options:
  - `:min_score` - minimum score (default: 0)
  - `:exclude_ids` - list of link IDs to exclude
  - `:domain` - filter by domain
  - `:tags` - filter by tags (any match)
  """
  def random_link(opts \\ []) do
    min_score = opts[:min_score] || 0
    exclude_ids = opts[:exclude_ids] || []

    query =
      from(l in Link,
        where: l.score >= ^min_score,
        order_by: fragment("RANDOM()"),
        limit: 1
      )

    query =
      if exclude_ids != [] do
        from(l in query, where: l.id not in ^exclude_ids)
      else
        query
      end

    query =
      case opts[:domain] do
        nil -> query
        domain -> from(l in query, where: l.domain == ^domain)
      end

    query =
      case opts[:tags] do
        nil -> query
        [] -> query
        tags -> from(l in query, where: fragment("? && ?", l.tags, ^tags))
      end

    Repo.one(query)
  end

  @doc """
  Get multiple random links.

  Options:
  - `:min_score` - minimum score (default: 0)
  - `:exclude_ids` - list of link IDs to exclude
  - `:langs` - filter by languages (any match)
  """
  def random_links(count, opts \\ []) do
    min_score = opts[:min_score] || 0
    exclude_ids = opts[:exclude_ids] || []
    langs = opts[:langs] || []

    query =
      from(l in Link,
        where: l.score >= ^min_score,
        order_by: fragment("RANDOM()"),
        limit: ^count
      )

    query =
      if exclude_ids != [] do
        from(l in query, where: l.id not in ^exclude_ids)
      else
        query
      end

    # Language filter - matches links containing ANY of the selected languages
    query =
      if langs != [] do
        from(l in query, where: fragment("? && ?", l.langs, ^langs))
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Increment the stumble count for a link.
  """
  def increment_stumble_count(link_id) do
    from(l in Link, where: l.id == ^link_id)
    |> Repo.update_all(inc: [stumble_count: 1])
  end

  @doc """
  Get a link by ID.
  """
  def get_link(id), do: Repo.get(Link, id)

  @doc """
  Get a link by URL.
  """
  def get_link_by_url(url) do
    url_hash = Link.hash_url(url)
    Repo.get_by(Link, url_hash: url_hash)
  end

  @doc """
  List links with pagination.
  """
  def list_links(opts \\ []) do
    page = opts[:page] || 1
    per_page = opts[:per_page] || 20
    offset = (page - 1) * per_page

    from(l in Link,
      order_by: [desc: l.inserted_at],
      limit: ^per_page,
      offset: ^offset
    )
    |> Repo.all()
  end

  @doc """
  Count total links.
  """
  def count_links do
    Repo.aggregate(Link, :count)
  end

  @doc """
  Get top domains by link count.
  """
  def top_domains(limit \\ 10) do
    from(l in Link,
      group_by: l.domain,
      select: {l.domain, count(l.id)},
      order_by: [desc: count(l.id)],
      limit: ^limit
    )
    |> Repo.all()
  end
end
