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
             :quotes,
             :thread,
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
          quotes: [String.t()],
          thread: map() | nil,
          favicon_url: String.t() | nil,
          image_url: String.t() | nil,
          site_name: String.t() | nil,
          enriched_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "blinks" do
    field :url, :string
    field :title, :string
    field :description, :string
    field :tags, {:array, :string}, default: []
    field :quotes, {:array, :string}, default: []
    field :thread, :map
    field :favicon_url, :string
    field :image_url, :string
    field :site_name, :string
    field :enriched_at, :naive_datetime
    field :dead_at, :naive_datetime
    field :last_checked_at, :naive_datetime
    field :fail_count, :integer, default: 0

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
      :quotes,
      :thread,
      :favicon_url,
      :image_url,
      :site_name,
      :enriched_at,
      :dead_at,
      :last_checked_at,
      :fail_count
    ])
    |> validate_required([:url])
    |> validate_length(:url, min: 1, max: 4096)
    |> validate_length(:description, max: 10_000)
    |> update_change(:tags, &normalize_tags/1)
    |> update_change(:quotes, &normalize_quotes/1)
    |> unique_constraint(:url)
  end

  defp normalize_quotes(quotes) do
    quotes
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(&String.slice(&1, 0, 2000))
    |> Enum.uniq()
  end

  defp normalize_tags(tags) do
    tags
    |> Enum.map(&(&1 |> String.trim() |> String.downcase()))
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end
end
