defmodule Blog.ReceiptMessages do
  @moduledoc """
  The ReceiptMessages context.
  """

  import Ecto.Query, warn: false
  alias Blog.Repo
  alias Blog.ReceiptMessage

  @doc """
  Returns the list of receipt_messages.
  """
  def list_receipt_messages do
    Repo.all(ReceiptMessage)
  end

  @doc """
  Returns the list of pending receipt_messages.
  """
  def list_pending_messages do
    ReceiptMessage
    |> where([m], m.status == "pending")
    |> order_by([m], asc: m.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single receipt_message.
  """
  def get_receipt_message!(id), do: Repo.get!(ReceiptMessage, id)

  @doc """
  Creates a receipt_message.
  """
  def create_receipt_message(attrs \\ %{}) do
    %ReceiptMessage{}
    |> ReceiptMessage.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, message} ->
        # Trigger printing asynchronously
        Task.start(fn ->
          try do
            Blog.ReceiptPrinter.MessageHandler.print_message(message)
          rescue
            e ->
              require Logger
              Logger.error("Failed to print message: #{inspect(e)}")
          end
        end)
        
        {:ok, message}
        
      error ->
        error
    end
  end

  @doc """
  Updates a receipt_message.
  """
  def update_receipt_message(%ReceiptMessage{} = receipt_message, attrs) do
    receipt_message
    |> ReceiptMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Marks a message as printed.
  """
  def mark_as_printed(%ReceiptMessage{} = receipt_message) do
    update_receipt_message(receipt_message, %{
      status: "printed",
      printed_at: DateTime.utc_now()
    })
  end

  @doc """
  Marks a message as failed.
  """
  def mark_as_failed(%ReceiptMessage{} = receipt_message) do
    update_receipt_message(receipt_message, %{status: "failed"})
  end

  @doc """
  Deletes a receipt_message.
  """
  def delete_receipt_message(%ReceiptMessage{} = receipt_message) do
    Repo.delete(receipt_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking receipt_message changes.
  """
  def change_receipt_message(%ReceiptMessage{} = receipt_message, attrs \\ %{}) do
    ReceiptMessage.changeset(receipt_message, attrs)
  end
end