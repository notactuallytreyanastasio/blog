defmodule Blog.GifMaker.Job do
  use Ecto.Schema
  import Ecto.Changeset

  @youtube_url_regex ~r{^https?://(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/shorts/)}
  @max_segment_ms 180_000

  schema "gif_maker_jobs" do
    field :youtube_url, :string
    field :video_id, :string
    field :title, :string
    field :duration_seconds, :integer
    field :start_time_ms, :integer
    field :end_time_ms, :integer
    field :status, :string, default: "pending"
    field :ip_hash, :string
    field :error_message, :string
    field :frame_count, :integer
    field :expires_at, :utc_datetime

    has_many :frames, Blog.GifMaker.Frame, foreign_key: :job_id
    has_many :gifs, Blog.GifMaker.Gif, foreign_key: :job_id

    timestamps()
  end

  def changeset(job, attrs) do
    job
    |> cast(attrs, [:youtube_url, :video_id, :title, :duration_seconds, :start_time_ms, :end_time_ms, :status, :ip_hash, :error_message, :frame_count, :expires_at])
    |> validate_required([:youtube_url, :video_id, :start_time_ms, :end_time_ms])
    |> validate_format(:youtube_url, @youtube_url_regex, message: "must be a valid YouTube URL")
    |> validate_number(:start_time_ms, greater_than_or_equal_to: 0)
    |> validate_segment_length()
    |> put_expires_at()
  end

  def status_changeset(job, status, attrs \\ %{}) do
    job
    |> cast(Map.put(attrs, :status, status), [:status, :error_message, :frame_count])
    |> validate_inclusion(:status, ~w(pending downloading extracting ready generating_gif completed failed expired))
  end

  defp validate_segment_length(changeset) do
    start_ms = get_field(changeset, :start_time_ms)
    end_ms = get_field(changeset, :end_time_ms)

    cond do
      is_nil(start_ms) or is_nil(end_ms) -> changeset
      end_ms <= start_ms -> add_error(changeset, :end_time_ms, "must be after start time")
      end_ms - start_ms > @max_segment_ms -> add_error(changeset, :end_time_ms, "segment cannot exceed 3 minutes")
      true -> changeset
    end
  end

  defp put_expires_at(changeset) do
    if get_field(changeset, :expires_at) do
      changeset
    else
      put_change(changeset, :expires_at, DateTime.add(DateTime.utc_now(), 2, :hour) |> DateTime.truncate(:second))
    end
  end
end
