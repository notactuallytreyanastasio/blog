defmodule Blog.Blinks.CommentReaction do
  @moduledoc "One device's emoji on one comment."
  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "blink_comment_reactions" do
    field :comment_id, :integer
    field :emoji, :string
    field :device_hash, :string

    timestamps()
  end
end
