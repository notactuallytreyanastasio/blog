defmodule Blog.Who.Chat do
  @moduledoc """
  "Ask the TARDIS": a function-calling loop over the Doctor Who knowledge
  graph, in the shape of `Marginalia.Chat.Editor`. Every model call goes
  through `Blog.LLM`, so the provider is config and a truncated reply is an
  error rather than a short answer.

  The tools close over nothing but the graph, which is read-only and public
  data, so there is no private tool list to withhold from anyone.
  """

  alias Blog.{GraphChat, LLM, Who}

  @max_tool_iterations 8

  @system_prompt """
  You are the TARDIS's databank, or near enough: a companion for talking through Doctor Who
  with someone who already loves it. You have a knowledge graph of the show in front of you,
  built by a fan from the Tardis wiki, the Eyespider chronology and the broadcast record, and
  you answer from it rather than from memory.

  WHAT THE GRAPH IS

  About 2,700 nodes and 7,700 edges. Each Doctor is an `observation` node titled like
  "The Tenth Doctor (David Tennant, 2005-2010)". Stories, companions, enemies, places,
  concepts and media formats are `observation` nodes too, titled "Name - a few words on what
  matters about it". The graph also holds the show's own big choices as a decision graph:
  `decision` nodes ("Should the Doctor destroy the Daleks at their creation?") with the
  `option`s weighed, the `action` taken and the `outcome`, plus `revisit` nodes for the times
  the show went back and changed its own answer (Day of the Doctor, Hell Bent, The Star Beast).

  No node has a description; every fact is in the title. The edges carry the relationship
  in their `relation` field: "Story of", "Features companion", "Features enemy", "Set in",
  "Followed by" (broadcast order), "Chronologically followed by" (in-universe order), "Format",
  "Written by", "Departure of", "Same as". Walk them with node_neighbors.

  Separately, the 384 television stories have a wiki record each: Doctor, companions,
  enemies, writer, director, setting, air date, how many episodes, whether the BBC still
  holds the tapes, and a synopsis. Reach for story and search_stories when a question is
  about a TV story's facts; the graph is better for how things connect.

  HOW TO WORK

  Use the tools constantly. You are never guessing about this graph. search_graph and
  search_stories score by matching words, not phrases, so if a search comes back thin,
  retry with one or two simple nouns ("Daleks Genesis", not "the creation of the Daleks")
  before concluding something is not there. A miss is not evidence of absence. For a
  Doctor, call the_doctors or doctor_stories rather than searching.

  The tools: search_graph finds nodes by words; node_neighbors shows everything joined to
  one node and how; the_doctors lists the incarnations; doctor_stories files the stories
  under one of them; chain walks the "Followed by" / "Chronologically followed by" edges
  forward or back from a node; the_eras gives the five eras; the_doctors_decisions gives the
  show's own decision graph; story and search_stories read the TV wiki records;
  recall_conversations searches what was said in earlier chats here.

  Be clear about which Doctor Who you mean. There are sixteen incarnations plus the
  Fugitive Doctor, the chronology covers audio, novels and comics as well as television,
  and the same title can be a TV story and a novel. When the graph says "Novel: Virgin NA"
  in a title, that is a book, and say so.

  The graph is a fan's record and it has gaps and the odd wrong year. If what the graph
  says contradicts what you know, give the graph's version and say it may be wrong rather
  than silently correcting it; the person can check the wiki link.

  HOW TO TALK

  Short. Most answers are under 150 words; a good one is often two sentences and a question
  back. Say what you found and where in the graph it is, so they can click through. Do not
  list every match the search returned; pick what matters.

  Have opinions when asked for them. "Blink is the best Tennant story" is a fine thing to
  say if you then say why. Spoilers are expected here: anyone talking to this has seen the
  show or does not mind. Do not warn about them.

  No "great question", no headers on a short answer, no emoji. Contractions are fine.
  Sounding like a person who has seen all of it is the register.

  If they ask about things the graph does not cover (ratings, cast gossip, what is coming
  next series) say the graph does not go there and offer what it does have nearby.
  """

  @tools [
    %{
      "type" => "function",
      "function" => %{
        "name" => "search_graph",
        "description" =>
          "Word-scored search over every node title in the knowledge graph: stories, Doctors, companions, enemies, places, concepts, formats and the show's own decisions. Retry with fewer, simpler words if thin.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{
            "query" => %{"type" => "string"},
            "node_type" => %{
              "type" => "string",
              "enum" => ["goal", "option", "decision", "action", "outcome", "observation", "revisit"],
              "description" => "Optional: restrict to one node type. Most things are observations."
            }
          },
          "required" => ["query"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "node_neighbors",
        "description" =>
          "Everything connected to one node, with the relation on each edge (Story of, Features companion, Set in, Followed by, Chronologically followed by, Format...). This is how you find a story's companions, a companion's Doctors, what a place appears in.",
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
        "name" => "the_doctors",
        "description" => "Every incarnation of the Doctor in the graph, with actor and years, and the node id to use with doctor_stories or node_neighbors.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "doctor_stories",
        "description" =>
          "The stories the graph files under one Doctor, across every medium. Takes the Doctor by ordinal (\"Tenth\"), number (10) or actor surname (\"Tennant\"). Can be long for the busy Doctors; it is capped at 80 and says so.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"doctor" => %{"type" => "string"}},
          "required" => ["doctor"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "chain",
        "description" =>
          "Walk the sequence edges from a node: what follows it (or what it follows) in broadcast or in-universe order, up to a dozen steps. Use it for 'what comes after X' and 'what led up to X'.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{
            "id" => %{"type" => "integer"},
            "direction" => %{"type" => "string", "enum" => ["forward", "back"]}
          },
          "required" => ["id"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "the_eras",
        "description" => "The five eras the graph hangs off (Classic, Wilderness Years, Time War, New Who, spinoffs) with how much sits under each.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "the_doctors_decisions",
        "description" =>
          "The show's own big choices as a decision graph: each decision with the options weighed, the action taken, the outcome, and what it was about. Use it for 'should the Doctor have...' questions and for the revisits where the show changed its answer.",
        "parameters" => %{"type" => "object", "properties" => %{}}
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "story",
        "description" =>
          "The wiki record of one TELEVISION story by title: Doctor, companions, enemies, writer, director, setting, air date, episode count, missing-episode status and the synopsis. Only the 384 TV stories; novels and audios are graph nodes.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"title" => %{"type" => "string"}},
          "required" => ["title"]
        }
      }
    },
    %{
      "type" => "function",
      "function" => %{
        "name" => "search_stories",
        "description" =>
          "Word-scored search over the TV stories' wiki records: title, companions, enemies, writer, director, setting and synopsis. 'Moffat Angels' finds the Weeping Angel stories he wrote.",
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
        "name" => "recall_conversations",
        "description" =>
          "Search what has already been said in earlier chats on this graph, by anyone. Use it when they refer back to something or when an earlier answer would save repeating the work.",
        "parameters" => %{
          "type" => "object",
          "properties" => %{"query" => %{"type" => "string"}},
          "required" => ["query"]
        }
      }
    }
  ]

  @doc "The tool schemas handed to the model."
  def tools, do: @tools

  @doc "The system prompt, verbatim. Exposed so tests can hold it to the tool list."
  def system_prompt, do: @system_prompt

  @doc """
  Ask, with the tool loop. `history` is the running conversation as
  `%{"role" => _, "content" => _}` maps. Returns `{:ok, reply}` or
  `{:error, human_readable_reason}`.
  """
  def ask(history, opts \\ []) when is_list(history) do
    # The system prompt never changes and the history only grows at the end,
    # so the provider's prefix cache sees the same prefix every turn.
    messages = [%{"role" => "system", "content" => @system_prompt} | history]
    loop(messages, 0, opts[:provider])
  end

  defp loop(_messages, n, _provider) when n >= @max_tool_iterations,
    do: {:error, "gave up after too many tool calls"}

  defp loop(messages, n, provider) do
    case LLM.chat(
           provider: provider,
           messages: messages,
           tools: @tools,
           temperature: 0.7,
           max_tokens: 2_000
         ) do
      {:ok, %{"tool_calls" => calls} = msg} when is_list(calls) and calls != [] ->
        results = Enum.map(calls, &run_call/1)
        loop(messages ++ [msg] ++ results, n + 1, provider)

      {:ok, %{"content" => content}} ->
        {:ok, content || "(no response)"}

      {:error, reason} ->
        {:error, describe(reason)}
    end
  end

  defp describe(:no_api_key), do: "no #{LLM.label()} key is configured on this deploy"
  defp describe(:truncated), do: "the reply was cut off; try a narrower question"
  defp describe(:rate_limited), do: "#{LLM.label()} is rate limiting us; give it a moment"
  defp describe({:transport, detail}), do: "could not reach #{LLM.label()} (#{detail})"
  defp describe({:http, status, body}), do: "#{LLM.label()} answered #{status}: #{body}"
  defp describe(other), do: inspect(other)

  @doc false
  # public so the tool surface can be tested without a live model
  def run_call(%{"id" => id, "function" => %{"name" => name, "arguments" => args_json}}) do
    args =
      case Jason.decode(args_json || "{}") do
        {:ok, m} when is_map(m) -> m
        _ -> %{}
      end

    %{"role" => "tool", "tool_call_id" => id, "content" => name |> tool(args) |> Jason.encode!()}
  end

  @story_cap 80

  defp tool("search_graph", args) do
    args["query"]
    |> Who.search_nodes(node_type: args["node_type"])
    |> Enum.map(&Who.to_summary/1)
    |> empty_to_note("nothing in the graph matches those words; try fewer or simpler ones")
  end

  defp tool("node_neighbors", args) do
    case Who.get_node(args["id"]) do
      nil -> %{error: "no node with that id"}
      node -> Map.merge(Who.to_summary(node), Who.neighbors(node.id))
    end
  end

  defp tool("the_doctors", _args), do: Who.doctors()

  defp tool("doctor_stories", args) do
    case Who.doctor(args["doctor"]) do
      nil ->
        %{error: "no Doctor matches #{inspect(args["doctor"])}; call the_doctors for the list"}

      d ->
        stories = Who.stories_of(d.id)

        %{
          doctor: d.title,
          total: length(stories),
          capped_at: @story_cap,
          stories: stories |> Enum.take(@story_cap) |> Enum.map(&Who.to_summary/1)
        }
    end
  end

  defp tool("chain", args) do
    direction = if args["direction"] == "back", do: :back, else: :forward

    case Who.get_node(args["id"]) do
      nil ->
        %{error: "no node with that id"}

      node ->
        case Who.chain(node.id, direction) do
          [_only] -> %{result: "no sequence edges #{direction} from #{node.title}"}
          nodes -> Enum.map(nodes, &Who.to_summary/1)
        end
    end
  end

  defp tool("the_eras", _args), do: Who.eras()

  defp tool("the_doctors_decisions", _args), do: Who.decisions()

  defp tool("story", args) do
    case Who.episode(args["title"]) do
      nil ->
        %{error: "no TV story with that title; search_stories finds near misses, and novels and audios are graph nodes that search_graph finds"}

      e ->
        e |> Who.episode_summary(full: true) |> Map.put(:wiki_url, e.wiki_url)
    end
  end

  defp tool("search_stories", args) do
    args["query"]
    |> Who.search_episodes()
    |> Enum.map(&Who.episode_summary/1)
    |> empty_to_note("no TV story matches those words; it may be a novel or audio, which search_graph finds")
  end

  defp tool("recall_conversations", args) do
    case GraphChat.search("who", args["query"]) do
      [] -> %{result: "nothing remembered matching that yet"}
      hits -> hits
    end
  end

  defp tool(_unknown, _args), do: %{error: "unknown tool"}

  defp empty_to_note([], note), do: %{result: note}
  defp empty_to_note(list, _note), do: list
end
