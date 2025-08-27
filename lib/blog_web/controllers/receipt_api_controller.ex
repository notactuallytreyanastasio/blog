defmodule BlogWeb.ReceiptApiController do
  use BlogWeb, :controller
  alias Blog.ReceiptMessages

  def pending_messages(conn, _params) do
    messages = ReceiptMessages.list_pending_messages()
    
    json(conn, %{
      status: "ok",
      messages: Enum.map(messages, &format_message/1)
    })
  end
  
  def mark_printed(conn, %{"id" => id}) do
    case ReceiptMessages.get_receipt_message!(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Message not found"})
      
      message ->
        case ReceiptMessages.mark_as_printed(message) do
          {:ok, updated_message} ->
            json(conn, %{
              status: "ok",
              message: format_message(updated_message)
            })
          
          {:error, _changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to update message"})
        end
    end
  end
  
  def mark_failed(conn, %{"id" => id}) do
    case ReceiptMessages.get_receipt_message!(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Message not found"})
      
      message ->
        case ReceiptMessages.mark_as_failed(message) do
          {:ok, updated_message} ->
            json(conn, %{
              status: "ok",
              message: format_message(updated_message)
            })
          
          {:error, _changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> json(%{error: "Failed to update message"})
        end
    end
  end
  
  defp format_message(message) do
    %{
      id: message.id,
      content: message.content,
      sender_name: message.sender_name,
      sender_ip: message.sender_ip,
      image_url: message.image_url,
      status: message.status,
      created_at: message.inserted_at
    }
  end
end