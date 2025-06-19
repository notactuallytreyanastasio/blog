tags: programming,ai,llms,software,engineering

# A Clever Hack: Claude Code as an MCP for Windsurf/Cursor
I was briefly locked out of my Windsurf and Cursor models today for an unknown reason.
Both of these happening at once was a bit suspect.
But I figured the universe just wanted to make my afternoon more interesting.

I got to a particularly hairy task for a UI that would _really_ benefit from some LLM generated goodness with good reference points to hash out a UI idea more than it would be futzing around slowly.

But alas, now I had no models being paid for by work!

What did I do?

## Claude Code as an MCP Server and implementation layer, Windsurf/Cursor model as a translator
What does this even mean?

When I prompt claude code, I say something like

```
build me an entire sandwich app, with all the options
```

And this, well, is a pretty shit prompt.

BUT, if I have Claude Code configured as an MCP with the tool call configurations I have set up right now, I will end up doing something magical.

It will use the LLM's model (in this case, Open AI's o3, because my service came back on at this point) to structure the input that gets handed to the MCP.
The MCP then formulates an "action plan" which it dispatches.
However, in this case, _its action plan instructions_ are being augmented from our trash human language, to something more useful the machines pass to each other.
We end up having much better inputs _given to Claude Code_ and then it works to implement them!

This is fantastic.
We are effectively using an MCP layer and o3 + Claude Opus 4 as a combined force to automatically up every prompts game.

## The Other Benefit
If you are on a pro/max plan, this saves you _so much money_ on tool calls from Windsurf/Cursor.
If you are on a pro/max plan this also is effectively a license to go crazy building whatever you want.
Adding this layer to the implementation where we have our editor refine our inputs is great, and not only reduces costs but can yield better outcomes.

Here is my MCP configuration.
It's simple.

```
# ~/project/.windsurf|.cursor/mcp_config.json
{
    "mcpServers": {
        "claude-code": {
            "command": "claude",
            "args": [
                "mcp",
                "serve"
            ],
            "env": {}
        }
    }
}
```

This really will impact your usage patterns and allow you to work on a free plan with Cursor or Windsurf, but get the pro model benefits of Claude Opus and Sonnet 4 with the best tools to utilize them possible.

Happy hacking.
