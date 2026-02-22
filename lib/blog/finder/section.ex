defmodule Blog.Finder.Section do
  use Ecto.Schema
  import Ecto.Changeset

  schema "finder_sections" do
    field :name, :string
    field :label, :string
    field :sort_order, :integer, default: 0
    field :joyride_target, :string
    field :visible, :boolean, default: true

    has_many :items, Blog.Finder.Item

    timestamps()
  end

  def changeset(section, attrs) do
    section
    |> cast(attrs, [:name, :label, :sort_order, :joyride_target, :visible])
    |> validate_required([:name, :sort_order])
    |> unique_constraint(:name)
  end
end
