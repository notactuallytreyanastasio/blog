defmodule Blog.RoleCall.Credit do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          role: String.t() | nil,
          details: String.t() | nil,
          show_id: String.t() | nil,
          show: struct() | Ecto.Association.NotLoaded.t() | nil,
          person_id: String.t() | nil,
          person: struct() | Ecto.Association.NotLoaded.t() | nil
        }

  @primary_key {:id, :id, autogenerate: true}
  schema "rc_credits" do
    field :role, :string
    field :details, :string

    belongs_to :show, Blog.RoleCall.Show, type: :string
    belongs_to :person, Blog.RoleCall.Person, type: :string
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(credit, attrs) do
    credit
    |> cast(attrs, [:show_id, :person_id, :role, :details])
    |> validate_required([:show_id, :person_id, :role])
    |> validate_inclusion(:role, ["creator", "writer", "director", "actor"])
  end
end
