defmodule Blog.ReceiptMessage do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          content: String.t() | nil,
          sender_name: String.t() | nil,
          sender_ip: String.t() | nil,
          image_url: String.t() | nil,
          image_data: binary() | nil,
          image_content_type: String.t() | nil,
          printed_at: DateTime.t() | nil,
          status: String.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          updated_at: NaiveDateTime.t() | nil
        }

  schema "receipt_messages" do
    field :content, :string
    field :sender_name, :string
    field :sender_ip, :string
    field :image_url, :string
    field :image_data, :binary
    field :image_content_type, :string
    field :printed_at, :utc_datetime
    field :status, :string, default: "pending"

    timestamps()
  end

  @doc false
  @spec changeset(t() | Ecto.Changeset.t(), map()) :: Ecto.Changeset.t()
  def changeset(receipt_message, attrs) do
    receipt_message
    |> cast(attrs, [:content, :sender_name, :sender_ip, :image_url, :image_data, :image_content_type, :status, :printed_at])
    |> validate_required([:content])
    |> validate_inclusion(:status, ["pending", "printed", "failed"])
  end
end