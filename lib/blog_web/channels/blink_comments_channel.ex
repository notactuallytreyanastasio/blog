defmodule BlogWeb.BlinkCommentsChannel do
  @moduledoc """
  Live feed for one blink's comment room ("blink_comments:<blink_id>").
  Read-only: posting goes through the rate-limited REST endpoint, whose
  PubSub broadcasts land in `handle_info` below (joining a channel already
  subscribes this process to its topic — no manual subscribe needed).
  Presence tracks anonymous joiners so the room can show "n here now".
  """
  use Phoenix.Channel

  alias BlogWeb.Presence

  @impl true
  def join("blink_comments:" <> blink_id, _params, socket) do
    case Integer.parse(blink_id) do
      {_id, ""} ->
        send(self(), :after_join)
        {:ok, socket}

      _ ->
        {:error, %{reason: "bad blink id"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    # Anonymous room: presence keys are opaque per-connection ids; clients
    # only ever count them.
    {:ok, _} = Presence.track(socket, "anon-#{System.unique_integer([:positive])}", %{})
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_info({:new_comment, comment}, socket) do
    push(socket, "new_comment", %{comment: comment})
    {:noreply, socket}
  end

  def handle_info({:reactions_updated, comment_id, reactions}, socket) do
    push(socket, "reactions_updated", %{id: comment_id, reactions: reactions})
    {:noreply, socket}
  end

  def handle_info({event, comment}, socket) when event in [:comment_hidden, :comment_deleted] do
    push(socket, Atom.to_string(event), %{id: comment.id})
    {:noreply, socket}
  end
end
