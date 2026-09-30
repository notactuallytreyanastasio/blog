# The Ziggy Account's text

What `/ziggy` computes from strings alone, shared by the server
(`src/99_ziggy.blimp`, which holds the graph and talks to OpenAI) and the
page's program (`static/ziggy/ziggy.blimp`, the header and the chat). A port
of the string half of `Blog.Ziggy` and `Blog.Ziggy.OpenAI` and the texts of
`BlogWeb.ZiggyLive`.

What stayed in Blimp, and why:

- Lower-casing. `Blog.Ziggy.search_nodes/2` and `character_mentions/1`
  compare `String.downcase` of both sides; Temper's `String` has no case
  mapping, so the Blimp caller lower-cases and these take the result.
- Walking the graph and OpenAI's answers, which are decoded JSON: a Temper
  function takes strings, not a Blimp map.

## The prompts

`@system_prompt` and `@autocomplete_prompt`, line for line. An Elixir
heredoc ends in a newline, so these do too.

    let zg_lines(lines: List<String>): String {
      "${lines.join("\n") { (l): String => l }}\n"
    }

    export let zg_system_prompt: String = zg_lines([
      "You are a story-analysis companion for \"The Ziggy Account,\" a novel manuscript that has been",
      "mapped chapter by chapter into a decision graph (goal -> options -> decision -> actions ->",
      "outcomes, plus observation nodes for character beats, \"PERSPECTIVE --\" nodes for moments where",
      "two characters read the same event differently, \"PATTERN --\" nodes for cross-chapter authorial",
      "patterns, and \"SPECULATION:\" nodes that are explicitly-flagged, low-confidence guesses about",
      "where the unfinished draft might go).",
      "",
      "Always use the provided tools to look up specifics (nodes, characters, themes, connections)",
      "instead of inventing details. Cite chapters and be concrete about what actually happens versus",
      "what a node speculates. search_story scores by matching words, not exact phrases — if a search",
      "comes back empty or thin, retry with fewer/simpler keywords (e.g. one or two nouns) before",
      "concluding something isn't in the graph; a miss on your first query is not evidence it's absent.",
      "",
      "The manuscript draft is unfinished: it cuts off mid-scene in Chapter 7, during the Jensen House",
      "introductions at Willis's ELMIP orientation. Never invent what happens after that point — if",
      "asked, say clearly that the draft ends there and, if useful, point to the SPECULATION nodes as",
      "guesses, not canon.",
      "",
      "Be a real conversational partner: react to what's actually interesting or contestable, offer a",
      "point of view when asked for one, and keep answers tight rather than exhaustively listing every",
      "matching node.",
    ]);

    export let zg_autocomplete_prompt: String = zg_lines([
      "You auto-complete a sentence someone is typing into a chat box where they ask questions about",
      "a novel's decision graph. Continue their exact wording naturally for another 3-10 words, in the",
      "same voice and tense, without repeating what they already wrote. Reply with ONLY the",
      "continuation text (include a leading space so it joins naturally), no quotes, no explanation.",
      "If nothing sensible continues it, reply with an empty string.",
    ]);

The four questions the empty chat offers.

    export let zg_presets: List<String> = [
      "What's the deal with the Willis/Wallace mixup?",
      "Why does Beth end up vetting Willis for Garrett?",
      "What's the golden-handcuffs theme about?",
      "Where does the draft actually end?",
    ];

## What the chat says when it cannot answer

The LiveView appended these to the conversation as the assistant's turn.

    export let zg_max_chat_messages: Int = 40;

    export let zg_limit_reply(max: Int): String {
      "This session has hit its ${max.toString()}-message limit (keeps a runaway conversation from burning API credits). Refresh the page to start a new one."
    }

    export let zg_error_reply(reason: String): String {
      "Sorry — I hit an error: ${reason}"
    }

## Search

`search_nodes/2` split the lower-cased query on `[^a-z0-9]+` and kept the
words of three characters or more. Everything between two words is a
separator, so each is written as a space and the string split on spaces.
Only ASCII letters and digits survive, so a word's bytes are its
characters and "three or more" is three steps.

    let zg_word_code(c: Int): Boolean {
      if (c < 48) {
        false
      } else if (c <= 57) {
        true
      } else if (c < 97) {
        false
      } else {
        c <= 122
      }
    }

    let zg_spaced(s: String, i: StringIndex, acc: String): String {
      if (i >= s.end) {
        acc
      } else {
        let n = s.next(i);
        if (zg_word_code(s[i])) {
          zg_spaced(s, n, "${acc}${s.slice(i, n)}")
        } else {
          zg_spaced(s, n, "${acc} ")
        }
      }
    }

    let zg_three(t: String): Boolean {
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

    export let zg_terms(lowered: String): List<String> {
      zg_spaced(lowered, String.begin, "").split(" ").filter { (t): Boolean => zg_three(t) }
    }

A node's score is how many of the words its lower-cased title and
description contain, as substrings: "garrett" scores on "garrett's".

    export let zg_score(terms: List<String>, lowered: String): Int {
      terms.filter { (t): Boolean => lowered.indexOf(t) is StringIndex }.length
    }

## Characters

A character is a node titled `CHARACTER -- Name: trait`; the trait is
everything after the first colon, and a title without one is all name.

    let zg_character_rest(title: String): String {
      let prefix = "CHARACTER -- ";
      if (title.end >= prefix.end && title.slice(String.begin, prefix.end) == prefix) {
        title.slice(prefix.end, title.end)
      } else {
        title
      }
    }

    export let zg_is_character(title: String): Boolean {
      let prefix = "CHARACTER -- ";
      title.end >= prefix.end && title.slice(String.begin, prefix.end) == prefix
    }

    export let zg_character_name(title: String): String {
      let rest = zg_character_rest(title);
      let colon = rest.indexOf(":");
      if (colon is StringIndex) {
        zg_trim(rest.slice(String.begin, colon))
      } else {
        zg_trim(rest)
      }
    }

    export let zg_character_trait(title: String): String {
      let rest = zg_character_rest(title);
      let colon = rest.indexOf(":");
      if (colon is StringIndex) {
        zg_trim(rest.slice(rest.next(colon), rest.end))
      } else {
        ""
      }
    }

`String.trim` trims Unicode whitespace; these titles only ever have spaces.

    let zg_space(c: Int): Boolean {
      c == 32 || c == 9 || c == 10 || c == 13
    }

    let zg_trim_left(s: String, i: StringIndex): String {
      if (i < s.end) {
        if (zg_space(s[i])) { zg_trim_left(s, s.next(i)) } else { s.slice(i, s.end) }
      } else {
        ""
      }
    }

    let zg_trim_right(s: String, n: StringIndex): String {
      if (n > String.begin) {
        let p = s.prev(n);
        if (zg_space(s[p])) { zg_trim_right(s, p) } else { s.slice(String.begin, n) }
      } else {
        ""
      }
    }

    export let zg_trim(s: String): String {
      let l = zg_trim_left(s, String.begin);
      zg_trim_right(l, l.end)
    }

## The model's Markdown, made safe

The LiveView rendered a reply with `Blog.Markdown.as_html/1`, which is MDEx
without `unsafe_`: raw HTML in the model's answer came out as
`<!-- raw HTML omitted -->`, and a link to `javascript:` lost its address.
The site's renderer (`src/10_markdown.blimp`) is the posts' renderer, and
posts rely on raw HTML, so it passes it through. A reply is someone else's
text, put into the page with `inner_html`: a prompt that talks the model
into writing `<img src=x onerror=...>` must not run it.

So the rendered HTML is checked tag by tag. Every `<` in it is a tag: the
renderer writes a `<` in text as `&lt;`. A tag is kept if it is one the
renderer writes, with attributes the renderer writes, quoted as it quotes
them; anything else is replaced, whole, with MDEx's comment. A `>` inside a
quoted value of the model's own HTML ends the "tag" early; what follows it
is then text, which is inert. Nothing is lower-cased: the renderer writes
lower case, and `<IMG>` is simply not a tag it writes.

    let zg_omitted: String = "<!-- raw HTML omitted -->";

    export let zg_safe_html(html: String): String {
      zg_safe_from(html, String.begin, "")
    }

    let zg_safe_from(s: String, i: StringIndex, acc: String): String {
      let lt = s.indexOf("<", i);
      if (lt is StringIndex) {
        let before = "${acc}${s.slice(i, lt)}";
        let gt = s.indexOf(">", lt);
        if (gt is StringIndex) {
          let tag = s.slice(s.next(lt), gt);
          let kept = if (zg_tag_ok(tag)) { "<${tag}>" } else { zg_omitted };
          zg_safe_from(s, s.next(gt), "${before}${kept}")
        } else {
          "${before}&lt;${s.slice(s.next(lt), s.end)}"
        }
      } else {
        "${acc}${s.slice(i, s.end)}"
      }
    }

The elements the renderer and the highlighter write.

    let zg_element(name: String): Boolean {
      " p ul ol li strong em code pre blockquote hr br h1 h2 h3 h4 h5 h6 a img span ".indexOf(" ${name} ") is StringIndex
    }

    let zg_name_code(c: Int): Boolean {
      if (c == 45) {
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

    let zg_name_end(s: String, i: StringIndex): StringIndex {
      if (i < s.end && zg_name_code(s[i])) { zg_name_end(s, s.next(i)) } else { i }
    }

    export let zg_tag_ok(tag: String): Boolean {
      if (tag.isEmpty) {
        false
      } else if (tag[String.begin] == 47) {
        let start = tag.next(String.begin);
        let e = zg_name_end(tag, start);
        e == tag.end && e > start && zg_element(tag.slice(start, e))
      } else {
        let e = zg_name_end(tag, String.begin);
        e > String.begin && zg_element(tag.slice(String.begin, e)) && zg_attrs_ok(tag, e)
      }
    }

After the name: ` name="value"` any number of times, then nothing or ` /`.

    let zg_attrs_ok(tag: String, i: StringIndex): Boolean {
      if (i >= tag.end) {
        true
      } else if (tag[i] != 32) {
        false
      } else {
        let a = tag.next(i);
        if (a >= tag.end) {
          false
        } else if (tag[a] == 47) {
          tag.next(a) == tag.end
        } else {
          let ne = zg_name_end(tag, a);
          if (ne == a || ne >= tag.end || tag[ne] != 61) {
            false
          } else {
            let q = tag.next(ne);
            if (q >= tag.end || tag[q] != 34) {
              false
            } else {
              let vs = tag.next(q);
              let ve = tag.indexOf("\"", vs);
              if (ve is StringIndex) {
                zg_attr_ok(tag.slice(a, ne), tag.slice(vs, ve)) && zg_attrs_ok(tag, tag.next(ve))
              } else {
                false
              }
            }
          }
        }
      }
    }

    let zg_attr_ok(name: String, value: String): Boolean {
      if (name == "href" || name == "src") {
        zg_url_ok(value)
      } else {
        " class data-line translate tabindex start alt title ".indexOf(" ${name} ") is StringIndex
      }
    }

An address is kept if it is http, https or mailto, or a path or fragment on
this site. Anything else with a colon, or with an `&` that is not the
renderer's own `&amp;` (so an entity the browser would decode into a colon,
`&#58;`), is not.

    let zg_prefixed(s: String, p: String): Boolean {
      s.end >= p.end && s.slice(String.begin, p.end) == p
    }

    export let zg_url_ok(url: String): Boolean {
      if (zg_prefixed(url, "https://") || zg_prefixed(url, "http://") || zg_prefixed(url, "mailto:")) {
        true
      } else if (zg_prefixed(url, "//")) {
        false
      } else if (url.indexOf(":") is StringIndex) {
        false
      } else {
        let plain = url.split("&amp;").join("") { (p): String => p };
        !(plain.indexOf("&") is StringIndex)
      }
    }
