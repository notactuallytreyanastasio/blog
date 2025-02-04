defmodule BlogWeb.SkeetChannel do
  use Phoenix.Channel
  require Logger

  @max_body_length 250
  @max_handle_length 16
  @table_name :skeet_messages

  def join("skeet:lobby", _params, socket) do
    # Create ETS table if it doesn't exist
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
    {:ok, socket}
  rescue
    ArgumentError ->
      # Table already exists
      {:ok, socket}
  end

  def handle_in("new_message", %{"body" => body, "user" => user, "reply_to" => reply_to}, socket) do
    with {:ok, body} <- validate_body(body),
         {:ok, user} <- validate_user(user),
         {:ok, reply_to} <- validate_reply_to(reply_to) do

      message = %{
        id: generate_sha(),
        body: body,
        user: user,
        reply_to: reply_to,
        created_at: DateTime.utc_now()
      }

      :ets.insert(@table_name, {message.id, message})
      broadcast!(socket, "new_message", message)

      {:reply, {:ok, message}, socket}
    else
      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end

  defp validate_body(body) when is_binary(body) do
    if String.length(body) <= @max_body_length do
      {:ok, body}
    else
      {:error, "Body exceeds maximum length of #{@max_body_length} characters"}
    end
  end
  defp validate_body(_), do: {:error, "Body must be a string"}

  defp validate_user(user) when is_binary(user) do
    if String.length(user) <= @max_handle_length do
      {:ok, user}
    else
      {:error, "User handle exceeds maximum length of #{@max_handle_length} characters"}
    end
  end
  defp validate_user(_), do: {:error, "User handle must be a string"}

  defp validate_reply_to(nil), do: {:ok, nil}
  defp validate_reply_to(reply_to) when is_binary(reply_to), do: {:ok, reply_to}
  defp validate_reply_to(_), do: {:error, "Reply_to must be nil or a string"}

  defp generate_sha do
    :crypto.strong_rand_bytes(20)
    |> Base.encode16(case: :lower)
  end
end
