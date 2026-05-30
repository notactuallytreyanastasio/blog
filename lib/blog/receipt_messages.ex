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
  @spec list_receipt_messages() :: [Blog.ReceiptMessage.t()]
  def list_receipt_messages do
    Repo.all(ReceiptMessage)
  end

  @doc """
  Returns the list of pending receipt_messages.
  """
  @spec list_recent_messages(non_neg_integer()) :: [Blog.ReceiptMessage.t()]
  def list_recent_messages(limit \\ 10) do
    ReceiptMessage
    |> order_by([m], desc: m.inserted_at)
    |> limit(^limit)
    |> Repo.all()
  end

  @spec list_pending_messages() :: [Blog.ReceiptMessage.t()]
  def list_pending_messages do
    ReceiptMessage
    |> where([m], m.status == "pending")
    |> order_by([m], asc: m.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single receipt_message.
  """
  @spec get_receipt_message!(integer() | String.t()) :: Blog.ReceiptMessage.t()
  def get_receipt_message!(id), do: Repo.get!(ReceiptMessage, id)

  @doc """
  Gets a single receipt_message, returning nil if it does not exist.
  """
  @spec get_receipt_message(integer() | String.t()) :: Blog.ReceiptMessage.t() | nil
  def get_receipt_message(id), do: Repo.get(ReceiptMessage, id)

  @doc """
  Creates a receipt_message.
  """
  @spec create_receipt_message(map()) ::
          {:ok, Blog.ReceiptMessage.t()} | {:error, Ecto.Changeset.t()}
  def create_receipt_message(attrs \\ %{}) do
    %ReceiptMessage{}
    |> ReceiptMessage.changeset(attrs)
    |> Repo.insert()
    # Removed automatic printing - let the poller handle it
  end

  @doc """
  Updates a receipt_message.
  """
  @spec update_receipt_message(Blog.ReceiptMessage.t(), map()) ::
          {:ok, Blog.ReceiptMessage.t()} | {:error, Ecto.Changeset.t()}
  def update_receipt_message(%ReceiptMessage{} = receipt_message, attrs) do
    receipt_message
    |> ReceiptMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Marks a message as printed.
  """
  @spec mark_as_printed(Blog.ReceiptMessage.t()) ::
          {:ok, Blog.ReceiptMessage.t()} | {:error, Ecto.Changeset.t()}
  def mark_as_printed(%ReceiptMessage{} = receipt_message) do
    update_receipt_message(receipt_message, %{
      status: "printed",
      printed_at: DateTime.utc_now()
    })
  end

  @doc """
  Marks a message as failed.
  """
  @spec mark_as_failed(Blog.ReceiptMessage.t()) ::
          {:ok, Blog.ReceiptMessage.t()} | {:error, Ecto.Changeset.t()}
  def mark_as_failed(%ReceiptMessage{} = receipt_message) do
    update_receipt_message(receipt_message, %{status: "failed"})
  end

  @doc """
  Deletes a receipt_message.
  """
  @spec delete_receipt_message(Blog.ReceiptMessage.t()) ::
          {:ok, Blog.ReceiptMessage.t()} | {:error, Ecto.Changeset.t()}
  def delete_receipt_message(%ReceiptMessage{} = receipt_message) do
    Repo.delete(receipt_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking receipt_message changes.
  """
  @spec change_receipt_message(Blog.ReceiptMessage.t(), map()) :: Ecto.Changeset.t()
  def change_receipt_message(%ReceiptMessage{} = receipt_message, attrs \\ %{}) do
    ReceiptMessage.changeset(receipt_message, attrs)
  end
end