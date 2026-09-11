defmodule Blog.Blinks.BlinkSave do
  @moduledoc "An anonymous device bookmarked a blink — powers save counts + Popular."
  use Ecto.Schema

  @type t :: %__MODULE__{}

  schema "blink_saves" do
    field :blink_id, :integer
    field :device_hash, :string

    timestamps()
  end
end
