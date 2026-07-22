defmodule Blog.Blinks.Blink do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [
             :id,
             :url,
             :title,
             :description,
             :tags,
             :favicon_url,
             :image_url,
             :site_name,
             :inserted_at
           ]}
  @type t :: %__MODULE__{
          id: integer() | nil,
          url: String.t() | nil,
          title: String.t() | nil,
          description: String.t() | nil,
          tags: [String.t()],
          favicon_url: String.t() | nil,
          image_url: String.t() | nil,
          site_name: String.t() | nil,
          embedding: [float()] | nil,
          enriched_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "blinks" do
    field :url, :string
    field :title, :string
    field :description, :string
    field :tags, {:array, :string}, default: []
    field :favicon_url, :string
    field :image_url, :string
    field :site_name, :string
    field :embedding, {:array, :float}
    field :enriched_at, :naive_datetime

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(blink, attrs) do
    blink
    |> cast(attrs, [
      :url,
      :title,
      :description,
      :tags,
      :favicon_url,
      :image_url,
      :site_name,
      :embedding,
      :enriched_at
    ])
    |> validate_required([:url])
    |> validate_length(:url, min: 1, max: 4096)
    |> validate_length(:description, max: 10_000)
    |> update_change(:tags, &normalize_tags/1)
    |> unique_constraint(:url)
  end

  defp normalize_tags(tags) do
    tags
    |> Enum.map(&(&1 |> String.trim() |> String.downcase()))
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end
end
