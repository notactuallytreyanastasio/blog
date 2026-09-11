defmodule Blog.Ziggy do
  @moduledoc """
  Read-only query interface over the "Ziggy Account" decision graph, exported
  from deciduous as priv/ziggy/graph-data.json. Refresh that file (copy from
  the tim_blausey repo's docs/graph-data.json after a `deciduous sync`) to
  pick up new chapters or graph passes.
  """

  defp data_path, do: Application.app_dir(:blog, "priv/ziggy/graph-data.json")

  defp load do
    data_path()
    |> File.read!()
    |> Jason.decode!(keys: :atoms)
  end

  def stats do
    d = load()
    %{nodes: length(d.nodes), edges: length(d.edges), themes: length(d.themes)}
  end

  def list_themes, do: load().themes

  def chapter(node) do
    case Jason.decode(node.metadata_json || "{}") do
      {:ok, %{"branch" => b}} -> b
      _ -> "unfiled"
    end
  end

  def list_chapters do
    load().nodes |> Enum.map(&chapter/1) |> Enum.uniq() |> Enum.sort()
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
    ch = opts[:chapter]

    load().nodes
    |> Enum.filter(fn n ->
      (is_nil(node_type) or node_type == "" or n.node_type == node_type) and
        (is_nil(ch) or ch == "" or chapter(n) == ch)
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

  @doc "Characters as explicit CHARACTER-profile nodes logged by the graph, e.g. 'CHARACTER -- Garrett: ...'"
  def list_characters do
    load().nodes
    |> Enum.filter(&String.starts_with?(&1.title, "CHARACTER -- "))
    |> Enum.map(fn n ->
      rest = String.replace_prefix(n.title, "CHARACTER -- ", "")

      {name, trait} =
        case String.split(rest, ":", parts: 2) do
          [name, trait] -> {String.trim(name), String.trim(trait)}
          [name] -> {String.trim(name), ""}
        end

      %{name: name, trait: trait, node_id: n.id}
    end)
  end

  @aliases %{
    "Grandmother" => ["Grandma"],
    "Garrett's mother" => ["his mother", "mother", "mom"]
  }

  def character_mentions(name) do
    names = [name | Map.get(@aliases, name, [])] |> Enum.map(&String.downcase/1)

    load().nodes
    |> Enum.filter(fn n ->
      text = String.downcase("#{n.title} #{n.description}")
      Enum.any?(names, &String.contains?(text, &1))
    end)
  end

  def theme_counts do
    node_themes = load().node_themes
    Enum.frequencies_by(node_themes, & &1.theme_id)
  end

  @doc "Everything the client-side graph explorer needs, JSON-ready."
  def graph_export do
    d = load()

    characters =
      list_characters()
      |> Enum.map(fn c -> Map.put(c, :mention_ids, character_mentions(c.name) |> Enum.map(& &1.id)) end)

    %{
      nodes: d.nodes,
      edges: d.edges,
      themes: d.themes,
      node_themes: d.node_themes,
      characters: characters
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

  def neighbors(node_id) do
    d = load()
    id = if is_binary(node_id), do: String.to_integer(node_id), else: node_id
    outgoing = d.edges |> Enum.filter(&(&1.from_node_id == id))
    incoming = d.edges |> Enum.filter(&(&1.to_node_id == id))
    %{outgoing: outgoing, incoming: incoming}
  end

  def to_summary(node) do
    %{id: node.id, type: node.node_type, title: node.title, chapter: chapter(node), status: node.status}
  end
end
