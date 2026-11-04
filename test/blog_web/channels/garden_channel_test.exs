defmodule BlogWeb.GardenChannelTest do
  use BlogWeb.ChannelCase

  defp join_room(room, name) do
    {:ok, reply, socket} =
      BlogWeb.UserSocket
      |> socket(nil, %{})
      |> subscribe_and_join(BlogWeb.GardenChannel, "garden:" <> room, %{"name" => name})

    {reply, socket}
  end

  test "join replies with an id and pushes presence including the joiner" do
    {%{id: id}, _socket} = join_room("t1", "alice")
    assert_push "presence_state", state
    assert %{metas: [%{name: "alice", joined_at: _}]} = state[id]
  end

  test "relays player state to others, tagged with the sender" do
    {%{id: a}, sa} = join_room("t2", "a")
    {_, _sb} = join_room("t2", "b")
    push(sa, "p", %{"x" => 1.5})
    assert_broadcast "p", %{"x" => 1.5, "from" => ^a}
  end

  test "ignores unknown events" do
    {_, s} = join_room("t3", "a")
    ref = push(s, "nuke", %{})
    refute_reply ref, _
  end

  test "caps a room at four players" do
    for n <- 1..4, do: join_room("t4", "p#{n}")

    assert {:error, %{reason: "room_full"}} =
             BlogWeb.UserSocket
             |> socket(nil, %{})
             |> subscribe_and_join(BlogWeb.GardenChannel, "garden:t4", %{})
  end

  test "rejects an empty room name" do
    assert {:error, %{reason: "bad_room"}} =
             BlogWeb.UserSocket |> socket(nil, %{}) |> subscribe_and_join(BlogWeb.GardenChannel, "garden:", %{})
  end
end
