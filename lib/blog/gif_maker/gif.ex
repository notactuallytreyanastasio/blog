defmodule Blog.GifMaker.Gif do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          hash: String.t() | nil,
          frame_indices: [integer()] | nil,
          gif_data: binary() | nil,
          frame_count: integer() | nil,
          duration_ms: integer() | nil,
          file_size: integer() | nil,
          job_id: integer() | nil,
          job: struct() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "gif_maker_gifs" do
    field :hash, :string
    field :frame_indices, {:array, :integer}
    field :gif_data, :binary
    field :frame_count, :integer
    field :duration_ms, :integer
    field :file_size, :integer

    belongs_to :job, Blog.GifMaker.Job

    timestamps()
  end

  @spec changeset(t() | Ecto.Schema.t(), map()) :: Ecto.Changeset.t()
  def changeset(gif, attrs) do
    gif
    |> cast(attrs, [:job_id, :hash, :frame_indices, :gif_data, :frame_count, :duration_ms, :file_size])
    |> validate_required([:job_id, :hash, :frame_indices, :gif_data])
    |> unique_constraint(:hash)
  end

  @spec generate_hash(term(), [integer()], String.t()) :: String.t()
  def generate_hash(job_id, frame_indices, text \\ "") do
    sorted = Enum.sort(frame_indices)
    data = "#{job_id}:#{Enum.join(sorted, ",")}:#{text}"
    :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  end
end
