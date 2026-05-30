defmodule Blog.Sky.Profile do
  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "sky_profiles" do
    field :handle, :string
    field :did, :string
    field :display_name, :string
    field :bio, :string
    field :avatar_url, :string
    field :followers_count, :integer, default: 0
    field :following_count, :integer, default: 0
    field :community_index, :integer
  end
end
