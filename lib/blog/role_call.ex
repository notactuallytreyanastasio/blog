defmodule Blog.RoleCall do
  @moduledoc """
  Context for Role Call - TV show discovery through writers.
  """

  import Ecto.Query
  alias Blog.Repo
  alias Blog.RoleCall.{Show, Person, Credit}

  # ============ Shows ============

  def search_shows(query, opts \\ []) when is_binary(query) do
    limit = Keyword.get(opts, :limit, 20)
    exclude_ids = Keyword.get(opts, :exclude_ids, [])

    from(s in Show,
      where: ilike(s.title, ^"%#{query}%"),
      where: s.id not in ^exclude_ids,
      order_by: [desc: s.imdb_rating],
      limit: ^limit
    )
    |> Repo.all()
  end

  def get_show(id), do: Repo.get(Show, id)

  def get_show_with_credits(id) do
    from(s in Show,
      where: s.id == ^id,
      preload: [credits: ^credits_with_people_query()]
    )
    |> Repo.one()
  end

  defp credits_with_people_query do
    from(c in Credit,
      join: p in assoc(c, :person),
      preload: [person: p],
      order_by: [
        asc: fragment("CASE ? WHEN 'creator' THEN 1 WHEN 'writer' THEN 2 WHEN 'director' THEN 3 WHEN 'actor' THEN 4 END", c.role)
      ]
    )
  end

  def get_random_shows(opts \\ []) do
    limit = Keyword.get(opts, :limit, 12)
    exclude_ids = Keyword.get(opts, :exclude_ids, [])
    min_rating = Keyword.get(opts, :min_rating, 7.5)

    from(s in Show,
      where: s.id not in ^exclude_ids,
      where: s.imdb_rating >= ^min_rating or is_nil(s.imdb_rating),
      where: not is_nil(s.scraped_at),
      order_by: fragment("RANDOM()"),
      limit: ^limit
    )
    |> Repo.all()
    |> preload_writers()
  end

  # ============ People ============

  def get_person(id), do: Repo.get(Person, id)

  def get_person_with_shows(id) do
    from(p in Person,
      where: p.id == ^id,
      preload: [credits: ^person_credits_query()]
    )
    |> Repo.one()
  end

  defp person_credits_query do
    from(c in Credit,
      join: s in assoc(c, :show),
      preload: [show: s],
      order_by: [desc: s.imdb_rating]
    )
  end

  # ============ Writers & Recommendations ============

  def get_show_writers(show_id) do
    from(c in Credit,
      join: p in assoc(c, :person),
      where: c.show_id == ^show_id,
      where: c.role in ["creator", "writer"],
      preload: [person: p],
      order_by: [
        asc: fragment("CASE ? WHEN 'creator' THEN 1 WHEN 'writer' THEN 2 END", c.role)
      ]
    )
    |> Repo.all()
    |> Enum.map(& &1.person)
  end

  def get_writer_shows(person_id, opts \\ []) do
    exclude_ids = Keyword.get(opts, :exclude_ids, [])

    from(s in Show,
      join: c in Credit,
      on: c.show_id == s.id,
      where: c.person_id == ^person_id,
      where: c.role in ["creator", "writer"],
      where: s.id not in ^exclude_ids,
      order_by: [desc: s.imdb_rating],
      distinct: true
    )
    |> Repo.all()
  end

  @doc """
  Get recommendations based on writers from liked shows.
  Returns shows by the same writers, ranked by how many liked writers worked on them.
  """
  def get_recommendations(liked_show_ids, opts \\ []) when is_list(liked_show_ids) do
    limit = Keyword.get(opts, :limit, 20)
    exclude_ids = Keyword.get(opts, :exclude_ids, [])

    if liked_show_ids == [] do
      []
    else
      # Get all writers from liked shows
      writer_ids =
        from(c in Credit,
          where: c.show_id in ^liked_show_ids,
          where: c.role in ["creator", "writer"],
          select: c.person_id,
          distinct: true
        )
        |> Repo.all()

      if writer_ids == [] do
        []
      else
        # Find shows by these writers, ranked by overlap count
        from(s in Show,
          join: c in Credit,
          on: c.show_id == s.id,
          where: c.person_id in ^writer_ids,
          where: c.role in ["creator", "writer"],
          where: s.id not in ^exclude_ids,
          where: s.id not in ^liked_show_ids,
          where: not is_nil(s.scraped_at),
          group_by: s.id,
          order_by: [desc: count(c.person_id), desc: s.imdb_rating],
          limit: ^limit
        )
        |> Repo.all()
        |> preload_writers()
      end
    end
  end

  # ============ Data Import ============

  def import_show(attrs) do
    %Show{}
    |> Show.changeset(attrs)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :id)
  end

  def import_person(attrs) do
    %Person{}
    |> Person.changeset(attrs)
    |> Repo.insert(on_conflict: :replace_all, conflict_target: :id)
  end

  def import_credit(attrs) do
    %Credit{}
    |> Credit.changeset(attrs)
    |> Repo.insert(on_conflict: :nothing)
  end

  def count_shows, do: Repo.aggregate(Show, :count)
  def count_people, do: Repo.aggregate(Person, :count)

  # ============ Helpers ============

  defp preload_writers(shows) when is_list(shows) do
    show_ids = Enum.map(shows, & &1.id)

    writers_by_show =
      from(c in Credit,
        join: p in assoc(c, :person),
        where: c.show_id in ^show_ids,
        where: c.role in ["creator", "writer"],
        preload: [person: p],
        order_by: [asc: fragment("CASE ? WHEN 'creator' THEN 1 WHEN 'writer' THEN 2 END", c.role)]
      )
      |> Repo.all()
      |> Enum.group_by(& &1.show_id)

    Enum.map(shows, fn show ->
      writers = writers_by_show[show.id] || []
      Map.put(show, :writers, Enum.map(writers, & &1.person))
    end)
  end
end
