defmodule Blog.Blinks.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :blink_id, :author_name, :content, :inserted_at, :reactions]}
  @type t :: %__MODULE__{
          id: integer() | nil,
          blink_id: integer() | nil,
          author_name: String.t() | nil,
          content: String.t() | nil,
          ip_hash: String.t() | nil,
          report_count: integer(),
          hidden_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "blink_comments" do
    field :blink_id, :integer
    field :author_name, :string
    field :content, :string
    field :ip_hash, :string
    field :report_count, :integer, default: 0
    field :hidden_at, :naive_datetime
    # %{"❤️" => 3} — populated by list queries and reaction broadcasts
    field :reactions, :map, virtual: true, default: %{}

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:blink_id, :author_name, :content, :ip_hash])
    |> update_change(:author_name, &squish/1)
    |> update_change(:content, &String.trim/1)
    |> validate_required([:blink_id, :author_name, :content])
    |> validate_length(:author_name, min: 1, max: 40)
    |> validate_length(:content, min: 1, max: 500)
    |> validate_link_budget()
    |> validate_clean_language(:author_name)
    |> validate_clean_language(:content)
    |> foreign_key_constraint(:blink_id)
  end

  defp squish(s), do: s |> String.trim() |> String.replace(~r/\s+/, " ")

  # Anonymous comments are a spam magnet; more than two links reads as one.
  defp validate_link_budget(changeset) do
    content = get_change(changeset, :content) || ""

    if length(Regex.scan(~r/https?:\/\//i, content)) > 2 do
      add_error(changeset, :content, "too many links")
    else
      changeset
    end
  end

  # Apple guideline 1.2 requires filtering objectionable UGC. Small blocklist
  # of the clearly-over-the-line terms; reports + auto-hide catch the rest.
  @blocked ~w(nigger nigga faggot kike spic chink tranny)

  defp validate_clean_language(changeset, field) do
    value = (get_change(changeset, field) || "") |> String.downcase()

    if Enum.any?(@blocked, &String.contains?(value, &1)) do
      add_error(changeset, field, "keep it civil")
    else
      changeset
    end
  end
end
