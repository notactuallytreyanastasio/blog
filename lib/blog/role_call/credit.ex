defmodule Blog.RoleCall.Credit do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "rc_credits" do
    field :role, :string
    field :details, :string

    belongs_to :show, Blog.RoleCall.Show, type: :string
    belongs_to :person, Blog.RoleCall.Person, type: :string
  end

  def changeset(credit, attrs) do
    credit
    |> cast(attrs, [:show_id, :person_id, :role, :details])
    |> validate_required([:show_id, :person_id, :role])
    |> validate_inclusion(:role, ["creator", "writer", "director", "actor"])
  end
end
