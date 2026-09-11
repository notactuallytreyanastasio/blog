defmodule Blog.Ziggy.OpenAI do
  @moduledoc """
  Chat layer for "Ask the Graph" — sends the conversation to OpenAI with
  function-calling tools that query Blog.Ziggy (the decision graph for
  "The Ziggy Account"), executes any tool calls the model makes, and loops
  until it returns a final answer grounded in the graph.
  """

  @max_tool_iterations 5

  @autocomplete_prompt """
  You auto-complete a sentence someone is typing into a chat box where they ask questions about
  a novel's decision graph. Continue their exact wording naturally for another 3-10 words, in the
  same voice and tense, without repeating what they already wrote. Reply with ONLY the
  continuation text (include a leading space so it joins naturally), no quotes, no explanation.
  If nothing sensible continues it, reply with an empty string.
  """

  @doc "Cheap inline-autocomplete suggestion for the chat textarea. {:ok, text} | {:error, reason}"
  def suggest(partial) when is_binary(partial) do
    with {:ok, api_key} <- fetch_api_key() do
      model = Application.get_env(:blog, :openai_autocomplete_model, "gpt-5.4-nano")

      body = %{
        "model" => model,
        "messages" => [
          %{"role" => "system", "content" => @autocomplete_prompt},
          %{"role" => "user", "content" => partial}
        ],
        "max_completion_tokens" => 30
      }

      case Req.post("https://api.openai.com/v1/chat/completions",
             headers: [{"authorization", "Bearer #{api_key}"}],
             json: body,
             receive_timeout: 8_000
           ) do
        {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => content}} | _]}}} ->
          {:ok, String.trim_trailing(content || "")}

        {:ok, %{status: status, body: resp_body}} ->
          {:error, "status #{status}: #{inspect(resp_body)}"}

        {:error, reason} ->
          {:error, inspect(reason)}
      end
    end
  end

  @system_prompt """
  You are a story-analysis companion for "The Ziggy Account," a novel manuscript that has been
  mapped chapter by chapter into a decision graph (goal -> options -> decision -> actions ->
  outcomes, plus observation nodes for character beats, "PERSPECTIVE --" nodes for moments where
  two characters read the same event differently, "PATTERN --" nodes for cross-chapter authorial
  patterns, and "SPECULATION:" nodes that are explicitly-flagged, low-confidence guesses about
  where the unfinished draft might go).

  Always use the provided tools to look up specifics (nodes, characters, themes, connections)
  instead of inventing details. Cite chapters and be concrete about what actually happens versus
  what a node speculates. search_story scores by matching words, not exact phrases — if a search
  comes back empty or thin, retry with fewer/simpler keywords (e.g. one or two nouns) before
  concluding something isn't in the graph; a miss on your first query is not evidence it's absent.

  The manuscript draft is unfinished: it cuts off mid-scene in Chapter 7, during the Jensen House
  introductions at Willis's ELMIP orientation. Never invent what happens after that point — if
  asked, say clearly that the draft ends there and, if useful, point to the SPECULATION nodes as
  guesses, not canon.

  Be a real conversational partner: react to what's actually interesting or contestable, offer a
  point of view when asked for one, and keep answers tight rather than exhaustively listing every
  matching node.
  """

  @tools [
    %{
      "type" => "function",
      "function" => %{
        "name" => "search_story",
        "description" => "Full-text search over story-beat nodes (title + description).",
        "parameters" => %{
          "type" => "object",
          "properties" => %{
            "query" => %{"type" => "string", "description" => "Text to search for."},
            "node_type" => %{
              "type" => "string",
              "enum" => ["goal", "option", "decision", "action", "outcome", "observation"],
              "description" => "Optional filter by node type."
            },
            "chapter" => %{"type" => "string", "description" => "Optional filter, e.g. 'chapter-3'."}
          },
          "required" => ["query"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "get_story_node",
        "description" => "Fetch the full title/description/status of one node by id.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"id" => %{"type" => "integer"}},
          "required" => ["id"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "node_neighbors",
        "description" => "List the edges/connections in and out of a node, with the connected node titles.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"id" => %{"type" => "integer"}},
          "required" => ["id"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "list_characters",
        "description" => "List every character with a logged motivation/trait profile.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "character_appearances",
        "description" => "Find every story-beat node that mentions a given character by name.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"name" => %{"type" => "string"}},
          "required" => ["name"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "list_themes",
        "description" => "List all tracked literary themes with their descriptions.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "nodes_for_theme",
        "description" => "List the story-beat nodes tagged with a given theme name.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"theme_name" => %{"type" => "string"}},
          "required" => ["theme_name"]
        }
      }
    }
  ]

  @doc """
  history is a list of %{"role" => "user" | "assistant", "content" => text} maps
  (the running conversation, not including the system prompt).
  Returns {:ok, reply_text} | {:error, reason}.
  """
  def ask(history) when is_list(history) do
    messages = [%{"role" => "system", "content" => @system_prompt} | history]
    loop(messages, 0)
  end

  defp loop(_messages, iteration) when iteration >= @max_tool_iterations do
    {:error, "gave up after too many tool calls"}
  end

  defp loop(messages, iteration) do
    with {:ok, api_key} <- fetch_api_key(),
         {:ok, %{"choices" => [%{"message" => msg} | _]}} <- request(messages, api_key) do
      case msg["tool_calls"] do
        tool_calls when is_list(tool_calls) and tool_calls != [] ->
          tool_results = Enum.map(tool_calls, &execute_tool_call/1)
          loop(messages ++ [msg] ++ tool_results, iteration + 1)

        _ ->
          {:ok, msg["content"] || "(no response)"}
      end
    else
      {:error, reason} -> {:error, reason}
      other -> {:error, "unexpected OpenAI response: #{inspect(other)}"}
    end
  end

  defp fetch_api_key do
    case Application.get_env(:blog, :openai_api_key) do
      key when is_binary(key) and key != "" -> {:ok, key}
      _ -> {:error, "OPENAI_API_KEY is not configured"}
    end
  end

  defp request(messages, api_key) do
    model = Application.get_env(:blog, :openai_model, "gpt-5.1")

    body = %{
      "model" => model,
      "messages" => messages,
      "tools" => @tools,
      "tool_choice" => "auto",
      "temperature" => 0.5
    }

    case Req.post("https://api.openai.com/v1/chat/completions",
           headers: [{"authorization", "Bearer #{api_key}"}],
           json: body,
           receive_timeout: 30_000
         ) do
      {:ok, %{status: 200, body: resp_body}} -> {:ok, resp_body}
      {:ok, %{status: status, body: resp_body}} -> {:error, "OpenAI API error #{status}: #{inspect(resp_body)}"}
      {:error, reason} -> {:error, "OpenAI request failed: #{inspect(reason)}"}
    end
  end

  defp execute_tool_call(%{"id" => id, "function" => %{"name" => name, "arguments" => args_json}}) do
    args =
      case Jason.decode(args_json || "{}") do
        {:ok, decoded} -> decoded
        _ -> %{}
      end

    result = run_tool(name, args)
    %{"role" => "tool", "tool_call_id" => id, "content" => Jason.encode!(result)}
  end

  defp run_tool("search_story", args) do
    Blog.Ziggy.search_nodes(args["query"], node_type: args["node_type"], chapter: args["chapter"])
    |> Enum.map(&Blog.Ziggy.to_summary/1)
  end

  defp run_tool("get_story_node", %{"id" => id}) do
    case Blog.Ziggy.get_node(id) do
      nil -> %{error: "no node with that id"}
      node -> Map.take(node, [:id, :node_type, :title, :description, :status])
    end
  end

  defp run_tool("node_neighbors", %{"id" => id}) do
    %{outgoing: outgoing, incoming: incoming} = Blog.Ziggy.neighbors(id)

    %{
      outgoing: Enum.map(outgoing, &edge_summary(&1, :to_node_id)),
      incoming: Enum.map(incoming, &edge_summary(&1, :from_node_id))
    }
  end

  defp run_tool("list_characters", _args), do: Blog.Ziggy.list_characters()

  defp run_tool("character_appearances", %{"name" => name}) do
    Blog.Ziggy.character_mentions(name) |> Enum.map(&Blog.Ziggy.to_summary/1)
  end

  defp run_tool("list_themes", _args) do
    Blog.Ziggy.list_themes() |> Enum.map(&Map.take(&1, [:name, :description]))
  end

  defp run_tool("nodes_for_theme", %{"theme_name" => name}) do
    Blog.Ziggy.nodes_for_theme(name) |> Enum.map(&Blog.Ziggy.to_summary/1)
  end

  defp run_tool(_other, _args), do: %{error: "unknown tool"}

  defp edge_summary(edge, other_id_key) do
    other = Blog.Ziggy.get_node(Map.get(edge, other_id_key))
    %{edge_type: edge.edge_type, rationale: edge.rationale, node_title: other && other.title}
  end
end
