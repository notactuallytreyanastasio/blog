defmodule BlogWeb.ReceiptMessageLive do
  use BlogWeb, :live_view
  alias Blog.ReceiptMessages

  @content_types %{
    ".jpg" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".png" => "image/png",
    ".gif" => "image/gif"
  }

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
     |> assign(:show_queue, false)
     |> assign(:queue_messages, [])
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png .gif), max_entries: 1)}
  end

  @impl true
  def handle_event("validate", params, socket) do
    message = Map.get(params, "message", socket.assigns.message)
    {:noreply, assign(socket, :message, message)}
  end

  @impl true
  def handle_event("send_message", %{"message" => message}, socket) do
    attrs = build_message_attrs(message, socket.assigns.sender_ip)
    {image_data, content_type} = consume_uploaded_image(socket)
    attrs = maybe_add_image(attrs, image_data, content_type)

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
  def handle_event("toggle_queue", _params, socket) do
    show = !socket.assigns.show_queue
    messages = if show, do: ReceiptMessages.list_recent_messages(10), else: []
    {:noreply, socket |> assign(:show_queue, show) |> assign(:queue_messages, messages)}
  end

  @impl true
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :image, ref)}
  end

  # Pure functions - testable without LiveView

  @doc """
  Builds the base message attributes map from content and sender IP.
  """
  def build_message_attrs(content, sender_ip) do
    %{content: content, sender_ip: sender_ip, status: "pending"}
  end

  @doc """
  Adds image data to message attributes if present.
  """
  def maybe_add_image(attrs, nil, _content_type), do: attrs

  def maybe_add_image(attrs, image_data, content_type) do
    Map.merge(attrs, %{image_data: image_data, image_content_type: content_type})
  end

  @doc """
  Determines the content type for an uploaded file based on its extension.
  Returns \"image/jpeg\" as a default for unrecognized extensions.
  """
  def content_type_for_extension(filename) when is_binary(filename) do
    ext = filename |> Path.extname() |> String.downcase()
    Map.get(@content_types, ext, "image/jpeg")
  end

  @doc """
  Formats an IP address tuple into a human-readable string.

  Supports IPv4 (4-element tuple) and IPv6 (8-element tuple).
  Returns nil for unrecognized formats.
  """
  def format_ip(address)
  def format_ip({a, b, c, d}), do: "#{a}.#{b}.#{c}.#{d}"

  def format_ip({a, b, c, d, e, f, g, h}) do
    [a, b, c, d, e, f, g, h]
    |> Enum.map_join(":", &Integer.to_string(&1, 16))
  end

  def format_ip(_), do: nil

  @doc """
  Extracts the first IP from an x-forwarded-for header value list.
  """
  def extract_forwarded_ip(headers) when is_list(headers) do
    case List.keyfind(headers, "x-forwarded-for", 0) do
      {"x-forwarded-for", value} ->
        value |> String.split(",") |> List.first() |> String.trim()

      _ ->
        nil
    end
  end

  # Private helpers

  defp get_ip_from_socket_or_session(socket, session) do
    ip_from_connect =
      case socket do
        %{private: %{connect_info: %{peer_data: %{address: address}}}} ->
          format_ip(address)

        %{private: %{connect_info: %{x_headers: headers}}} ->
          extract_forwarded_ip(headers)

        _ ->
          nil
      end

    ip_from_connect || Map.get(session, "remote_ip", "unknown")
  end

  defp consume_uploaded_image(socket) do
    case socket.assigns.uploads.image.entries do
      [] ->
        {nil, nil}

      _entries ->
        result =
          consume_uploaded_entries(socket, :image, fn %{path: path}, entry ->
            image_binary = File.read!(path)
            content_type = content_type_for_extension(entry.client_name)
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
      <div class="os-window os-window-mac" id="dm-window" phx-hook="Draggable" style="width: 90vw; max-width: 1100px;">
        <div class="os-titlebar">
          <a href="/" class="os-btn-close"></a>
          <span class="os-titlebar-title">Very Direct Message</span>
        </div>
        <div class="os-content" style="overflow-y: auto; max-height: calc(100vh - 100px);">
    <div class="receipt-message-container">
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
          <button class="image-button queue-button" type="button" phx-click="toggle_queue">
            <svg class="queue-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <line x1="8" y1="6" x2="21" y2="6"></line>
              <line x1="8" y1="12" x2="21" y2="12"></line>
              <line x1="8" y1="18" x2="21" y2="18"></line>
              <line x1="3" y1="6" x2="3.01" y2="6"></line>
              <line x1="3" y1="12" x2="3.01" y2="12"></line>
              <line x1="3" y1="18" x2="3.01" y2="18"></line>
            </svg>
            <%= if @show_queue, do: "Hide Queue", else: "View Queue" %>
          </button>
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

        <%= if @show_queue do %>
          <div class="queue-panel">
            <div class="queue-header">Recent Messages</div>
            <%= if @queue_messages == [] do %>
              <div class="queue-empty">No messages yet</div>
            <% else %>
              <%= for msg <- @queue_messages do %>
                <div class="queue-item">
                  <div class="queue-item-content"><%= msg.content %></div>
                  <div class="queue-item-meta">
                    <span><%= msg.status %></span>
                    <span><%= Calendar.strftime(msg.inserted_at, "%b %d, %I:%M %p") %></span>
                  </div>
                </div>
              <% end %>
            <% end %>
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
