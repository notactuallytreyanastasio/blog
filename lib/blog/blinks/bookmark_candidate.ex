defmodule Blog.Blinks.BookmarkCandidate do
  use Ecto.Schema

  @type t :: %__MODULE__{
          id: integer() | nil,
          url: String.t() | nil,
          title: String.t() | nil,
          folder: String.t() | nil,
          status: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "bookmark_candidates" do
    field :url, :string
    field :title, :string
    field :folder, :string
    field :status, :string, default: "pending"

    timestamps()
  end
end
