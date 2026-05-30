defmodule Blog.Content.Tag do
  @type t :: %__MODULE__{name: String.t() | nil}

  defstruct [:name]
end
