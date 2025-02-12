defmodule Blog.Social do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Social.Sparkle

  @doc """
  Creates a new sparkle.
  If it's a reply, it will set both sparkle_id and root_sparkle_id.
  """
  def create_sparkle(attrs \\ %{}) do
    # If this is a reply, set the root_sparkle_id
    attrs = case attrs do
      %{sparkle_id: parent_id} when not is_nil(parent_id) ->
        parent = get_sparkle!(parent_id)
        root_id = parent.root_sparkle_id || parent.id
        Map.put(attrs, :root_sparkle_id, root_id)
      _ -> attrs
    end

    %Sparkle{}
    |> Sparkle.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a sparkle by ID.
  Raises if not found.
  """
  def get_sparkle!(id), do: Repo.get!(Sparkle, id)

  @doc """
  Gets a sparkle and preloads its replies.
  """
  def get_sparkle_with_replies!(id) do
    Sparkle
    |> Repo.get!(id)
    |> Repo.preload(replies: from(s in Sparkle, order_by: [desc: s.inserted_at]))
  end

  @doc """
  Gets the entire conversation for a sparkle.
  Returns the root sparkle with all nested replies.
  """
  def get_conversation!(sparkle_id) do
    sparkle = get_sparkle!(sparkle_id)
    root_id = sparkle.root_sparkle_id || sparkle.id

    Sparkle
    |> where([s], s.id == ^root_id)
    |> preload(replies: ^from(s in Sparkle, order_by: [desc: s.inserted_at]))
    |> Repo.one!()
  end

  @doc """
  Lists sparkles with optional filters.
  """
  def list_sparkles(opts \\ []) do
    Sparkle
    |> filter_sparkles(opts)
    |> order_by([s], [desc: s.inserted_at])
    |> Repo.all()
  end

  @doc """
  Updates a sparkle.
  """
  def update_sparkle(%Sparkle{} = sparkle, attrs) do
    sparkle
    |> Sparkle.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sparkle and all its replies.
  """
  def delete_sparkle(%Sparkle{} = sparkle) do
    Repo.delete(sparkle)
  end

  @doc """
  Gets 10 random sparkles and concatenates their content into a single string.
  Uses TABLESAMPLE for efficient random selection on large tables.
  """
  def random_sparkle_content do
    # Using TABLESAMPLE SYSTEM to efficiently sample large tables
    query = """
    WITH random_sparkles AS (
      SELECT content
      FROM sparkles TABLESAMPLE SYSTEM (1)
      WHERE content IS NOT NULL
      LIMIT 100
    )
    SELECT string_agg(content, ' ') as combined_content
    FROM random_sparkles
    """

    case Repo.query(query) do
      {:ok, %{rows: [[content]]}} when not is_nil(content) ->
        content
      _ ->
        "" # Return empty string if no results or error
    end
  end

  defp filter_sparkles(query, opts) do
    Enum.reduce(opts, query, fn
      {:author, author}, query ->
        where(query, [s], s.author == ^author)
      {:since, timestamp}, query ->
        where(query, [s], s.inserted_at >= ^timestamp)
      {:root_only, true}, query ->
        where(query, [s], is_nil(s.sparkle_id))
      _opt, query -> query
    end)
  end
end
