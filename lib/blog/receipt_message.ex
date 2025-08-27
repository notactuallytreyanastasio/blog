defmodule Blog.ReceiptMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "receipt_messages" do
    field :content, :string
    field :sender_name, :string
    field :sender_ip, :string
    field :image_url, :string
    field :printed_at, :utc_datetime
    field :status, :string, default: "pending"

    timestamps()
  end

  @doc false
  def changeset(receipt_message, attrs) do
    receipt_message
    |> cast(attrs, [:content, :sender_name, :sender_ip, :image_url, :status, :printed_at])
    |> validate_required([:content])
    |> validate_inclusion(:status, ["pending", "printed", "failed"])
  end
end