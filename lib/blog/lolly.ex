defmodule Blog.Lolly do
  @moduledoc """
  Read-only query interface over the "Say It With Pictures" course decision
  graph, exported from deciduous as priv/lolly/graph-data.json. Refresh that
  file (copy from the lolly_course repo's docs/graph-data.json after a
  `deciduous sync`) to pick up new passes over the book.

  The graph maps a 137-page parent-education course on visual supports for
  autistic children: a book-level spine, the eight lessons, the framing and
  closing material, cross-lesson arcs, the alignment between the content and
  the course's expressed design goals, and a layer of `AI_NOTE:` commentary
  nodes written on top of the book rather than drawn from it.
  """

  @note_prefix "AI_NOTE:"

  defp data_path, do: Application.app_dir(:blog, "priv/lolly/graph-data.json")

  defp load do
    data_path()
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
  end

  def stats do
    d = load()

    %{
      nodes: length(d.nodes),
      edges: length(d.edges),
      themes: length(d.themes),
      notes: Enum.count(d.nodes, &note?/1)
    }
  end

  def list_themes, do: load().themes

  @doc "AI_NOTE nodes are commentary about the book, not content from it."
  def note?(node), do: String.starts_with?(node.title || "", @note_prefix)

  @doc "The note title without its marker prefix."
  def note_title(node), do: node.title |> String.replace_prefix(@note_prefix, "") |> String.trim()

  @doc """
  Which part of the course a node belongs to — the deciduous branch tag.
  Values are `lesson-1`..`lesson-8`, plus `frame`, `spine`, `arcs`,
  `alignment`, `closing`, `ai-notes`, and `book` for the work itself.
  """
  def part(node) do
    case Jason.decode(node.metadata_json || "{}") do
      {:ok, %{"branch" => b}} -> b
      _ -> "unfiled"
    end
  end

  @part_labels %{
    "book" => "This exploration",
    "spine" => "Book spine",
    "frame" => "Framing & promise",
    "closing" => "Bringing it together",
    "arcs" => "Arcs across lessons",
    "alignment" => "Goals vs. content",
    "ai-notes" => "AI commentary",
    "unfiled" => "Unfiled"
  }

  def part_label("lesson-" <> n), do: "Lesson #{n}"
  def part_label(part), do: Map.get(@part_labels, part, part)

  @part_order ~w(book spine frame lesson-1 lesson-2 lesson-3 lesson-4 lesson-5
                 lesson-6 lesson-7 lesson-8 closing arcs alignment ai-notes unfiled)

  def part_rank(part) do
    case Enum.find_index(@part_order, &(&1 == part)) do
      nil -> 99
      i -> i
    end
  end

  def list_parts do
    load().nodes
    |> Enum.map(&part/1)
    |> Enum.uniq()
    |> Enum.sort_by(&part_rank/1)
  end

  def get_node(id) when is_integer(id) do
    load().nodes |> Enum.find(&(&1.id == id))
  end

  def get_node(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> get_node(int)
      :error -> nil
    end
  end

  @doc """
  Token-scored search: splits the query into words and ranks nodes by how
  many of them appear (rather than requiring the whole phrase verbatim),
  since callers (including an LLM) rarely quote text exactly.
  """
  def search_nodes(query, opts \\ []) do
    terms =
      (query || "")
      |> String.downcase()
      |> String.split(~r/[^a-z0-9]+/, trim: true)
      |> Enum.reject(&(String.length(&1) < 3))

    node_type = opts[:node_type]
    p = opts[:part]

    load().nodes
    |> Enum.filter(fn n ->
      (is_nil(node_type) or node_type == "" or n.node_type == node_type) and
        (is_nil(p) or p == "" or part(n) == p)
    end)
    |> Enum.map(fn n ->
      text = String.downcase("#{n.title} #{n.description}")
      score = Enum.count(terms, &String.contains?(text, &1))
      {n, score}
    end)
    |> Enum.filter(fn {_n, score} -> terms == [] or score > 0 end)
    |> Enum.sort_by(fn {_n, score} -> -score end)
    |> Enum.map(&elem(&1, 0))
    |> Enum.take(opts[:limit] || 20)
  end

  @doc "The commentary layer: every AI_NOTE node with what it attaches to."
  def list_notes do
    d = load()
    by_id = Map.new(d.nodes, &{&1.id, &1})

    d.nodes
    |> Enum.filter(&note?/1)
    |> Enum.map(fn n ->
      about =
        d.edges
        |> Enum.filter(&(&1.from_node_id == n.id))
        |> Enum.map(&Map.get(by_id, &1.to_node_id))
        |> Enum.reject(&is_nil/1)

      %{
        id: n.id,
        title: note_title(n),
        description: n.description,
        about: Enum.map(about, &%{id: &1.id, title: &1.title, part: part(&1)})
      }
    end)
  end

  @doc """
  The book-level spine: the single top chain the eight lessons hang off,
  in canonical flow order.
  """
  @type_order ~w(goal option decision action outcome observation)

  def spine do
    load().nodes
    |> Enum.filter(&(part(&1) == "spine"))
    |> Enum.sort_by(fn n ->
      {Enum.find_index(@type_order, &(&1 == n.node_type)) || 99, n.id}
    end)
  end

  @doc "Cross-lesson arcs — developmental movements that span the course."
  def arcs, do: load().nodes |> Enum.filter(&(part(&1) == "arcs"))

  def theme_counts do
    node_themes = load().node_themes
    Enum.frequencies_by(node_themes, & &1.theme_id)
  end

  @doc "Everything the client-side graph explorer needs, JSON-ready."
  def graph_export do
    d = load()

    %{
      nodes: d.nodes,
      edges: d.edges,
      themes: d.themes,
      node_themes: d.node_themes
    }
  end

  def nodes_for_theme(theme_name) do
    d = load()
    theme = Enum.find(d.themes, &(String.downcase(&1.name) == String.downcase(theme_name || "")))

    if theme do
      ids = d.node_themes |> Enum.filter(&(&1.theme_id == theme.id)) |> Enum.map(& &1.node_id)
      Enum.filter(d.nodes, &(&1.id in ids))
    else
      []
    end
  end

  def themes_for_node(node_id) do
    d = load()
    id = if is_binary(node_id), do: String.to_integer(node_id), else: node_id
    theme_ids = d.node_themes |> Enum.filter(&(&1.node_id == id)) |> Enum.map(& &1.theme_id)
    Enum.filter(d.themes, &(&1.id in theme_ids))
  end

  def neighbors(node_id) do
    d = load()
    id = if is_binary(node_id), do: String.to_integer(node_id), else: node_id
    outgoing = d.edges |> Enum.filter(&(&1.from_node_id == id))
    incoming = d.edges |> Enum.filter(&(&1.to_node_id == id))
    %{outgoing: outgoing, incoming: incoming}
  end

  def to_summary(node) do
    %{
      id: node.id,
      type: node.node_type,
      title: node.title,
      part: part(node),
      part_label: part_label(part(node)),
      status: node.status
    }
  end
end
