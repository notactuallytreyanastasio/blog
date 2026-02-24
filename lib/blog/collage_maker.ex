defmodule Blog.CollageMaker do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.CollageMaker.{Collage, Image}

  def create_collage(attrs) do
    %Collage{}
    |> Collage.changeset(attrs)
    |> Repo.insert()
  end

  def get_collage!(id), do: Repo.get!(Collage, id)

  def get_collage(id), do: Repo.get(Collage, id)

  def get_collage_by_token(token) do
    Repo.get_by(Collage, share_token: token)
  end

  def update_collage(%Collage{} = collage, attrs) do
    collage
    |> Collage.changeset(attrs)
    |> Repo.update()
  end

  def add_image(attrs) do
    %Image{}
    |> Image.changeset(attrs)
    |> Repo.insert()
  end

  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  def list_images(collage_id) do
    from(i in Image, where: i.collage_id == ^collage_id, order_by: i.position)
    |> Repo.all()
  end

  def cleanup_expired do
    now = DateTime.utc_now()

    expired =
      from(c in Collage,
        where: c.expires_at < ^now,
        select: c
      )
      |> Repo.all()

    Enum.each(expired, fn collage ->
      images = list_images(collage.id)

      Enum.each(images, fn img ->
        if img.original_s3_key, do: Blog.Storage.delete(img.original_s3_key)
        if img.cropped_s3_key, do: Blog.Storage.delete(img.cropped_s3_key)
      end)

      if collage.collage_s3_key, do: Blog.Storage.delete(collage.collage_s3_key)

      Repo.delete(collage)
    end)

    length(expired)
  end

  def count_recent(ip_hash, minutes) do
    cutoff = DateTime.add(DateTime.utc_now(), -minutes * 60, :second)

    from(c in Collage,
      where: c.ip_hash == ^ip_hash and c.inserted_at > ^cutoff
    )
    |> Repo.aggregate(:count)
  end
end
