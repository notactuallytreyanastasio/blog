defmodule BlogWeb.ReceiptMessageLive do
  use BlogWeb, :live_view
  alias Blog.ReceiptMessages

  @impl true
  def mount(_params, session, socket) do
    sender_ip = get_ip_from_socket_or_session(socket, session)

    {:ok,
     socket
     |> assign(:page_title, "Send me a very direct message. To my desk..")
     |> assign(:page_description, "Want to send Bobby a VERY direct message? Get it to his desk right now. This page will allow you to send text and images directly to the receipt printer sitting next to his laptops on his desk at home in New York City. Please be kind. The service will be shut off if someone tries to send anything hurtful, offensive, or mean. I love you, have fun.")
     |> assign(:page_image, "https://www.bobbby.online/images/og-image.png")
     |> assign(:message, "")
     |> assign(:sender_ip, sender_ip)
     |> assign(:uploaded_files, [])
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    message = Map.get(params, "message", socket.assigns.message)
    {:noreply, assign(socket, :message, message)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    # Get sender IP from assigns (already set during mount)
    sender_ip = socket.assigns.sender_ip

    # Handle uploaded image if any
    {image_data, content_type} = consume_uploaded_image(socket)

    # Create the message with image binary data
    attrs = %{
      content: message,
      sender_ip: sender_ip,
      status: "pending"
    }

    # Add image data if present
    attrs = if image_data do
      Map.merge(attrs, %{
        image_data: image_data,
        image_content_type: content_type
      })
    else
      attrs
    end

    case ReceiptMessages.create_receipt_message(attrs) do
      {:ok, _message} ->
        {:noreply,
         socket
         |> put_flash(:info, "Message sent successfully! It will print on my desk soon.")
         |> assign(:message, "")
         |> assign(:uploaded_files, [])}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to send message. Please try again.")
         |> assign(:message, "")}
    end
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  defp get_ip_from_socket_or_session(socket, session) do
    # First try to get from connect_info if available
    ip_from_connect = case socket do
      %{private: %{connect_info: %{peer_data: %{address: address}}}} ->
        format_ip(address)
      %{private: %{connect_info: %{x_headers: headers}}} ->
        get_ip_from_headers(headers)
      _ ->
        nil
    end

    # Fall back to session if connect_info not available
    ip_from_connect || Map.get(session, "remote_ip", "unknown")
  end

  defp format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"
  defp format_ip({a, b, c, d, e, f, g, h}) do
    "#{Integer.to_string(a, 16)}:#{Integer.to_string(b, 16)}:#{Integer.to_string(c, 16)}:#{Integer.to_string(d, 16)}:#{Integer.to_string(e, 16)}:#{Integer.to_string(f, 16)}:#{Integer.to_string(g, 16)}:#{Integer.to_string(h, 16)}"
  end
  defp format_ip(_), do: nil

  defp get_ip_from_headers(headers) do
    case List.keyfind(headers, "x-forwarded-for", 0) do
      {"x-forwarded-for", value} ->
        value
        |> String.split(",")
        |> List.first()
        |> String.trim()
      _ ->
        nil
    end
  end

  defp consume_uploaded_image(socket) do
    case socket.assigns.uploads.image.entries do
      [] ->
        {nil, nil}
      _entries ->
        # Process the uploaded image and return binary data
        result = consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
          # Read the file content as binary
          image_binary = File.read!(path)

          # Determine content type from the file extension
          content_type = case Path.extname(entry.client_name) |> String.downcase() do
            ".jpg" -> "image/jpeg"
            ".jpeg" -> "image/jpeg"
            ".png" -> "image/png"
            ".gif" -> "image/gif"
            _ -> "image/jpeg"  # Default to JPEG
          end

          {:ok, {image_binary, content_type}}
        end)

        case result do
          [{image_binary, content_type} | _] -> {image_binary, content_type}
          _ -> {nil, nil}
        end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="os-desktop-mac">
      <div class="os-window os-window-mac" style="width: 100%; height: calc(100vh - 40px); max-width: none;">
        <div class="os-titlebar">
          <a href="/" class="os-btn-close"></a>
          <span class="os-titlebar-title">Receipt Printer - Direct Message</span>
        </div>
        <div class="os-content" style="height: calc(100% - 50px); overflow-y: auto;">
    <div class="receipt-message-container">
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        body {
          font-family: Georgia, serif;
          background-color: #fdf6e3;
          min-height: 100vh;
          display: flex;
          flex-direction: column;
          align-items: center;
          padding: 40px 20px;
          color: #5d4e37;
        }

        .receipt-message-container {
          width: 100%;
          min-height: 100vh;
          background-color: #fdf6e3;
          display: flex;
          flex-direction: column;
          align-items: center;
          padding: 40px 20px;
          font-family: Georgia, serif;
          color: #5d4e37;
        }

        .typewriter-container {
          margin-bottom: 60px;
          margin-top: 100px;
          position: relative;
          animation: float 3s ease-in-out infinite;
        }

        @keyframes float {
          0%, 100% { transform: translateY(0px); }
          50% { transform: translateY(-10px); }
        }

        .typewriter {
          width: 320px;
          height: 180px;
          position: relative;
        }

        .typewriter-body {
          width: 100%;
          height: 140px;
          background-color: #6b5d4f;
          border-radius: 10px;
          position: absolute;
          bottom: 0;
          box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
        }

        .carriage {
          position: absolute;
          top: -20px;
          left: 50%;
          transform: translateX(-50%);
          width: 280px;
          height: 40px;
          background-color: #4a3f36;
          border-radius: 20px;
          box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .roller {
          position: absolute;
          top: 5px;
          left: 50%;
          transform: translateX(-50%);
          width: 260px;
          height: 30px;
          background-color: #2d2520;
          border-radius: 15px;
        }

        .paper {
          width: 220px;
          height: 140px;
          background-color: #fffef9;
          position: absolute;
          top: -120px;
          left: 50%;
          transform: translateX(-50%);
          box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
          padding: 30px 20px;
          font-family: 'Courier New', monospace;
          font-size: 18px;
          text-align: center;
          display: flex;
          align-items: center;
          justify-content: center;
          animation: paperSlide 2s ease-out;
          z-index: 1;
        }

        @keyframes paperSlide {
          from {
            top: -40px;
            opacity: 0;
          }
          to {
            top: -120px;
            opacity: 1;
          }
        }

        .paper::before,
        .paper::after {
          content: '';
          position: absolute;
          left: 15px;
          right: 15px;
          height: 1px;
          background-color: #e0d5c7;
        }

        .paper::before {
          top: 25px;
        }

        .paper::after {
          bottom: 25px;
        }

        .keyboard {
          position: absolute;
          bottom: 20px;
          left: 50%;
          transform: translateX(-50%);
          width: 280px;
          height: 80px;
          background-color: #4a3f36;
          border-radius: 8px;
          padding: 10px;
          box-shadow: inset 0 2px 5px rgba(0, 0, 0, 0.3);
        }

        .key-row {
          display: flex;
          justify-content: center;
          gap: 4px;
          margin-bottom: 4px;
        }

        .key {
          width: 22px;
          height: 22px;
          background-color: #f4e4c1;
          border-radius: 50%;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
          position: relative;
        }

        .key::after {
          content: '';
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          width: 12px;
          height: 12px;
          background-color: #2d2520;
          border-radius: 50%;
        }

        .space-bar {
          width: 120px;
          height: 18px;
          background-color: #f4e4c1;
          border-radius: 9px;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
          margin: 0 auto;
        }

        .side-panel {
          position: absolute;
          width: 30px;
          height: 100px;
          background-color: #8b7355;
          bottom: 10px;
          border-radius: 5px;
        }

        .side-panel.left {
          left: 10px;
        }

        .side-panel.right {
          right: 10px;
        }

        .message-form {
          width: 100%;
          max-width: 500px;
          background-color: #fff8e7;
          padding: 40px;
          border-radius: 20px;
          box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
        }

        .form-title {
          font-size: 24px;
          color: #8b7355;
          margin-bottom: 25px;
          text-align: center;
          font-weight: normal;
        }

        .message-input {
          width: 100%;
          min-height: 150px;
          padding: 15px;
          border: 2px solid #e0d5c7;
          border-radius: 10px;
          font-family: Georgia, serif;
          font-size: 16px;
          resize: vertical;
          background-color: #fffef9;
          color: #5d4e37;
          transition: border-color 0.3s ease;
        }

        .message-input:focus {
          outline: none;
          border-color: #d4a574;
        }

        .message-input::placeholder {
          color: #b8a590;
        }

        .button-container {
          display: flex;
          gap: 15px;
          margin-top: 20px;
        }

        .image-button, .send-button {
          padding: 12px 25px;
          border: none;
          border-radius: 8px;
          font-size: 16px;
          cursor: pointer;
          transition: all 0.3s ease;
          font-family: Georgia, serif;
        }

        .image-button {
          background-color: #f4e4c1;
          color: #8b7355;
          flex: 0 0 auto;
          display: flex;
          align-items: center;
          gap: 8px;
        }

        .image-button:hover {
          background-color: #e8d4a9;
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .send-button {
          background-color: #d4a574;
          color: white;
          flex: 1;
          font-weight: bold;
        }

        .send-button:hover {
          background-color: #c69963;
          transform: translateY(-2px);
          box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
        }

        .send-button:disabled {
          background-color: #ccc;
          cursor: not-allowed;
        }

        .image-icon {
          width: 20px;
          height: 20px;
        }

        .typewriter-text {
          overflow: hidden;
          white-space: nowrap;
          animation: typing 2s steps(30, end);
        }

        @keyframes typing {
          from { width: 0; }
          to { width: 100%; }
        }
      </style>

      <div class="typewriter-container">
        <div class="typewriter">
          <div class="typewriter-body">
            <div class="carriage">
              <div class="roller"></div>
            </div>
            <div class="side-panel left"></div>
            <div class="side-panel right"></div>
            <div class="keyboard">
              <div class="key-row">
                <%= for _ <- 1..10 do %>
                  <div class="key"></div>
                <% end %>
              </div>
              <div class="key-row">
                <%= for _ <- 1..9 do %>
                  <div class="key"></div>
                <% end %>
              </div>
              <div class="space-bar"></div>
            </div>
          </div>
          <div class="paper">
            <div class="typewriter-text">Send me a message</div>
          </div>
        </div>
      </div>

      <form class="message-form" phx-submit="send_message" phx-change="validate">
        <h2 class="form-title">Write your message below</h2>
        <textarea
          class="message-input"
          name="message"
          placeholder="Type your message here...please leave your name or handle, its anonymous otherwise"
          phx-debounce="100"
        ><%= @message %></textarea>

        <div class="button-container">
          <label class="image-button">
            <svg class="image-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
              <circle cx="8.5" cy="8.5" r="1.5"></circle>
              <polyline points="21 15 16 10 5 21"></polyline>
            </svg>
            Add Image
            <.live_file_input upload={@uploads.image} style="display: none;" />
          </label>
          
          <button class="send-button" type="submit" disabled={@message == ""}>
            Send Message
          </button>
        </div>
        
        <%= for entry <- @uploads.image.entries do %>
          <div>
            <%= entry.client_name %>
            <button type="button" phx-click="cancel-upload" phx-value-ref={entry.ref}>Cancel</button>
          </div>
        <% end %>
      </form>
    </div>
        </div>
        <div class="os-statusbar">
          <span>Ready to send</span>
          <span>Characters: {String.length(@message)}</span>
        </div>
      </div>
    </div>
    """
  end
end
