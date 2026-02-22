defmodule Blog.Finder do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Finder.{Section, Item}

  # === Public Queries (used by TerminalLive) ===

  def list_sections_with_items do
    Section
    |> where([s], s.visible == true)
    |> order_by([s], asc: s.sort_order)
    |> preload(items: ^from(i in Item, where: i.visible == true, order_by: [asc: i.sort_order]))
    |> Repo.all()
  end

  # === Section CRUD (admin) ===

  def list_sections do
    Section
    |> order_by([s], asc: s.sort_order)
    |> preload(items: ^from(i in Item, order_by: [asc: i.sort_order]))
    |> Repo.all()
  end

  def get_section!(id), do: Repo.get!(Section, id) |> Repo.preload(items: from(i in Item, order_by: [asc: i.sort_order]))

  def create_section(attrs) do
    %Section{}
    |> Section.changeset(attrs)
    |> Repo.insert()
  end

  def update_section(%Section{} = section, attrs) do
    section
    |> Section.changeset(attrs)
    |> Repo.update()
  end

  def delete_section(%Section{} = section), do: Repo.delete(section)

  def change_section(%Section{} = section, attrs \\ %{}), do: Section.changeset(section, attrs)

  # === Item CRUD (admin) ===

  def get_item!(id), do: Repo.get!(Item, id)

  def create_item(attrs) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item), do: Repo.delete(item)

  def change_item(%Item{} = item, attrs \\ %{}), do: Item.changeset(item, attrs)

  # === Reordering ===

  def reorder_section(section_id, direction) when direction in [:up, :down] do
    sections = Repo.all(from(s in Section, order_by: [asc: s.sort_order]))
    reorder_in_list(sections, section_id, direction, &update_section/2)
  end

  def reorder_item(item_id, direction) when direction in [:up, :down] do
    item = get_item!(item_id)
    items = Repo.all(from(i in Item, where: i.section_id == ^item.section_id, order_by: [asc: i.sort_order]))
    reorder_in_list(items, item_id, direction, &update_item/2)
  end

  defp reorder_in_list(list, target_id, direction, update_fn) do
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
      update_fn.(target, %{sort_order: swap.sort_order})
      update_fn.(swap, %{sort_order: target.sort_order})
    end
  end
end
