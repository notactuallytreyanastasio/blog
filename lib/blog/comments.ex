defmodule Blog.Comments do
  @moduledoc """
  Context module for blog post comments.
  """
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Comments.Comment

  @doc "List all comments for a post by slug, ordered by creation time"
  @spec list_comments(String.t()) :: [struct()]
  def list_comments(post_slug) do
    Comment
    |> where([c], c.post_slug == ^post_slug)
    |> order_by([c], asc: c.inserted_at)
    |> Repo.all()
  end

  @doc "Create a new comment"
  @spec create_comment(map()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def create_comment(attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  @doc "Get a comment by ID"
  @spec get_comment(term()) :: struct() | nil
  def get_comment(id), do: Repo.get(Comment, id)

  @doc "Delete a comment"
  @spec delete_comment(struct()) :: {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def delete_comment(%Comment{} = comment), do: Repo.delete(comment)

  @doc "Returns an empty changeset for form rendering"
  @spec change_comment(struct(), map()) :: Ecto.Changeset.t()
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
