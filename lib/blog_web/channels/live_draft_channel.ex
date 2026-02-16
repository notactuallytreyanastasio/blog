defmodule BlogWeb.LiveDraftChannel do
  use Phoenix.Channel
  require Logger

  @impl true
  def join("live_draft:" <> slug, %{"token" => token}, socket) do
    expected = Application.get_env(:blog, :live_draft_api_token)

    if token == expected && token != nil do
      Logger.info("[LiveDraft] Author joined channel for #{slug}")
      {:ok, assign(socket, :slug, slug)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("live_draft:" <> _slug, _params, _socket) do
    {:error, %{reason: "missing token"}}
  end

  @impl true
  def handle_in("draft:update", %{"content" => content}, socket) do
    slug = socket.assigns.slug
    {:ok, _html} = Blog.LiveDraft.update(slug, content)
    {:reply, :ok, socket}
  end

  @impl true
  def handle_in("draft:diff", %{"ops" => ops}, socket) do
    slug = socket.assigns.slug
    {:ok, _html} = Blog.LiveDraft.apply_diff(slug, ops)
    {:reply, :ok, socket}
  end

  @impl true
  def handle_in("draft:clear", _params, socket) do
    slug = socket.assigns.slug
    Blog.LiveDraft.clear(slug)
    {:reply, :ok, socket}
  end
end
