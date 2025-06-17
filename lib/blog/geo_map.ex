defmodule Blog.GeoMap do
  @moduledoc """
  The GeoMap context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo

  alias Blog.TagIn # Using the schema we created at lib/blog/tag_in.ex

  @doc """
  Returns the list of tag_ins.

  ## Examples

      iex> list_tag_ins()
      [%TagIn{}, ...]

  """
  def list_tag_ins do
    Repo.all(TagIn)
  end

  @doc """
  Gets a single tag_in.

  Raises `Ecto.NoResultsError` if the Tag in does not exist.

  ## Examples

      iex> get_tag_in!(123)
      %TagIn{}

      iex> get_tag_in!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag_in!(id), do: Repo.get!(TagIn, id)

  @doc """
  Creates a tag_in.

  ## Examples

      iex> create_tag_in(%{field: value})
      {:ok, %TagIn{}} # Changed from :tag_in to :TagIn

      iex> create_tag_in(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag_in(attrs \\ %{}) do
    %TagIn{}
    |> TagIn.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag_in.

  ## Examples

      iex> update_tag_in(tag_in, %{field: new_value})
      {:ok, %TagIn{}} # Changed from :tag_in to :TagIn

      iex> update_tag_in(tag_in, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag_in(%TagIn{} = tag_in, attrs) do # Changed from :tag_in to :TagIn
    tag_in
    |> TagIn.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag_in.

  ## Examples

      iex> delete_tag_in(tag_in)
      {:ok, %TagIn{}} # Changed from :tag_in to :TagIn

      iex> delete_tag_in(tag_in)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag_in(%TagIn{} = tag_in) do # Changed from :tag_in to :TagIn
    Repo.delete(tag_in)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag_in changes.

  ## Examples

      iex> change_tag_in(tag_in)
      %Ecto.Changeset{data: %TagIn{}} # Changed from :tag_in to :TagIn

  """
  def change_tag_in(%TagIn{} = tag_in, attrs \\ %{}) do # Changed from :tag_in to :TagIn
    TagIn.changeset(tag_in, attrs)
  end
end
