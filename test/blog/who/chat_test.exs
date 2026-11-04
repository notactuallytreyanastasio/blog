defmodule Blog.Who.ChatTest do
  @moduledoc """
  The prompt names tools by hand, so the first test pins prompt and tool
  surface together (marginalia shipped three releases promising two tools
  that did not exist). The rest run the tools without a model and the loop
  against a stubbed one.
  """
  use Blog.DataCase, async: false

  alias Blog.Who.Chat

  defp names, do: Enum.map(Chat.tools(), & &1["function"]["name"])

  defp call(name, args) do
    fun = %{"id" => "x", "function" => %{"name" => name, "arguments" => Jason.encode!(args)}}
    %{"role" => "tool", "tool_call_id" => "x", "content" => content} = Chat.run_call(fun)
    Jason.decode!(content)
  end

  test "every tool the prompt tells the model to call exists" do
    prompt = Chat.system_prompt()

    mentioned =
      Regex.scan(~r/\b([a-z]+_[a-z_]+)\b/, prompt)
      |> Enum.map(&List.last/1)
      |> Enum.uniq()
      |> Enum.reject(&(&1 in ~w(timey_wimey)))

    for m <- mentioned, m =~ ~r/^(search|node|the|doctor|chain|story|recall)/ do
      assert m in names(), "the prompt names #{m} but there is no such tool"
    end

    for n <- names() do
      assert prompt =~ n, "#{n} exists but the prompt never tells the model about it"
    end
  end

  describe "tools" do
    test "search_graph finds by words and says when it does not" do
      assert [%{"title" => "Blink - Sally Sparrow, timey-wimey, Angels"} | _] =
               call("search_graph", %{"query" => "Blink Sally Sparrow"})

      assert %{"result" => note} = call("search_graph", %{"query" => "zzzz"})
      assert note =~ "nothing in the graph"
    end

    test "the_doctors and doctor_stories agree" do
      doctors = call("the_doctors", %{})
      assert length(doctors) == 17

      out = call("doctor_stories", %{"doctor" => "Eccleston"})
      assert out["doctor"] =~ "Ninth Doctor"
      assert out["total"] > 0
      assert length(out["stories"]) <= 80

      assert %{"error" => e} = call("doctor_stories", %{"doctor" => "Bananaman"})
      assert e =~ "the_doctors"
    end

    test "node_neighbors and chain take an id and refuse a bad one" do
      [blink | _] = call("search_graph", %{"query" => "Blink Sally Sparrow"})
      n = call("node_neighbors", %{"id" => blink["id"]})
      assert n["title"] =~ "Blink"
      assert Enum.any?(n["outgoing"], &(&1["relation"] == "Doctor"))

      assert %{"error" => _} = call("node_neighbors", %{"id" => 999_999})
      assert %{"error" => _} = call("chain", %{"id" => 999_999})
    end

    test "story and search_stories read the wiki records" do
      s = call("story", %{"title" => "Blink"})
      assert s["writer"] == "Steven Moffat"
      assert s["synopsis"] =~ "Blink"
      assert s["wiki_url"] =~ "tardis.fandom.com"

      assert %{"error" => e} = call("story", %{"title" => "Shadowmind"})
      assert e =~ "search_graph"

      assert Enum.any?(call("search_stories", %{"query" => "Moffat Angels"}), &(&1["title"] == "Blink"))
    end

    test "the_doctors_decisions and the_eras are the graph's own layers" do
      assert Enum.any?(call("the_doctors_decisions", %{}), &(&1["title"] =~ "Daleks"))
      assert length(call("the_eras", %{})) == 5
    end

    test "recall_conversations searches what was said here before" do
      Blog.GraphChat.append("who", "v1", "c1", "assistant", "Blink is the best Tennant story")
      assert [%{"said" => said}] = call("recall_conversations", %{"query" => "best Tennant"})
      assert said =~ "Blink"
      assert %{"result" => _} = call("recall_conversations", %{"query" => "zzzz"})
    end

    test "an unknown tool is refused rather than crashing the loop" do
      assert %{"error" => "unknown tool"} = call("delete_everything", %{})
    end
  end

  describe "ask/2" do
    setup do
      prev = %{
        key: Application.get_env(:blog, :deepseek_api_key),
        req: Application.get_env(:blog, :llm_req_options)
      }

      Application.put_env(:blog, :deepseek_api_key, "test-key")
      Application.put_env(:blog, :llm_req_options, plug: {Req.Test, Blog.LLM}, retry: false)

      on_exit(fn ->
        Application.put_env(:blog, :deepseek_api_key, prev.key)
        Application.put_env(:blog, :llm_req_options, prev.req)
      end)

      :ok
    end

    defp completion(message) do
      %{"choices" => [%{"finish_reason" => "stop", "message" => message}]}
    end

    test "runs a tool call, feeds the result back, and returns the final content" do
      {:ok, turns} = Agent.start_link(fn -> [] end)

      Req.Test.stub(Blog.LLM, fn conn ->
        {:ok, raw, conn} = Plug.Conn.read_body(conn)
        body = Jason.decode!(raw)
        Agent.update(turns, &[body["messages"] | &1])

        case length(Agent.get(turns, & &1)) do
          1 ->
            Req.Test.json(
              conn,
              completion(%{
                "role" => "assistant",
                "content" => nil,
                "tool_calls" => [
                  %{
                    "id" => "call_1",
                    "type" => "function",
                    "function" => %{"name" => "story", "arguments" => ~s({"title":"Blink"})}
                  }
                ]
              })
            )

          _ ->
            Req.Test.json(conn, completion(%{"role" => "assistant", "content" => "Moffat wrote it."}))
        end
      end)

      assert {:ok, "Moffat wrote it."} = Chat.ask([%{"role" => "user", "content" => "who wrote Blink?"}])

      [second, first] = Agent.get(turns, & &1)
      assert hd(first)["role"] == "system"
      assert List.last(first)["content"] == "who wrote Blink?"

      tool_turn = Enum.find(second, &(&1["role"] == "tool"))
      assert tool_turn["tool_call_id"] == "call_1"
      assert Jason.decode!(tool_turn["content"])["writer"] == "Steven Moffat"
    end

    test "a missing key is explained in words the chat can show" do
      Application.put_env(:blog, :deepseek_api_key, nil)
      assert {:error, reason} = Chat.ask([])
      assert reason =~ "no DeepSeek Flash key"
    end

    test "a truncated reply is an error the chat can show" do
      Req.Test.stub(Blog.LLM, fn conn ->
        Req.Test.json(conn, %{
          "choices" => [%{"finish_reason" => "length", "message" => %{"content" => "half"}}]
        })
      end)

      assert {:error, reason} = Chat.ask([])
      assert reason =~ "cut off"
    end
  end
end
