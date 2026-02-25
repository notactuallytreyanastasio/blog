defmodule BlogWeb.ReceiptMessageLiveTest do
  use ExUnit.Case, async: true

  alias BlogWeb.ReceiptMessageLive

  # ── Pure function tests (no database required) ──────────────────

  describe "format_ip/1" do
    test "formats IPv4 tuple to dotted-decimal string" do
      assert ReceiptMessageLive.format_ip({127, 0, 0, 1}) == "127.0.0.1"
      assert ReceiptMessageLive.format_ip({192, 168, 1, 100}) == "192.168.1.100"
      assert ReceiptMessageLive.format_ip({0, 0, 0, 0}) == "0.0.0.0"
      assert ReceiptMessageLive.format_ip({255, 255, 255, 255}) == "255.255.255.255"
    end

    test "formats IPv6 tuple to colon-separated hex string" do
      assert ReceiptMessageLive.format_ip({0, 0, 0, 0, 0, 0, 0, 1}) == "0:0:0:0:0:0:0:1"

      assert ReceiptMessageLive.format_ip({8193, 3512, 0, 0, 0, 0, 0, 1}) ==
               "2001:DB8:0:0:0:0:0:1"
    end

    test "returns nil for unrecognized formats" do
      assert ReceiptMessageLive.format_ip("not a tuple") == nil
      assert ReceiptMessageLive.format_ip(nil) == nil
      assert ReceiptMessageLive.format_ip({1, 2, 3}) == nil
    end
  end

  describe "content_type_for_extension/1" do
    test "maps known image extensions to MIME types" do
      assert ReceiptMessageLive.content_type_for_extension("photo.jpg") == "image/jpeg"
      assert ReceiptMessageLive.content_type_for_extension("photo.jpeg") == "image/jpeg"
      assert ReceiptMessageLive.content_type_for_extension("photo.png") == "image/png"
      assert ReceiptMessageLive.content_type_for_extension("photo.gif") == "image/gif"
    end

    test "is case-insensitive" do
      assert ReceiptMessageLive.content_type_for_extension("PHOTO.JPG") == "image/jpeg"
      assert ReceiptMessageLive.content_type_for_extension("image.PNG") == "image/png"
    end

    test "defaults to image/jpeg for unknown extensions" do
      assert ReceiptMessageLive.content_type_for_extension("file.bmp") == "image/jpeg"
      assert ReceiptMessageLive.content_type_for_extension("file.webp") == "image/jpeg"
    end
  end

  describe "build_message_attrs/2" do
    test "returns a map with content, sender_ip, and pending status" do
      attrs = ReceiptMessageLive.build_message_attrs("Hello!", "192.168.1.1")

      assert attrs == %{
               content: "Hello!",
               sender_ip: "192.168.1.1",
               status: "pending"
             }
    end

    test "handles empty content" do
      attrs = ReceiptMessageLive.build_message_attrs("", "10.0.0.1")
      assert attrs.content == ""
      assert attrs.status == "pending"
    end
  end

  describe "maybe_add_image/3" do
    test "returns attrs unchanged when image_data is nil" do
      attrs = %{content: "hi", status: "pending"}
      assert ReceiptMessageLive.maybe_add_image(attrs, nil, nil) == attrs
      assert ReceiptMessageLive.maybe_add_image(attrs, nil, "image/png") == attrs
    end

    test "merges image data and content type when image_data is present" do
      attrs = %{content: "hi", status: "pending"}
      image_data = <<0xFF, 0xD8, 0xFF>>

      result = ReceiptMessageLive.maybe_add_image(attrs, image_data, "image/jpeg")

      assert result.content == "hi"
      assert result.status == "pending"
      assert result.image_data == image_data
      assert result.image_content_type == "image/jpeg"
    end
  end

  describe "extract_forwarded_ip/1" do
    test "extracts the first IP from x-forwarded-for header" do
      headers = [{"x-forwarded-for", "203.0.113.50, 70.41.3.18, 150.172.238.178"}]
      assert ReceiptMessageLive.extract_forwarded_ip(headers) == "203.0.113.50"
    end

    test "trims whitespace from extracted IP" do
      headers = [{"x-forwarded-for", "  10.0.0.1  , 192.168.1.1"}]
      assert ReceiptMessageLive.extract_forwarded_ip(headers) == "10.0.0.1"
    end

    test "handles single IP in header" do
      headers = [{"x-forwarded-for", "172.16.0.1"}]
      assert ReceiptMessageLive.extract_forwarded_ip(headers) == "172.16.0.1"
    end

    test "returns nil when x-forwarded-for header is missing" do
      assert ReceiptMessageLive.extract_forwarded_ip([]) == nil
      assert ReceiptMessageLive.extract_forwarded_ip([{"x-real-ip", "1.2.3.4"}]) == nil
    end
  end

  # ── Composition tests ───────────────────────────────────────────

  describe "build_message_attrs + maybe_add_image composition" do
    test "builds a complete message with image data" do
      attrs =
        ReceiptMessageLive.build_message_attrs("Hello with image", "10.0.0.1")
        |> ReceiptMessageLive.maybe_add_image(<<0xFF>>, "image/png")

      assert attrs.content == "Hello with image"
      assert attrs.sender_ip == "10.0.0.1"
      assert attrs.status == "pending"
      assert attrs.image_data == <<0xFF>>
      assert attrs.image_content_type == "image/png"
    end

    test "builds a text-only message when no image" do
      attrs =
        ReceiptMessageLive.build_message_attrs("Text only", "10.0.0.1")
        |> ReceiptMessageLive.maybe_add_image(nil, nil)

      assert attrs == %{content: "Text only", sender_ip: "10.0.0.1", status: "pending"}
      refute Map.has_key?(attrs, :image_data)
    end
  end
end

defmodule BlogWeb.ReceiptMessageLive.IntegrationTest do
  use BlogWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  @moduletag :db

  describe "mount" do
    test "renders the page with form elements", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/very_direct_message")

      assert html =~ "Very Direct Message"
      assert html =~ "Write your message below"
      assert html =~ "Send Message"
      assert html =~ "View Queue"
      assert html =~ "Add Image"
      assert html =~ "phx-submit=\"send_message\""
      assert html =~ "phx-change=\"validate\""
    end

    test "displays typewriter animation", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/very_direct_message")

      assert html =~ "typewriter-container"
      assert html =~ "Send me a message"
    end

    test "shows character count in status bar", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/very_direct_message")

      assert html =~ "Characters:"
      assert html =~ "Ready to send"
    end
  end

  describe "validate event" do
    test "updates the message assign on input", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/very_direct_message")

      html = render_change(view, "validate", %{"message" => "Hello printer!"})
      assert html =~ "Hello printer!"
    end
  end

  describe "send_message event" do
    test "creates a message and clears the form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/very_direct_message")

      render_change(view, "validate", %{"message" => "Test message for printer"})
      render_submit(view, "send_message", %{"message" => "Test message for printer"})

      html = render(view)
      refute html =~ "Test message for printer"
    end
  end

  describe "toggle_queue event" do
    test "shows queue panel when toggled on", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/very_direct_message")

      refute html =~ "queue-panel"

      html = render_click(view, "toggle_queue")
      assert html =~ "queue-panel"
      assert html =~ "Recent Messages"
      assert html =~ "Hide Queue"
    end

    test "hides queue panel when toggled off", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/very_direct_message")

      render_click(view, "toggle_queue")
      html = render_click(view, "toggle_queue")

      refute html =~ "queue-panel"
      assert html =~ "View Queue"
    end
  end
end
