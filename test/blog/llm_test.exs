defmodule Blog.LLMTest do
  @moduledoc """
  The client's opinions, held against a stubbed provider: a truncated reply
  is an error, congestion retries and a bad request does not, and the body
  sent to DeepSeek is shaped the way DeepSeek wants it.
  """
  use ExUnit.Case, async: false

  alias Blog.LLM

  setup do
    prev = %{
      key: Application.get_env(:blog, :deepseek_api_key),
      openai: Application.get_env(:blog, :openai_api_key),
      provider: Application.get_env(:blog, :llm_provider),
      req: Application.get_env(:blog, :llm_req_options)
    }

    Application.put_env(:blog, :deepseek_api_key, "test-key")
    Application.put_env(:blog, :openai_api_key, "test-openai-key")
    Application.put_env(:blog, :llm_provider, "deepseek")
    Application.put_env(:blog, :llm_req_options, plug: {Req.Test, LLM}, retry: false)

    on_exit(fn ->
      Application.put_env(:blog, :deepseek_api_key, prev.key)
      Application.put_env(:blog, :openai_api_key, prev.openai)
      Application.put_env(:blog, :llm_provider, prev.provider)
      Application.put_env(:blog, :llm_req_options, prev.req)
    end)

    :ok
  end

  defp reply(conn, status, body) do
    conn |> Plug.Conn.put_status(status) |> Req.Test.json(body)
  end

  defp completion(message, finish \\ "stop") do
    %{"choices" => [%{"finish_reason" => finish, "message" => message}]}
  end

  defp sent_body(conn) do
    {:ok, raw, _conn} = Plug.Conn.read_body(conn)
    Jason.decode!(raw)
  end

  test "no key is its own error and nothing is sent" do
    Application.put_env(:blog, :deepseek_api_key, nil)
    Req.Test.stub(LLM, fn _conn -> flunk("should not have been called") end)
    assert {:error, :no_api_key} = LLM.chat(messages: [])
  end

  test "a reply is the assistant message" do
    Req.Test.stub(LLM, fn conn ->
      reply(conn, 200, completion(%{"role" => "assistant", "content" => "Allons-y"}))
    end)

    assert {:ok, %{"content" => "Allons-y"}} = LLM.chat(messages: [%{"role" => "user", "content" => "hi"}])
  end

  test "finish_reason length is a failure, not a short answer" do
    Req.Test.stub(LLM, fn conn ->
      reply(conn, 200, completion(%{"role" => "assistant", "content" => "Allons"}, "length"))
    end)

    assert {:error, :truncated} = LLM.chat(messages: [])
  end

  test "congestion retries three times and then says so" do
    {:ok, counter} = Agent.start_link(fn -> 0 end)

    Req.Test.stub(LLM, fn conn ->
      Agent.update(counter, &(&1 + 1))
      reply(conn, 429, %{"error" => "slow down"})
    end)

    assert {:error, :rate_limited} = LLM.chat(messages: [])
    assert Agent.get(counter, & &1) == 3
  end

  test "a bad request is reported once with its status and is not retried" do
    {:ok, counter} = Agent.start_link(fn -> 0 end)

    Req.Test.stub(LLM, fn conn ->
      Agent.update(counter, &(&1 + 1))
      reply(conn, 400, %{"error" => %{"message" => "unknown model"}})
    end)

    assert {:error, {:http, 400, detail}} = LLM.chat(messages: [])
    assert detail =~ "unknown model"
    assert Agent.get(counter, & &1) == 1
  end

  test "a dead endpoint is a transport error, after the retries" do
    Application.put_env(:blog, :llm_req_options, retry: false)
    assert {:error, {:transport, _}} = LLM.chat(messages: [])
  end

  test "json/1 refuses a reply that is not a JSON object" do
    Req.Test.stub(LLM, fn conn ->
      reply(conn, 200, completion(%{"role" => "assistant", "content" => "not json"}))
    end)

    assert {:error, :invalid_json} = LLM.json(messages: [])
  end

  test "the DeepSeek body: max_tokens with reasoning headroom, low effort, tools auto" do
    Req.Test.stub(LLM, fn conn ->
      body = sent_body(conn)
      assert body["model"] == "deepseek-flash"
      assert body["max_tokens"] == 2_000 + 24_000
      refute Map.has_key?(body, "max_completion_tokens")
      assert body["reasoning_effort"] == "low"
      assert body["tool_choice"] == "auto"
      assert [%{"type" => "function"}] = body["tools"]
      reply(conn, 200, completion(%{"role" => "assistant", "content" => "ok"}))
    end)

    tool = %{"type" => "function", "function" => %{"name" => "t", "parameters" => %{}}}
    assert {:ok, _} = LLM.chat(messages: [], tools: [tool], max_tokens: 2_000)
  end

  test "the OpenAI body uses max_completion_tokens and the OpenAI key" do
    Req.Test.stub(LLM, fn conn ->
      body = sent_body(conn)
      assert body["max_completion_tokens"] == 100 + 24_000
      refute Map.has_key?(body, "max_tokens")
      assert Plug.Conn.get_req_header(conn, "authorization") == ["Bearer test-openai-key"]
      reply(conn, 200, completion(%{"role" => "assistant", "content" => "ok"}))
    end)

    assert {:ok, _} = LLM.chat(provider: "openai", messages: [], max_tokens: 100)
  end

  test "an unknown provider name falls back to the deploy default" do
    assert LLM.label("nonsense") == LLM.label()
    assert LLM.provider_name() == :deepseek
  end
end
