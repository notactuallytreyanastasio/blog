defmodule Blog.PokeAround.Tags do
  @moduledoc """
  Context for managing tags and link-tag associations.
  """

  import Ecto.Query
  alias Blog.Repo
  alias Blog.PokeAround.{Tag, LinkTag, Link}

  @doc """
  Get or create a tag by name.
  """
  def get_or_create_tag(name) when is_binary(name) do
    slug = Tag.slugify(name)

    case Repo.get_by(Tag, slug: slug) do
      nil ->
        %Tag{}
        |> Tag.changeset(%{name: name, slug: slug})
        |> Repo.insert()

      tag ->
        {:ok, tag}
    end
  end

  @doc """
  Tag a link with multiple tags.

  Takes a link and a list of tag names, creates any missing tags,
  and associates them with the link.
  """
  def tag_link(link, tag_names, opts \\ []) when is_list(tag_names) do
    source = opts[:source] || "axon"
    confidence = opts[:confidence]

    result = Repo.transaction(fn ->
      tag_ids =
        tag_names
        |> Enum.map(&get_or_create_tag/1)
        |> Enum.filter(&match?({:ok, _}, &1))
        |> Enum.map(fn {:ok, tag} -> tag.id end)

      # Create link_tag associations
      now = DateTime.utc_now()

      link_tags =
        Enum.map(tag_ids, fn tag_id ->
          %{
            link_id: link.id,
            tag_id: tag_id,
            source: source,
            confidence: confidence,
            inserted_at: now,
            updated_at: now
          }
        end)

      # Insert all, ignoring conflicts (tag might already be associated)
      Repo.insert_all(LinkTag, link_tags, on_conflict: :nothing)

      # Update usage counts
      from(t in Tag, where: t.id in ^tag_ids)
      |> Repo.update_all(inc: [usage_count: 1])

      # Mark link as tagged
      from(l in Link, where: l.id == ^link.id)
      |> Repo.update_all(set: [tagged_at: now])

      :ok
    end)

    # Broadcast tagging result for live ingestion view
    case result do
      {:ok, :ok} ->
        Phoenix.PubSub.broadcast(
          Blog.PubSub,
          "poke_around:links:tagged",
          {:link_tagged, %{link_id: link.id, tags: tag_names, source: source}}
        )

      _ ->
        :ok
    end

    result
  end

  @doc """
  Get all tags for a link.
  """
  def get_tags_for_link(link_id) do
    from(t in Tag,
      join: lt in LinkTag,
      on: lt.tag_id == t.id,
      where: lt.link_id == ^link_id,
      select: t
    )
    |> Repo.all()
  end

  @doc """
  Get popular tags.
  """
  def popular_tags(limit \\ 20) do
    from(t in Tag,
      order_by: [desc: t.usage_count],
      limit: ^limit
    )
    |> Repo.all()
  end

  @doc """
  List all tags with filtering and sorting options.

  Options:
  - `:search` - Filter by name (case-insensitive substring match) [legacy]
  - `:sort` - :popular (default), :name_asc, :name_desc, :newest
  - `:sort_field` - :usage_count, :name, :inserted_at
  - `:sort_dir` - :asc, :desc
  - `:min_usage` - Minimum usage count (default: 0) [legacy]
  - `:rules` - List of filter rules (see apply_filter_rules/2)
  - `:match_mode` - :all (default) or :any for rule matching
  """
  def list_tags(opts \\ []) do
    # Support legacy options
    search = opts[:search]
    min_usage = opts[:min_usage] || 0

    # New sorting system
    {sort_field, sort_dir} = parse_sort_opts(opts)
    order_by = [{sort_dir, sort_field}]

    # Add secondary sort for stability
    order_by = if sort_field != :name, do: order_by ++ [asc: :name], else: order_by

    query = from(t in Tag, order_by: ^order_by)

    # Apply legacy min_usage
    query = if min_usage > 0 do
      from(t in query, where: t.usage_count >= ^min_usage)
    else
      query
    end

    # Apply legacy search
    query = if search && search != "" do
      search_term = "%#{String.downcase(search)}%"
      from(t in query, where: ilike(t.name, ^search_term))
    else
      query
    end

    # Apply new filter rules
    rules = opts[:rules] || []
    match_mode = opts[:match_mode] || :all

    query = apply_filter_rules(query, rules, match_mode)

    Repo.all(query)
  end

  defp parse_sort_opts(opts) do
    # Support both old :sort and new :sort_field/:sort_dir
    case opts[:sort] do
      :popular -> {:usage_count, :desc}
      :name_asc -> {:name, :asc}
      :name_desc -> {:name, :desc}
      :newest -> {:inserted_at, :desc}
      nil ->
        field = opts[:sort_field] || :usage_count
        dir = opts[:sort_dir] || :desc
        {field, dir}
      _ -> {:usage_count, :desc}
    end
  end

  @doc """
  Apply filter rules to a tag query.

  Each rule is a map with:
  - `:field` - :usage_count, :name, or :created
  - `:op` - operator (depends on field)
  - `:value` - the value to compare

  Usage count operators: :gte, :lte, :eq, :between
  Name operators: :contains, :starts_with, :ends_with, :equals
  Created operators: :last_n_days, :before, :after
  """
  def apply_filter_rules(query, [], _match_mode), do: query

  def apply_filter_rules(query, rules, :all) do
    Enum.reduce(rules, query, fn rule, q ->
      apply_single_rule(q, rule)
    end)
  end

  def apply_filter_rules(query, rules, :any) do
    # Build dynamic OR conditions
    conditions = Enum.map(rules, &build_rule_condition/1)
    |> Enum.filter(& &1)

    case conditions do
      [] -> query
      [first | rest] ->
        combined = Enum.reduce(rest, first, fn cond, acc ->
          dynamic([t], ^acc or ^cond)
        end)
        from(t in query, where: ^combined)
    end
  end

  defp apply_single_rule(query, %{field: :usage_count, op: op, value: value}) do
    case op do
      :gte -> from(t in query, where: t.usage_count >= ^value)
      :lte -> from(t in query, where: t.usage_count <= ^value)
      :eq -> from(t in query, where: t.usage_count == ^value)
      :between ->
        {min, max} = value
        from(t in query, where: t.usage_count >= ^min and t.usage_count <= ^max)
      _ -> query
    end
  end

  defp apply_single_rule(query, %{field: :name, op: op, value: value}) do
    case op do
      :contains ->
        pattern = "%#{String.downcase(value)}%"
        from(t in query, where: ilike(t.name, ^pattern))
      :starts_with ->
        pattern = "#{String.downcase(value)}%"
        from(t in query, where: ilike(t.name, ^pattern))
      :ends_with ->
        pattern = "%#{String.downcase(value)}"
        from(t in query, where: ilike(t.name, ^pattern))
      :equals ->
        from(t in query, where: fragment("lower(?)", t.name) == ^String.downcase(value))
      _ -> query
    end
  end

  defp apply_single_rule(query, %{field: :created, op: op, value: value}) do
    case op do
      :last_n_days ->
        cutoff = DateTime.utc_now() |> DateTime.add(-value * 24 * 60 * 60, :second)
        from(t in query, where: t.inserted_at >= ^cutoff)
      :before ->
        from(t in query, where: t.inserted_at < ^value)
      :after ->
        from(t in query, where: t.inserted_at > ^value)
      _ -> query
    end
  end

  defp apply_single_rule(query, _), do: query

  defp build_rule_condition(%{field: :usage_count, op: op, value: value}) do
    case op do
      :gte -> dynamic([t], t.usage_count >= ^value)
      :lte -> dynamic([t], t.usage_count <= ^value)
      :eq -> dynamic([t], t.usage_count == ^value)
      :between ->
        {min, max} = value
        dynamic([t], t.usage_count >= ^min and t.usage_count <= ^max)
      _ -> nil
    end
  end

  defp build_rule_condition(%{field: :name, op: op, value: value}) do
    case op do
      :contains ->
        pattern = "%#{String.downcase(value)}%"
        dynamic([t], ilike(t.name, ^pattern))
      :starts_with ->
        pattern = "#{String.downcase(value)}%"
        dynamic([t], ilike(t.name, ^pattern))
      :ends_with ->
        pattern = "%#{String.downcase(value)}"
        dynamic([t], ilike(t.name, ^pattern))
      :equals ->
        dynamic([t], fragment("lower(?)", t.name) == ^String.downcase(value))
      _ -> nil
    end
  end

  defp build_rule_condition(%{field: :created, op: op, value: value}) do
    case op do
      :last_n_days ->
        cutoff = DateTime.utc_now() |> DateTime.add(-value * 24 * 60 * 60, :second)
        dynamic([t], t.inserted_at >= ^cutoff)
      :before ->
        dynamic([t], t.inserted_at < ^value)
      :after ->
        dynamic([t], t.inserted_at > ^value)
      _ -> nil
    end
  end

  defp build_rule_condition(_), do: nil

  @doc """
  Count total tags.
  """
  def count_tags do
    Repo.aggregate(Tag, :count)
  end

  @doc """
  Get links by tag slug.

  Options:
  - `:limit` - Max links to return (default: 50)
  - `:order` - :newest (default) or :score
  - `:langs` - Filter by languages (empty list = all)
  """
  def links_by_tag(slug, opts \\ []) do
    limit = opts[:limit] || 50
    order = opts[:order] || :newest
    langs = opts[:langs] || []

    order_by = case order do
      :newest -> [desc: :inserted_at]
      :score -> [desc: :score]
    end

    query = from(l in Link,
      join: lt in LinkTag,
      on: lt.link_id == l.id,
      join: t in Tag,
      on: t.id == lt.tag_id,
      where: t.slug == ^slug,
      order_by: ^order_by,
      limit: ^limit
    )

    query = if langs != [] do
      from(l in query, where: fragment("? && ?", l.langs, ^langs))
    else
      query
    end

    Repo.all(query)
  end

  @doc """
  Get a tag by slug.
  """
  def get_tag_by_slug(slug) do
    Repo.get_by(Tag, slug: slug)
  end

  @doc """
  Get untagged links for processing.

  Options:
  - `:langs` - Filter by languages (default: ["en"] for English only)
  """
  def untagged_links(limit \\ 10, opts \\ []) do
    langs = opts[:langs] || ["en"]

    query = from(l in Link,
      where: is_nil(l.tagged_at),
      where: not is_nil(l.post_text),
      order_by: [desc: l.score],
      limit: ^limit
    )

    # Only filter by language if langs is non-empty
    query = if langs != [], do: from(l in query, where: fragment("? && ?", l.langs, ^langs)), else: query

    Repo.all(query)
  end

  @doc """
  Count untagged links.

  Options:
  - `:langs` - Filter by languages (default: ["en"] for English only)
  """
  def count_untagged(opts \\ []) do
    langs = opts[:langs] || ["en"]

    query = from(l in Link,
      where: is_nil(l.tagged_at),
      where: not is_nil(l.post_text)
    )

    # Only filter by language if langs is non-empty
    query = if langs != [], do: from(l in query, where: fragment("? && ?", l.langs, ^langs)), else: query

    Repo.aggregate(query, :count)
  end
end
