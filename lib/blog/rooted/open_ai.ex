defmodule Blog.Rooted.OpenAI do
  @moduledoc """
  Chat layer for "Ask the Method" — sends the conversation to OpenAI with
  function-calling tools that query Blog.Rooted (the decision graph for
  "The RootedInGood(TM) Method"), executes any tool calls the model makes, and
  loops until it returns a final answer grounded in the graph.
  """

  @max_tool_iterations 5

  @autocomplete_prompt """
  You auto-complete a sentence someone is typing into a chat box where they ask questions about
  a parenting method built around short daily touchpoints of connection. Continue their exact
  wording naturally for another 3-10 words, in the same voice and tense, without repeating what
  they already wrote. Reply with ONLY the continuation text (include a leading space so it joins
  naturally), no quotes, no explanation. If nothing sensible continues it, reply with an empty string.
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
  You are an analysis companion for "The RootedInGood(TM) Method," a 92-page parenting manuscript by
  Lolly Herman. Its claim is that a short, predictable daily rhythm of connection changes a child's
  behaviour by changing how understood they feel. The method's core is three daily touchpoints:
  Focused Support (~2 min), Intentional Listening (~5 min), Physical Connection (~2 min). The book has
  been mapped into a decision graph (goal -> options -> decision -> actions -> outcomes, with
  observation nodes for premises, cautions and parent vignettes).

  The graph is organised into parts, addressed by their branch tag:
  - `spine` — the book-level chain the whole method hangs off
  - `front` — the personal note, the author's authority claim, the note on reflection and practice,
    and the disclaimer, which together state the method's promises and its explicit anti-goals
  - `ch-1` .. `ch-13` — the thirteen chapters
  - `arcs` — developmental movements that run across chapters rather than inside one
  - `alignment` — where the content meets, or strains against, the book's stated promises
  - `ai-notes` — a commentary layer of `AI_NOTE:` nodes written ON TOP of the book: unstated
    assumptions, gaps between chapters, places the advice could be misapplied, strengths easy to miss.
    These are analysis, NOT claims the book makes. Never attribute an AI_NOTE to Lolly or to the
    method; when you use one, say it is a note about the book.

  Always use the provided tools to look up specifics instead of inventing details. Content nodes carry
  verbatim quotes from the manuscript in a "Sources:" block at the end of their description — quote
  those rather than paraphrasing when accuracy matters. search_book scores by matching words, not exact
  phrases; if a search comes back empty or thin, retry with fewer, simpler keywords (one or two nouns)
  before concluding something isn't in the graph.

  This is an unpublished manuscript and a parenting method, not clinical advice. Describe what the book
  teaches and where it is silent or thin; do not extend it into therapeutic, diagnostic or medical
  recommendations of your own, and if someone asks for those, say the book doesn't cover it and point
  them to a professional.

  Be a real conversational partner: react to what is actually interesting or contestable, offer a point
  of view when asked, and keep answers tight rather than exhaustively listing every matching node.
  """

  @tools [
    %{
      "type" => "function",
      "function" => %{
        "name" => "search_book",
        "description" => "Full-text search over the manuscript nodes (title + description, including the verbatim Sources quotes).",
        "parameters" => %{
          "type" => "object",
          "properties" => %{
            "query" => %{"type" => "string", "description" => "Text to search for."},
            "node_type" => %{
              "type" => "string",
              "enum" => ["goal", "option", "decision", "action", "outcome", "observation"],
              "description" => "Optional filter by node type."
            },
            "part" => %{
              "type" => "string",
              "description" => "Optional filter by part of the book, e.g. 'ch-5', 'front', 'spine', 'arcs', 'alignment', 'ai-notes'."
            }
          },
          "required" => ["query"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "get_book_node",
        "description" => "Fetch the full title/description/status of one node by id, including its Sources quotes.",
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
        "description" => "List the edges in and out of a node, with the connected node titles. Edge types: leads_to, requires, chosen, rejected.",
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
        "name" => "book_spine",
        "description" => "The book-level spine: the single top-level goal -> options -> decision -> actions -> outcomes chain the thirteen chapters hang off.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "list_arcs",
        "description" => "The developmental arcs that run across chapters rather than inside one.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "list_ai_notes",
        "description" => "The AI_NOTE commentary layer — analysis written on top of the book, with what each note is about. Not claims the book makes.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "list_parts",
        "description" => "List the parts of the book present in the graph (branch tags such as ch-5, front, spine, alignment).",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "recall_conversations",
        "description" =>
          "Search everything that has been discussed with you before on this book, across all past chats. Use it when they refer back to something, ask what you have covered, or when prior conclusions would save repeating work. Returns past questions, your past answers, and recurring topics.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{
            "query" => %{"type" => "string", "description" => "What to look for in the memory."},
            "node_type" => %{
              "type" => "string",
              "enum" => ["question", "answer", "topic"],
              "description" => "Optional: restrict to their questions, your answers, or topics."
            }
          },
          "required" => ["query"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "recall_topics",
        "description" =>
          "The subjects people keep returning to on this book, most-discussed first, with mention counts. Use it to answer \"what have we been talking about?\" or to notice a preoccupation.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "recall_other_books",
        "description" =>
          "Search what has been discussed on the OTHER books (the other explorers). Only use it when they ask about another book, or when a cross-book connection is genuinely the point — otherwise stay with this one. Results say which book each came from.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"query" => %{"type" => "string"}},
          "required" => ["query"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "list_themes",
        "description" => "List all tracked themes with their descriptions.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "nodes_for_theme",
        "description" => "List the nodes tagged with a given theme name.",
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

  defp run_tool("search_book", args) do
    Blog.Rooted.search_nodes(args["query"], node_type: args["node_type"], part: args["part"])
    |> Enum.map(&Blog.Rooted.to_summary/1)
  end

  defp run_tool("get_book_node", %{"id" => id}) do
    case Blog.Rooted.get_node(id) do
      nil ->
        %{error: "no node with that id"}

      node ->
        node
        |> Map.take([:id, :node_type, :title, :description, :status])
        |> Map.put(:part, Blog.Rooted.part(node))
        |> Map.put(:is_ai_note, Blog.Rooted.note?(node))
        |> Map.put(:themes, Blog.Rooted.themes_for_node(node.id) |> Enum.map(& &1.name))
    end
  end

  defp run_tool("node_neighbors", %{"id" => id}) do
    %{outgoing: outgoing, incoming: incoming} = Blog.Rooted.neighbors(id)

    %{
      outgoing: Enum.map(outgoing, &edge_summary(&1, :to_node_id)),
      incoming: Enum.map(incoming, &edge_summary(&1, :from_node_id))
    }
  end

  defp run_tool("book_spine", _args), do: Blog.Rooted.spine() |> Enum.map(&Blog.Rooted.to_summary/1)

  defp run_tool("list_arcs", _args) do
    Blog.Rooted.arcs() |> Enum.map(&Map.take(&1, [:id, :title, :description]))
  end

  defp run_tool("list_ai_notes", _args), do: Blog.Rooted.list_notes()

  defp run_tool("list_parts", _args) do
    Blog.Rooted.list_parts() |> Enum.map(&%{part: &1, label: Blog.Rooted.part_label(&1)})
  end

  defp run_tool("list_themes", _args) do
    Blog.Rooted.list_themes() |> Enum.map(&Map.take(&1, [:name, :description]))
  end

  defp run_tool("nodes_for_theme", %{"theme_name" => name}) do
    Blog.Rooted.nodes_for_theme(name) |> Enum.map(&Blog.Rooted.to_summary/1)
  end

  defp run_tool("recall_conversations", args) do
    case Blog.Memory.search("rooted", args["query"], node_type: args["node_type"]) do
      [] -> %{result: "nothing remembered matching that yet"}
      hits -> hits
    end
  end

  defp run_tool("recall_topics", _args) do
    case Blog.Memory.topics("rooted") do
      [] -> %{result: "no topics recorded yet"}
      topics -> topics
    end
  end

  defp run_tool("recall_other_books", args) do
    case Blog.Memory.search_across(args["query"], except: "rooted") do
      [] -> %{result: "nothing remembered on the other books matching that"}
      hits -> hits
    end
  end

  defp run_tool(_other, _args), do: %{error: "unknown tool"}

  defp edge_summary(edge, other_id_key) do
    other = Blog.Rooted.get_node(Map.get(edge, other_id_key))
    %{edge_type: edge.edge_type, rationale: edge.rationale, node_title: other && other.title}
  end
end
