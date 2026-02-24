defmodule Blog.GifMaker.Frame do
  use Ecto.Schema
  import Ecto.Changeset

  schema "gif_maker_frames" do
    field :frame_number, :integer
    field :timestamp_ms, :integer
    field :image_data, :binary
    field :file_size, :integer

    belongs_to :job, Blog.GifMaker.Job

    timestamps()
  end

  def changeset(frame, attrs) do
    frame
    |> cast(attrs, [:job_id, :frame_number, :timestamp_ms, :image_data, :file_size])
    |> validate_required([:job_id, :frame_number, :timestamp_ms, :image_data])
  end
end
