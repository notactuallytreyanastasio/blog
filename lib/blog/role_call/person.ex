defmodule Blog.RoleCall.Person do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, autogenerate: false}
  schema "rc_people" do
    field :name, :string
    field :image_url, :string
    field :scraped_at, :utc_datetime

    has_many :credits, Blog.RoleCall.Credit, foreign_key: :person_id
    many_to_many :shows, Blog.RoleCall.Show, join_through: Blog.RoleCall.Credit

    timestamps()
  end

  def changeset(person, attrs) do
    person
    |> cast(attrs, [:id, :name, :image_url, :scraped_at])
    |> validate_required([:id, :name])
  end
end
