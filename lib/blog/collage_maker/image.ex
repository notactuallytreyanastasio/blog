defmodule Blog.CollageMaker.Image do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          position: integer() | nil,
          original_s3_key: String.t() | nil,
          cropped_s3_key: String.t() | nil,
          original_width: integer() | nil,
          original_height: integer() | nil,
          content_type: String.t() | nil,
          file_size: integer() | nil,
          collage_id: integer() | nil,
          collage: Ecto.Association.NotLoaded.t() | struct() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "collage_maker_images" do
    field :position, :integer
    field :original_s3_key, :string
    field :cropped_s3_key, :string
    field :original_width, :integer
    field :original_height, :integer
    field :content_type, :string
    field :file_size, :integer

    belongs_to :collage, Blog.CollageMaker.Collage

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(image, attrs) do
    image
    |> cast(attrs, [:collage_id, :position, :original_s3_key, :cropped_s3_key,
                     :original_width, :original_height, :content_type, :file_size])
    |> validate_required([:collage_id, :position, :original_s3_key])
    |> foreign_key_constraint(:collage_id)
    |> unique_constraint([:collage_id, :position])
  end
end
