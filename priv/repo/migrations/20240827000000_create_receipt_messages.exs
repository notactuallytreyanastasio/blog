defmodule Blog.Repo.Migrations.CreateReceiptMessages do
  use Ecto.Migration

  def change do
    create table(:receipt_messages) do
      add :content, :text, null: false
      add :sender_ip, :string
      add :image_url, :string
      add :status, :string, default: "pending"
      add :printed_at, :utc_datetime
      
      timestamps()
    end
    
    create index(:receipt_messages, [:status])
    create index(:receipt_messages, [:inserted_at])
  end
end