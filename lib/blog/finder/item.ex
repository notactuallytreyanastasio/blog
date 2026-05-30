defmodule Blog.Finder.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          icon: String.t() | nil,
          path: String.t() | nil,
          sort_order: integer() | nil,
          joyride_target: String.t() | nil,
          action: String.t() | nil,
          description: String.t() | nil,
          visible: boolean() | nil,
          section_id: integer() | nil,
          section: Ecto.Association.NotLoaded.t() | struct() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "finder_items" do
    field :name, :string
    field :icon, :string
    field :path, :string
    field :sort_order, :integer, default: 0
    field :joyride_target, :string
    field :action, :string
    field :description, :string
    field :visible, :boolean, default: true

    belongs_to :section, Blog.Finder.Section

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :icon, :path, :sort_order, :joyride_target, :action, :description, :visible, :section_id])
    |> validate_required([:name, :icon, :sort_order, :section_id])
    |> foreign_key_constraint(:section_id)
  end
end
