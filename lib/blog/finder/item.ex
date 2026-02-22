defmodule Blog.Finder.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "finder_items" do
    field :name, :string
    field :icon, :string
    field :path, :string
    field :sort_order, :integer, default: 0
    field :joyride_target, :string
    field :action, :string
    field :visible, :boolean, default: true

    belongs_to :section, Blog.Finder.Section

    timestamps()
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :icon, :path, :sort_order, :joyride_target, :action, :visible, :section_id])
    |> validate_required([:name, :icon, :sort_order, :section_id])
    |> foreign_key_constraint(:section_id)
  end
end
