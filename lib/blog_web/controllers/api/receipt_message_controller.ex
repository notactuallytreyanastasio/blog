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

  defp format_message(%ReceiptMessage{} = msg) do
    # Build the complete receipt data including any images
    receipt_data = build_receipt_binary(msg)
    
    # Include image data if present
    response = %{
      id: msg.id,
      content: msg.content,
      sender_name: msg.sender_name,
      sender_ip: msg.sender_ip,
      image_url: msg.image_url,
      status: msg.status,
      created_at: msg.inserted_at,
      printed_at: msg.printed_at,
      receipt_data: Base.encode64(receipt_data)  # Base64 encode for JSON transport
    }
    
    # Add image data if present
    if msg.image_data && byte_size(msg.image_data) > 0 do
      Map.merge(response, %{
        image_data: Base.encode64(msg.image_data),
        image_content_type: msg.image_content_type
      })
    else
      response
    end
  end
  
  defp build_receipt_binary(msg) do
    alias ReceiptPrinter.{ReceiptBuilder, ImageProcessor}
    
    # Build the receipt with proper formatting
    builder = ReceiptBuilder.new()
    |> ReceiptBuilder.init()
    |> ReceiptBuilder.align(:center)
    |> ReceiptBuilder.text("========================")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.font_size(:double)
    |> ReceiptBuilder.text("NEW MESSAGE")
    |> ReceiptBuilder.font_size(:normal)
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("========================")
    |> ReceiptBuilder.line_feed(2)
    |> ReceiptBuilder.align(:left)
    |> ReceiptBuilder.text("From: #{msg.sender_ip || "unknown"}")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("Time: #{format_datetime(msg.inserted_at)}")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("--------------------------------")
    |> ReceiptBuilder.line_feed(2)
    |> ReceiptBuilder.bold(true)
    |> ReceiptBuilder.text("Message:")
    |> ReceiptBuilder.bold(false)
    |> ReceiptBuilder.line_feed()
    
    # Add message content with indentation
    builder = msg.content
    |> String.split("\n")
    |> Enum.reduce(builder, fn line, acc ->
      acc
      |> ReceiptBuilder.text("  #{line}")
      |> ReceiptBuilder.line_feed()
    end)
    |> ReceiptBuilder.line_feed()
    
    # Add image if present (now checking for binary image data)
    builder = if msg.image_data && byte_size(msg.image_data) > 0 do
      # Process the binary image data
      case ImageProcessor.process_image_binary(msg.image_data, width: 384) do
        {:ok, bitmap_data} ->
          builder
          |> ReceiptBuilder.text("--------------------------------")
          |> ReceiptBuilder.line_feed()
          |> ReceiptBuilder.align(:center)
          |> ReceiptBuilder.text("[Image]")
          |> ReceiptBuilder.line_feed()
          |> ReceiptBuilder.raw(bitmap_data)
          |> ReceiptBuilder.line_feed(2)
          |> ReceiptBuilder.align(:left)
        _ ->
          # Fallback to checking image_url if exists
          if msg.image_url && msg.image_url != "" && File.exists?(msg.image_url) do
            case ImageProcessor.process_image(msg.image_url, width: 384) do
              {:ok, bitmap_data} ->
                builder
                |> ReceiptBuilder.text("--------------------------------")
                |> ReceiptBuilder.line_feed()
                |> ReceiptBuilder.align(:center)
                |> ReceiptBuilder.text("[Image]")
                |> ReceiptBuilder.line_feed()
                |> ReceiptBuilder.raw(bitmap_data)
                |> ReceiptBuilder.line_feed(2)
                |> ReceiptBuilder.align(:left)
              _ ->
                builder
            end
          else
            builder
          end
      end
    else
      builder
    end
    
    # Footer
    builder
    |> ReceiptBuilder.text("--------------------------------")
    |> ReceiptBuilder.line_feed(2)
    |> ReceiptBuilder.align(:center)
    |> ReceiptBuilder.text("Thank you for your message!")
    |> ReceiptBuilder.line_feed()
    |> ReceiptBuilder.text("ID: MSG#{String.pad_leading(to_string(msg.id), 6, "0")}")
    |> ReceiptBuilder.line_feed(4)
    |> ReceiptBuilder.cut(:partial)
    |> ReceiptBuilder.build()
  end
  
  defp format_datetime(nil), do: "Unknown"
  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
  end

  defp authorized?(token) do
    expected_token = Application.get_env(:blog, :receipt_printer_api_token)
    token == expected_token && token != nil
  end
end