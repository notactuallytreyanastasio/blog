# defmodule Blog.Social.Sparkle do
#   use Ecto.Schema
#   import Ecto.Changeset
#   import Ecto.Query
#
#   schema "sparkles" do
#     field :content, :string
#     field :author, :string
#
#     belongs_to :parent_sparkle, Blog.Social.Sparkle, foreign_key: :sparkle_id
#     belongs_to :root_sparkle, Blog.Social.Sparkle, foreign_key: :root_sparkle_id
#     has_many :replies, Blog.Social.Sparkle, foreign_key: :sparkle_id
#
#     timestamps()
#   end
#
#   def changeset(sparkle, attrs) do
#     sparkle
#     |> cast(attrs, [:content, :author, :sparkle_id, :root_sparkle_id])
#     |> validate_required([:content, :author])
#     |> validate_length(:content, max: 280)
#     |> validate_length(:author, max: 50)
#     |> foreign_key_constraint(:sparkle_id)
#     |> foreign_key_constraint(:root_sparkle_id)
#   end
# end
#
