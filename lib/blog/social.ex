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

  @doc """
  Generates a tweet using a Markov chain built from existing sparkles.
  Uses pure SQL for performance with large datasets.
  """
  def generate_markov_tweet do
    query = """
    WITH RECURSIVE
    words AS (
      SELECT
        word_array[i] as word1,
        word_array[i+1] as word2
      FROM (
        SELECT regexp_split_to_array(lower(content), '\\s+') as word_array,
               generate_series(1, array_length(regexp_split_to_array(content, '\\s+'), 1) - 1) as i
        FROM sparkles TABLESAMPLE SYSTEM (1)
        WHERE content IS NOT NULL
      ) split
    ),
    transitions AS (
      SELECT
        word1,
        word2,
        count(*) as freq,
        row_number() OVER (PARTITION BY word1 ORDER BY random()) as rn
      FROM words
      GROUP BY word1, word2
    ),
    chain(word, text, words) AS (
      SELECT
        word1,
        word1 || ' ' || word2,
        2
      FROM transitions
      WHERE rn = 1
      AND length(word1) > 2

      UNION ALL

      SELECT
        t.word2,
        c.text || ' ' || t.word2,
        c.words + 1
      FROM chain c
      JOIN transitions t ON t.word1 = c.word
      WHERE c.words < 30
      AND NOT (c.text ~ '\\.\\s*$')
      AND t.rn = 1
    )
    SELECT text
    FROM chain
    WHERE text ~ '\\.\\s*$'
    AND char_length(text) <= 250
    ORDER BY words DESC, random()
    LIMIT 1;
    """

    case Repo.query(query, [], [timeout: 30_000]) do
      {:ok, %{rows: [[content]]}} when not is_nil(content) ->
        # Clean up the generated text
        content
        |> String.trim()
        |> String.replace(~r/\s+/, " ")
        |> capitalize_sentences()
      _ ->
        "Failed to generate tweet"
    end
  end

  defp capitalize_sentences(text) do
    text
    |> String.split(~r/([.!?])\s*/)
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(". ")
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
