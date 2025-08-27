defmodule Blog.Repo.Migrations.AddImageDataToReceiptMessages do
  use Ecto.Migration

  def change do
    alter table(:receipt_messages) do
      add :image_data, :binary
      add :image_content_type, :string
    end
  end
end