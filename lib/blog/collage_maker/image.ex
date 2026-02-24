defmodule Blog.CollageMaker.Image do
  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(image, attrs) do
    image
    |> cast(attrs, [:collage_id, :position, :original_s3_key, :cropped_s3_key,
                     :original_width, :original_height, :content_type, :file_size])
    |> validate_required([:collage_id, :position, :original_s3_key])
    |> foreign_key_constraint(:collage_id)
    |> unique_constraint([:collage_id, :position])
  end
end
