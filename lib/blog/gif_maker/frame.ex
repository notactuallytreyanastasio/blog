defmodule Blog.GifMaker.Frame do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          frame_number: integer() | nil,
          timestamp_ms: integer() | nil,
          image_data: binary() | nil,
          file_size: integer() | nil,
          job_id: integer() | nil,
          job: struct() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "gif_maker_frames" do
    field :frame_number, :integer
    field :timestamp_ms, :integer
    field :image_data, :binary
    field :file_size, :integer

    belongs_to :job, Blog.GifMaker.Job

    timestamps()
  end

  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(frame, attrs) do
    frame
    |> cast(attrs, [:job_id, :frame_number, :timestamp_ms, :image_data, :file_size])
    |> validate_required([:job_id, :frame_number, :timestamp_ms, :image_data])
  end
end
