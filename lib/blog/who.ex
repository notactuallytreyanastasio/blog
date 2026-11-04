defmodule Blog.Who do
  @moduledoc """
  Read-only queries over the Doctor Who knowledge graph, exported from
  deciduous by the `danielle_who` explorer as `priv/who/graph-data.json`,
  plus the 384 TV stories scraped from the Tardis wiki in
  `priv/who/wiki-episodes.json`. Refresh both files from that repo's
  `public/data/` to pick up new passes.

  Two things about this graph that the other explorers' graphs do not share:

  * No node has a description. Every fact is in the title
    (`"Blink - Sally Sparrow, timey-wimey, Angels"`), so search and summaries
    work on titles alone.
  * Every edge is `leads_to`; the relation is the edge's `rationale`
    ("Story of", "Features companion", "Chronologically followed by", ...).
    `neighbors/1` returns the rationale as the edge's type for that reason.

  The 3.8 MB graph is decoded once and kept in `:persistent_term`. The
  other explorers re-read and re-decode their file on every call, which is
  fine at 1 MB and is not at 4 MB inside a tool loop that calls five times
  per answer.
  """

  @graph_key {__MODULE__, :graph}
  @episodes_key {__MODULE__, :episodes}

  @doctor_title ~r/^The (\w+) Doctor \((?<actor>[^,]+), (?<years>[^)]+)\)$/

  defp data_path(file), do: Application.app_dir(:blog, "priv/who/#{file}")

  @doc "The decoded graph: `%{nodes: [...], edges: [...], by_id: %{id => node}}`."
  def graph do
    case :persistent_term.get(@graph_key, nil) do
      nil ->
        d = data_path("graph-data.json") |> File.read!() |> Jason.decode!(keys: :atoms)

        g = %{
          nodes: d.nodes,
          edges: d.edges,
          by_id: Map.new(d.nodes, &{&1.id, &1}),
          out: Enum.group_by(d.edges, & &1.from_node_id),
          in: Enum.group_by(d.edges, & &1.to_node_id)
        }

        :persistent_term.put(@graph_key, g)
        g

      g ->
        g
    end
  end

  @doc "The TV stories from the wiki scrape, in story-number order."
  def episodes do
    case :persistent_term.get(@episodes_key, nil) do
      nil ->
        eps = data_path("wiki-episodes.json") |> File.read!() |> Jason.decode!(keys: :atoms)
        :persistent_term.put(@episodes_key, eps)
        eps

      eps ->
        eps
    end
  end

  def stats do
    g = graph()

    %{
      nodes: length(g.nodes),
      edges: length(g.edges),
      doctors: length(doctors()),
      stories: length(episodes()),
      decisions: Enum.count(g.nodes, &(&1.node_type == "decision"))
    }
  end

  @doc """
  The Doctor's incarnations, as the graph names them: one observation node
  each, titled `The Nth Doctor (Actor, years)`. The Fugitive Doctor's title
  says `pre-Hartnell` where the others give years, which the pattern allows.
  """
  def doctors do
    graph().nodes
    |> Enum.filter(&Regex.match?(@doctor_title, &1.title))
    |> Enum.sort_by(& &1.id)
    |> Enum.map(&doctor_summary/1)
  end

  defp doctor_summary(node) do
    %{"actor" => actor, "years" => years} = Regex.named_captures(@doctor_title, node.title)
    [_, ordinal] = Regex.run(~r/^The (\w+) Doctor/, node.title)
    %{id: node.id, ordinal: ordinal, title: node.title, actor: actor, years: years}
  end

  @doc "Find a Doctor by ordinal word (\"Tenth\"), number (10) or actor surname."
  def doctor(ref) when is_integer(ref) do
    Enum.find(doctors(), &(ordinal_number(&1.ordinal) == ref))
  end

  def doctor(ref) when is_binary(ref) do
    q = String.downcase(String.trim(ref))

    case Integer.parse(q) do
      {n, ""} ->
        doctor(n)

      _ ->
        Enum.find(doctors(), fn d ->
          String.downcase(d.ordinal) == q or
            String.contains?(String.downcase(d.actor), q) or
            String.contains?(String.downcase(d.title), q)
        end)
    end
  end

  def doctor(_), do: nil

  @ordinals ~w(first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth fourteenth fifteenth)

  defp ordinal_number(word) do
    case Enum.find_index(@ordinals, &(&1 == String.downcase(word))) do
      nil -> nil
      i -> i + 1
    end
  end

  @doc "The era goals the graph hangs off: Classic, Wilderness, Time War, New Who, spinoffs."
  def eras do
    g = graph()

    g.nodes
    |> Enum.filter(&(&1.node_type == "goal" and &1.id in 2..6))
    |> Enum.map(fn n ->
      %{id: n.id, title: n.title, size: length(Map.get(g.out, n.id, []))}
    end)
  end

  def get_node(id) when is_integer(id), do: Map.get(graph().by_id, id)

  def get_node(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> get_node(int)
      :error -> nil
    end
  end

  def get_node(_), do: nil

  @doc """
  Token-scored search over node titles: the query is split into words and
  nodes are ranked by how many appear, since a model rarely quotes a title
  exactly. Words shorter than three letters are ignored, which drops "the"
  and "of" but also "ood"; a two-letter search finds nothing.
  """
  def search_nodes(query, opts \\ []) do
    terms = terms(query)
    node_type = opts[:node_type]

    graph().nodes
    |> Enum.filter(fn n -> is_nil(node_type) or node_type == "" or n.node_type == node_type end)
    |> Enum.map(fn n ->
      text = String.downcase(n.title)
      {n, Enum.count(terms, &String.contains?(text, &1))}
    end)
    |> Enum.filter(fn {_n, score} -> score > 0 end)
    |> Enum.sort_by(fn {n, score} -> {-score, n.id} end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.take(opts[:limit] || 20)
  end

  defp terms(query) do
    (query || "")
    |> String.downcase()
    |> String.split(~r/[^a-z0-9']+/, trim: true)
    |> Enum.reject(&(String.length(&1) < 3))
  end

  @doc """
  Edges in and out of a node, each with the related node's title and the
  rationale as `relation` (the graph's only edge_type is `leads_to`).
  """
  def neighbors(id) do
    g = graph()
    id = if is_binary(id), do: String.to_integer(id), else: id

    %{
      outgoing:
        g.out
        |> Map.get(id, [])
        |> Enum.map(&edge_summary(g, &1, &1.to_node_id)),
      incoming:
        g.in
        |> Map.get(id, [])
        |> Enum.map(&edge_summary(g, &1, &1.from_node_id))
    }
  end

  defp edge_summary(g, edge, other_id) do
    other = Map.get(g.by_id, other_id)

    %{
      relation: edge.rationale,
      id: other_id,
      title: other && other.title,
      type: other && other.node_type
    }
  end

  @doc """
  Stories filed under a Doctor: every node with an edge into the Doctor's
  node whose rationale says it is a story ("Story of", "Doctor", "Debut
  story"...). Companions, enemies and the era goal also point at the Doctor,
  so those relations are left out.
  """
  @story_relations ~w(Story\ of Doctor Doctor\ born Doctor\ dies Debut\ story Story episode)

  def stories_of(doctor_id) when is_integer(doctor_id) do
    g = graph()

    g.in
    |> Map.get(doctor_id, [])
    |> Enum.filter(&(&1.rationale in @story_relations))
    |> Enum.map(&Map.get(g.by_id, &1.from_node_id))
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.id)
  end

  @doc """
  Walk "Followed by" / "Chronologically followed by" edges from a node, in
  either direction, up to `limit` steps. The two relations are different
  orders (broadcast and in-universe) and are walked separately.
  """
  def chain(id, direction \\ :forward, limit \\ 12) do
    g = graph()
    id = if is_binary(id), do: String.to_integer(id), else: id
    walk(g, id, direction, limit, [id])
  end

  @sequence_relations ["Followed by", "Chronologically followed by"]

  defp walk(_g, _id, _dir, 0, seen), do: seen |> Enum.reverse() |> Enum.map(&get_node/1)

  defp walk(g, id, dir, n, seen) do
    edges = if dir == :forward, do: Map.get(g.out, id, []), else: Map.get(g.in, id, [])

    next =
      edges
      |> Enum.filter(&(&1.rationale in @sequence_relations))
      |> Enum.map(&if(dir == :forward, do: &1.to_node_id, else: &1.from_node_id))
      |> Enum.reject(&(&1 in seen))
      |> List.first()

    case next do
      nil -> walk(g, id, dir, 0, seen)
      next_id -> walk(g, next_id, dir, n - 1, [next_id | seen])
    end
  end

  @doc """
  The in-universe decision graph: every `decision` node with the options it
  chose between and the outcomes and actions downstream of it.
  """
  def decisions do
    g = graph()

    g.nodes
    |> Enum.filter(&(&1.node_type == "decision"))
    |> Enum.map(fn d ->
      downstream =
        g.out |> Map.get(d.id, []) |> Enum.map(&Map.get(g.by_id, &1.to_node_id)) |> Enum.reject(&is_nil/1)

      upstream =
        g.in |> Map.get(d.id, []) |> Enum.map(&Map.get(g.by_id, &1.from_node_id)) |> Enum.reject(&is_nil/1)

      %{
        id: d.id,
        title: d.title,
        options: Enum.filter(upstream ++ downstream, &(&1.node_type == "option")) |> Enum.map(& &1.title),
        actions: Enum.filter(downstream, &(&1.node_type == "action")) |> Enum.map(& &1.title),
        outcomes: Enum.filter(downstream, &(&1.node_type == "outcome")) |> Enum.map(& &1.title),
        about: Enum.filter(upstream, &(&1.node_type == "observation")) |> Enum.map(& &1.title)
      }
    end)
  end

  @doc "One TV story from the wiki scrape, by title (case-insensitive, prefix-tolerant)."
  def episode(title) when is_binary(title) do
    q = String.downcase(String.trim(title))

    Enum.find(episodes(), &(String.downcase(&1.title) == q)) ||
      Enum.find(episodes(), &String.starts_with?(String.downcase(&1.title), q))
  end

  def episode(_), do: nil

  @doc """
  Word-scored search over the wiki stories: title, companions, enemies,
  writer, director, setting and synopsis.
  """
  def search_episodes(query, opts \\ []) do
    terms = terms(query)

    episodes()
    |> Enum.map(fn e ->
      text =
        [e.title, e.doctor, e.writer, e.director, e.setting_location, e.synopsis | e.companions ++ e.enemies]
        |> Enum.reject(&is_nil/1)
        |> Enum.join(" ")
        |> String.downcase()

      {e, Enum.count(terms, &String.contains?(text, &1))}
    end)
    |> Enum.filter(fn {_e, score} -> score > 0 end)
    |> Enum.sort_by(fn {e, score} -> {-score, e.story_number} end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.take(opts[:limit] || 12)
  end

  @doc "The wiki fields worth handing to a model, without the 1 KB synopsis blob unless asked."
  def episode_summary(e, opts \\ []) do
    base = %{
      title: e.title,
      story_number: e.story_number,
      doctor: e.doctor,
      aired: e.air_date_start,
      episodes: e.episode_count,
      companions: e.companions,
      enemies: e.enemies,
      writer: e.writer,
      director: e.director,
      setting: e.setting_location,
      missing_status: e.missing_status
    }

    if opts[:full], do: Map.put(base, :synopsis, e.synopsis), else: base
  end

  def to_summary(node) do
    %{id: node.id, type: node.node_type, title: node.title}
  end
end
