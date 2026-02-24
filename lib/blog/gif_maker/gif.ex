defmodule Blog.GifMaker.Gif do
  use Ecto.Schema
  import Ecto.Changeset

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

  def changeset(gif, attrs) do
    gif
    |> cast(attrs, [:job_id, :hash, :frame_indices, :gif_data, :frame_count, :duration_ms, :file_size])
    |> validate_required([:job_id, :hash, :frame_indices, :gif_data])
    |> unique_constraint(:hash)
  end

  def generate_hash(job_id, frame_indices, text \\ "") do
    sorted = Enum.sort(frame_indices)
    data = "#{job_id}:#{Enum.join(sorted, ",")}:#{text}"
    :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  end
end
