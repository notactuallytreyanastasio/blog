defmodule Blog.Museum.Projects do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Museum.Project

  # === Public Queries (used by TerminalLive) ===

  @spec all() :: [struct()]
  def all do
    Project
    |> where([p], p.visible == true)
    |> order_by([p], asc: p.sort_order)
    |> Repo.all()
  end

  @spec get_by_slug(String.t()) :: struct() | nil
  def get_by_slug(slug) do
    Repo.get_by(Project, slug: slug, visible: true)
  end

  @spec categories() :: [String.t()]
  def categories do
    Project
    |> where([p], p.visible == true)
    |> select([p], p.category)
    |> distinct(true)
    |> order_by([p], asc: p.category)
    |> Repo.all()
  end

  @spec by_category(String.t()) :: [struct()]
  def by_category(category) do
    Project
    |> where([p], p.visible == true and p.category == ^category)
    |> order_by([p], asc: p.sort_order)
    |> Repo.all()
  end

  # === Admin CRUD ===

  @spec list_projects() :: [struct()]
  def list_projects do
    Project
    |> order_by([p], asc: p.sort_order)
    |> Repo.all()
  end

  @spec get_project!(term()) :: struct()
  def get_project!(id), do: Repo.get!(Project, id)

  @spec create_project(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create_project(attrs) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_project(struct(), map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @spec delete_project(struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def delete_project(%Project{} = project), do: Repo.delete(project)

  @spec change_project(struct(), map()) :: Ecto.Changeset.t()
  def change_project(%Project{} = project, attrs \\ %{}), do: Project.changeset(project, attrs)

  # === Reordering ===

  @spec bulk_reorder([integer() | String.t()]) :: {:ok, term()} | {:error, term()}
  def bulk_reorder(ids) when is_list(ids) do
    Repo.transaction(fn ->
      ids
      |> Enum.with_index()
      |> Enum.each(fn {id, index} ->
        id = if is_binary(id), do: String.to_integer(id), else: id
        from(p in Project, where: p.id == ^id)
        |> Repo.update_all(set: [sort_order: index])
      end)
    end)
  end

  @spec reorder_project(term(), :up | :down) ::
          :ok | {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def reorder_project(project_id, direction) when direction in [:up, :down] do
    projects = Repo.all(from(p in Project, order_by: [asc: p.sort_order]))
    reorder_in_list(projects, project_id, direction)
  end

  defp reorder_in_list(list, target_id, direction) do
    index = Enum.find_index(list, &(&1.id == target_id))

    swap_index =
      case direction do
        :up -> max(index - 1, 0)
        :down -> min(index + 1, length(list) - 1)
      end

    if index == swap_index do
      :ok
    else
      target = Enum.at(list, index)
      swap = Enum.at(list, swap_index)
      update_project(target, %{sort_order: swap.sort_order})
      update_project(swap, %{sort_order: target.sort_order})
    end
  end
end
