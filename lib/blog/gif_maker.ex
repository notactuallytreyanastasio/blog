defmodule Blog.GifMaker do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.GifMaker.{Job, Frame, Gif}

  @spec create_job(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create_job(attrs) do
    %Job{}
    |> Job.changeset(attrs)
    |> Repo.insert()
  end

  @spec get_job!(integer() | String.t()) :: struct()
  def get_job!(id) do
    Repo.get!(Job, id)
  end

  @spec get_job(integer() | String.t()) :: struct() | nil
  def get_job(id) do
    Repo.get(Job, id)
  end

  @spec update_job_status(struct() | Ecto.Changeset.t(), String.t(), map()) ::
          {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def update_job_status(job, status, attrs \\ %{}) do
    job
    |> Job.status_changeset(status, attrs)
    |> Repo.update()
  end

  @spec list_frames(integer() | String.t()) :: [
          %{
            id: integer(),
            frame_number: integer(),
            timestamp_ms: integer() | nil,
            file_size: integer() | nil
          }
        ]
  def list_frames(job_id) do
    Frame
    |> where([f], f.job_id == ^job_id)
    |> order_by([f], asc: f.frame_number)
    |> select([f], %{id: f.id, frame_number: f.frame_number, timestamp_ms: f.timestamp_ms, file_size: f.file_size})
    |> Repo.all()
  end

  @spec get_frame_image(integer() | String.t()) :: binary() | nil
  def get_frame_image(frame_id) do
    Frame
    |> where([f], f.id == ^frame_id)
    |> select([f], f.image_data)
    |> Repo.one()
  end

  @spec get_frames_by_indices(integer() | String.t(), [integer()]) :: [struct()]
  def get_frames_by_indices(job_id, indices) do
    frame_numbers = Enum.map(indices, &(&1 + 1))

    Frame
    |> where([f], f.job_id == ^job_id and f.frame_number in ^frame_numbers)
    |> order_by([f], asc: f.frame_number)
    |> Repo.all()
  end

  @spec insert_frame(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def insert_frame(attrs) do
    %Frame{}
    |> Frame.changeset(attrs)
    |> Repo.insert()
  end

  @spec insert_frames([map()]) :: {non_neg_integer(), nil | [term()]}
  def insert_frames(frames_attrs) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    entries =
      Enum.map(frames_attrs, fn attrs ->
        attrs
        |> Map.put(:inserted_at, now)
        |> Map.put(:updated_at, now)
      end)

    Repo.insert_all(Frame, entries)
  end

  @spec find_gif_by_hash(String.t()) :: struct() | nil
  def find_gif_by_hash(hash) do
    Gif
    |> where([g], g.hash == ^hash)
    |> Repo.one()
  end

  @spec save_gif(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def save_gif(attrs) do
    %Gif{}
    |> Gif.changeset(attrs)
    |> Repo.insert()
  end

  @spec get_gif(integer() | String.t()) :: struct() | nil
  def get_gif(id) do
    Repo.get(Gif, id)
  end

  @spec get_gif_data(integer() | String.t()) :: binary() | nil
  def get_gif_data(gif_id) do
    Gif
    |> where([g], g.id == ^gif_id)
    |> select([g], g.gif_data)
    |> Repo.one()
  end

  @spec cleanup_expired_jobs() :: non_neg_integer()
  def cleanup_expired_jobs do
    now = DateTime.utc_now()

    {count, _} =
      Job
      |> where([j], j.expires_at < ^now)
      |> Repo.delete_all()

    count
  end

  @spec count_recent_jobs(String.t(), integer()) :: non_neg_integer()
  def count_recent_jobs(ip_hash, minutes) do
    cutoff = DateTime.add(DateTime.utc_now(), -minutes, :minute)

    Job
    |> where([j], j.ip_hash == ^ip_hash and j.inserted_at > ^cutoff)
    |> Repo.aggregate(:count)
  end
end
