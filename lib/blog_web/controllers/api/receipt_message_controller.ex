defmodule BlogWeb.Api.ReceiptMessageController do
  use BlogWeb, :controller
  alias Blog.ReceiptMessages
  alias Blog.ReceiptMessage

  def pending(conn, params) do
    auth_token = params["auth_token"] || get_req_header(conn, "x-auth-token") |> List.first()
    
    if authorized?(auth_token) do
      messages = ReceiptMessages.list_pending_messages()
      
      json(conn, %{
        status: "ok",
        messages: Enum.map(messages, &format_message/1)
      })
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid or missing auth token"})
    end
  end

  def mark_printed(conn, %{"id" => id} = params) do
    auth_token = params["auth_token"] || get_req_header(conn, "x-auth-token") |> List.first()
    
    if authorized?(auth_token) do
      message = ReceiptMessages.get_receipt_message!(id)
      
      case ReceiptMessages.mark_as_printed(message) do
        {:ok, updated_message} ->
          json(conn, %{
            status: "ok",
            message: format_message(updated_message)
          })
        
        {:error, _changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Failed to update message status"})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid or missing auth token"})
    end
  end

  def mark_failed(conn, %{"id" => id} = params) do
    auth_token = params["auth_token"] || get_req_header(conn, "x-auth-token") |> List.first()
    
    if authorized?(auth_token) do
      message = ReceiptMessages.get_receipt_message!(id)
      
      case ReceiptMessages.mark_as_failed(message) do
        {:ok, updated_message} ->
          json(conn, %{
            status: "ok",
            message: format_message(updated_message)
          })
        
        {:error, _changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Failed to update message status"})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid or missing auth token"})
    end
  end

  def mark_pending(conn, %{"id" => id} = params) do
    auth_token = params["auth_token"] || get_req_header(conn, "x-auth-token") |> List.first()

    if authorized?(auth_token) do
      message = ReceiptMessages.get_receipt_message!(id)

      case ReceiptMessages.update_receipt_message(message, %{status: "pending", printed_at: nil}) do
        {:ok, updated_message} ->
          json(conn, %{status: "ok", message: format_message(updated_message)})

        {:error, _changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> json(%{error: "Failed to reset message status"})
      end
    else
      conn
      |> put_status(:unauthorized)
      |> json(%{error: "Invalid or missing auth token"})
    end
  end

  defp format_message(%ReceiptMessage{} = msg) do
    response = %{
      id: msg.id,
      content: msg.content,
      sender_name: msg.sender_name,
      sender_ip: msg.sender_ip,
      image_url: msg.image_url,
      status: msg.status,
      created_at: msg.inserted_at,
      printed_at: msg.printed_at
    }

    if msg.image_data && byte_size(msg.image_data) > 0 do
      Map.merge(response, %{
        image_data: Base.encode64(msg.image_data),
        image_content_type: msg.image_content_type
      })
    else
      response
    end
  end

  defp authorized?(token) do
    expected_token = Application.get_env(:blog, :receipt_printer_api_token)
    token == expected_token && token != nil
  end
end