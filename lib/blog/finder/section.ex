defmodule Blog.Finder.Section do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          name: String.t() | nil,
          label: String.t() | nil,
          sort_order: integer() | nil,
          joyride_target: String.t() | nil,
          visible: boolean() | nil,
          items: [struct()] | Ecto.Association.NotLoaded.t(),
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "finder_sections" do
    field :name, :string
    field :label, :string
    field :sort_order, :integer, default: 0
    field :joyride_target, :string
    field :visible, :boolean, default: true

    has_many :items, Blog.Finder.Item

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:name, :label, :sort_order, :joyride_target, :visible])
    |> validate_required([:name, :sort_order])
    |> unique_constraint(:name)
  end
end
