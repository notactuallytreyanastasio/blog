# Doctor Who's text

What `/who` computes from strings alone, shared by the server
(`src/99_who.blimp`, which holds the graph and the TV stories and talks to
the model) and the page's program (`static/who/who.blimp`). The string half
of `Blog.Who` and the texts of `Blog.Who.Chat` and `BlogWeb.WhoLive`, ported
as `temper/src/ziggy` ported the Ziggy Account's.

Lower-casing stays in Blimp, as it does for Ziggy: Temper's `String` has no
case mapping, so every function here that compares words takes text the
caller has already lower-cased.

## The prompt

`Blog.Who.Chat`'s `@system_prompt`, line for line, less the sentence about
`recall_conversations`: that tool searched the chats Postgres kept for the
LiveView, and this chat keeps nothing past the socket (see
`src/99_who.blimp`).

    let who_lines(lines: List<String>): String {
      "${lines.join("\n") { (l): String => l }}\n"
    }

    export let who_system_prompt: String = who_lines([
      "You are the TARDIS's databank, or near enough: a companion for talking through Doctor Who",
      "with someone who already loves it. You have a knowledge graph of the show in front of you,",
      "built by a fan from the Tardis wiki, the Eyespider chronology and the broadcast record, and",
      "you answer from it rather than from memory.",
      "",
      "WHAT THE GRAPH IS",
      "",
      "About 2,700 nodes and 7,700 edges. Each Doctor is an `observation` node titled like",
      "\"The Tenth Doctor (David Tennant, 2005-2010)\". Stories, companions, enemies, places,",
      "concepts and media formats are `observation` nodes too, titled \"Name - a few words on what",
      "matters about it\". The graph also holds the show's own big choices as a decision graph:",
      "`decision` nodes (\"Should the Doctor destroy the Daleks at their creation?\") with the",
      "`option`s weighed, the `action` taken and the `outcome`, plus `revisit` nodes for the times",
      "the show went back and changed its own answer (Day of the Doctor, Hell Bent, The Star Beast).",
      "",
      "No node has a description; every fact is in the title. The edges carry the relationship",
      "in their `relation` field: \"Story of\", \"Features companion\", \"Features enemy\", \"Set in\",",
      "\"Followed by\" (broadcast order), \"Chronologically followed by\" (in-universe order), \"Format\",",
      "\"Written by\", \"Departure of\", \"Same as\". Walk them with node_neighbors.",
      "",
      "Separately, the 384 television stories have a wiki record each: Doctor, companions,",
      "enemies, writer, director, setting, air date, how many episodes, whether the BBC still",
      "holds the tapes, and a synopsis. Reach for story and search_stories when a question is",
      "about a TV story's facts; the graph is better for how things connect.",
      "",
      "HOW TO WORK",
      "",
      "Use the tools constantly. You are never guessing about this graph. search_graph and",
      "search_stories score by matching words, not phrases, so if a search comes back thin,",
      "retry with one or two simple nouns (\"Daleks Genesis\", not \"the creation of the Daleks\")",
      "before concluding something is not there. A miss is not evidence of absence. For a",
      "Doctor, call the_doctors or doctor_stories rather than searching.",
      "",
      "The tools: search_graph finds nodes by words; node_neighbors shows everything joined to",
      "one node and how; the_doctors lists the incarnations; doctor_stories files the stories",
      "under one of them; chain walks the \"Followed by\" / \"Chronologically followed by\" edges",
      "forward or back from a node; the_eras gives the five eras; the_doctors_decisions gives the",
      "show's own decision graph; story and search_stories read the TV wiki records.",
      "",
      "Be clear about which Doctor Who you mean. There are sixteen incarnations plus the",
      "Fugitive Doctor, the chronology covers audio, novels and comics as well as television,",
      "and the same title can be a TV story and a novel. When the graph says \"Novel: Virgin NA\"",
      "in a title, that is a book, and say so.",
      "",
      "The graph is a fan's record and it has gaps and the odd wrong year. If what the graph",
      "says contradicts what you know, give the graph's version and say it may be wrong rather",
      "than silently correcting it; the person can check the wiki link.",
      "",
      "HOW TO TALK",
      "",
      "Short. Most answers are under 150 words; a good one is often two sentences and a question",
      "back. Say what you found and where in the graph it is, so they can click through. Do not",
      "list every match the search returned; pick what matters.",
      "",
      "Have opinions when asked for them. \"Blink is the best Tennant story\" is a fine thing to",
      "say if you then say why. Spoilers are expected here: anyone talking to this has seen the",
      "show or does not mind. Do not warn about them.",
      "",
      "No \"great question\", no headers on a short answer, no emoji. Contractions are fine.",
      "Sounding like a person who has seen all of it is the register.",
      "",
      "If they ask about things the graph does not cover (ratings, cast gossip, what is coming",
      "next series) say the graph does not go there and offer what it does have nearby.",
    ]);

The four questions the empty chat offers, `WhoLive`'s `@presets`.

    export let who_presets: List<String> = [
      "Which Doctor has the most stories, and across which media?",
      "What did the show decide about the Time War, and how many times did it change its mind?",
      "Walk me forward from Blink in broadcast order.",
      "Which TV stories are still missing from the archive?",
    ];

## The Doctors

`Blog.Who`'s `@doctor_title`, `^The (\w+) Doctor \((?<actor>[^,]+), (?<years>[^)]+)\)$`,
as a parse: the ordinal (one word), the actor (up to the first comma) and
the years (the rest, up to the closing bracket, which ends the title). A
title that is not a Doctor's gives an empty list. The Fugitive Doctor's
title says `pre-Hartnell` where the others give years, which this allows
as the pattern did.

    export let who_doctor_parts(title: String): List<String> {
      let prefix = "The ";
      let mid = " Doctor (";
      if (title.end < prefix.end || title.slice(String.begin, prefix.end) != prefix) {
        []
      } else {
        let m = title.indexOf(mid, prefix.end);
        if (m is StringIndex) {
          let ordinal = title.slice(prefix.end, m);
          let r0 = title.slice(m, title.end);
          let rest = r0.slice(mid.end, r0.end);
          let comma = rest.indexOf(", ");
          if (comma is StringIndex) {
            if (ordinal.isEmpty || ordinal.indexOf(" ") is StringIndex || rest[rest.prev(rest.end)] != 41) {
              []
            } else {
              let actor = rest.slice(String.begin, comma);
              let y0 = rest.slice(comma, rest.end);
              let y1 = y0.slice(", ".end, y0.end);
              let years = y1.slice(String.begin, y1.prev(y1.end));
              if (actor.isEmpty || years.isEmpty || years.indexOf(")") is StringIndex) {
                []
              } else {
                [ordinal, actor, years]
              }
            }
          } else {
            []
          }
        } else {
          []
        }
      }
    }

`Blog.Who.ordinal_number/1`: the number an ordinal word (lower-cased)
names, 1 to 15, or 0 for a word that is not one (War, Fugitive).

    let who_ordinals: List<String> = [
      "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth",
      "ninth", "tenth", "eleventh", "twelfth", "thirteenth", "fourteenth", "fifteenth",
    ];

    let who_ordinal_at(word: String, i: Int): Int {
      if (i >= who_ordinals.length) {
        0
      } else if (who_ordinals[i] == word) {
        i + 1
      } else {
        who_ordinal_at(word, i + 1)
      }
    }

    export let who_ordinal_number(word: String): Int {
      who_ordinal_at(word, 0)
    }

A string of digits and nothing else: `Blog.Who.doctor/1` takes "10" as 10.
Blimp's `to_int` raises on anything else, so the caller asks first.

    let who_digits_from(s: String, i: StringIndex): Boolean {
      if (i >= s.end) {
        true
      } else if (s[i] < 48 || s[i] > 57) {
        false
      } else {
        who_digits_from(s, s.next(i))
      }
    }

    export let who_all_digits(s: String): Boolean {
      !s.isEmpty && who_digits_from(s, String.begin)
    }

## Relations

Every edge is `leads_to`; the relation is the edge's rationale. The ones
that file a story under a Doctor (`@story_relations`), and the two
sequence orders `chain` walks (`@sequence_relations`).

    export let who_story_relation(r: String): Boolean {
      "|Story of|Doctor|Doctor born|Doctor dies|Debut story|Story|episode|".indexOf("|${r}|") is StringIndex
    }

    export let who_sequence_relation(r: String): Boolean {
      r == "Followed by" || r == "Chronologically followed by"
    }

## Search

`Blog.Who.terms/1` split the lower-cased query on `[^a-z0-9']+` and kept
the words of three characters or more: unlike Ziggy's, an apostrophe is
part of a word ("sally's"). Everything between two words becomes a space
and the string is split on spaces. Only ASCII survives, so a word's bytes
are its characters and "three or more" is three steps.

    let who_word_code(c: Int): Boolean {
      if (c == 39) {
        true
      } else if (c < 48) {
        false
      } else if (c <= 57) {
        true
      } else if (c < 97) {
        false
      } else {
        c <= 122
      }
    }

    let who_spaced(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let n = s.next(i);
        if (who_word_code(s[i])) {
          who_spaced(s, n, "${acc}${s.slice(i, n)}")
        } else {
          who_spaced(s, n, "${acc} ")
        }
      }
    }

    let who_three(t: String): Boolean {
      if (t.isEmpty) {
        false
      } else {
        let a = t.next(String.begin);
        if (a >= t.end) {
          false
        } else {
          t.next(a) < t.end
        }
      }
    }

    export let who_terms(lowered: String): List<String> {
      who_spaced(lowered, String.begin, "").split(" ").filter { (t): Boolean => who_three(t) }
    }

A node's score is how many of the words its lower-cased title contains,
as substrings; `zg_score` (temper/src/ziggy) is that count and is used as
it is.

## What the chat says

`WhoLive`'s texts. The chat's replies when it cannot answer are the Ziggy
Account's (`zg_limit_reply`, `zg_error_reply`), as the LiveView's were.

    export let who_max_chat_messages: Int = 40;

    export let who_empty_text: String = "Ask about a Doctor, a story, a companion, a villain, or one of the show's own decisions and the times it went back on them. Answers come from the graph and the wiki records, not from memory.";

    export let who_ask_about(title: String): String {
      "Tell me about ${title}: what it is, what it connects to, and why it matters."
    }

The header's figures: `"2731 nodes · 7728 edges · 17 Doctors · 384 TV stories · 42 decisions"`.

    export let who_stats_text(nodes: Int, edges: Int, doctors: Int, stories: Int, decisions: Int): String {
      "${nodes.toString()} nodes · ${edges.toString()} edges · ${doctors.toString()} Doctors · ${stories.toString()} TV stories · ${decisions.toString()} decisions"
    }

## The exhibit

The page opens on one TV story, chosen by the server, and the model is
asked to open the conversation about it. What it is asked, with the
exhibit (the wiki record, the node's relations, the broadcast chain
either side, the Doctor) as JSON. This turn is sent to the model as the
visitor's and never shown; the reply is the chat's first message.

    export let who_opener_prompt(facts: String): String {
      "The page in front of us has just opened on this story. Here is its wiki record and where it sits in the graph, as JSON:\n\n${facts}\n\nOpen the conversation. In two to four sentences, say something a fan would find interesting about it: a connection the graph shows, a detail from the record, an opinion. Use the tools if a fact wants checking. End with one question that invites them to talk. No greeting, no headers, do not describe the JSON."
    }

    export let who_shuffle_prompt(facts: String): String {
      "They asked for another story and the page has changed to this one. Its record and place in the graph, as JSON:\n\n${facts}\n\nIn two or three sentences, say what is interesting about this one, with a connection or an opinion, and end with a question. No greeting."
    }

A story is worth featuring when its record has a synopsis of some length;
many of the earliest stories have a line or nothing.

    export let who_featurable(synopsis: String): Boolean {
      synopsis.countBetween(String.begin, synopsis.end) >= 200
    }

What the chat says once the day's budget of model calls is spent (the
chat has no password; this is the credit guard).

    export let who_limit_reached(limit: Int): String {
      "the databank has answered its ${limit.toString()} questions for today and rests until tomorrow (UTC); the page still browses"
    }

The kicker over the featured story's title.

    export let who_kicker(story_number: String, doctor: String, aired: String, episodes: String): String {
      let parts = [story_number, doctor, aired, episodes].filter { (p): Boolean => !p.isEmpty };
      parts.join(" · ") { (p): String => p }
    }
