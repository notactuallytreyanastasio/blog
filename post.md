# Advanced Charlie Work: Guiding The Robot Good (For Your Health)

## Why You Are Here

In general, it's difficult to work with LLMs and the related tooling to write software.

In general, it's also true that LLMs have become *very* good at writing code.

Why are so many developers struggling to get real utility out of them? What leads to so many not impressed, but some thinking its the beginning of a revolution?

**In short: I think a big part of this is simply a skill issue.**

LLMs are very much like an inverted computer compared to what we are used to. This leads us to a situation in which we have to start thinking and learning in new ways. The LLM doesn't think in 1s and 0s, in fact its bad at math. The interface its best at is *token prediction*. So sometimes, people just start brushing strokes in the wrong way and get bad results in their first forays.

I am not here to tell people what is good practice, what is bad practice, and who is doing things wrong or right.

What I will do is share a collection of observations that, when coupled together, have proven quite effective in my day to day engineering work.

## What We Will Do

Today we are going to take an open problem and come up with definable inputs for an LLM.

We will approach this in an agnostic manner. It doesn't matter what tools you use, or what models you use, because we are thinking about a holistic methodology for approaching this, and that goes beyond what a model might excel at. What models excel at is certainly *still important* but it is not the only component.

So, the way we approach this is making an app.

We will get started below workshopping it, then dive straight into tools and building something real.

## Interactive Example

See the process in action with this simplified demonstration:

### Step 0: Ask broadly

We want to begin with something that is approachable from a high level. This can be something as simple as a premise, but its better to drill things in a little more. For our example, we are going to be trying to get on to building a clone of a popular old link sharing website, del.icio.us. This first step we will utilize Claude Opus 4. Any reasoning model will do, though. o3 is especially impressive, too. Grok also can hold its own here (though I do not endorse using it).

**We can start with a simple prompt:**

```
I need to design an application. I am choosing to use the Elixir programming language and Phoenix framework because I have heard they have some features with real-time capabilities that may be of use to me. The application is a social bookmarking service. It features several core concepts.

- A chrome extension. This simple extension saves a URL, a page title, a description, and some tags describing the page. It does this by communicating with our server.
- A backend service with several features: saving bookmarks, tagging them, browsing them once saved, sharing them with others, upvoting/downvoting, commenting, or more.

Can you help me structure a CLAUDE.md file to give Claude code instructions on getting started here?

I need a detailed specification, because I ultimately am going to feed this into another model. Please engineer this output to be structured in a way that it is a plan Claude Sonnet 4 is ready to implement.
```

## Implementation: Claude Code

We will begin by getting some real outputs and go from there. We will use claude code for those. So, let's begin. I am going to start an empty phoenix project, and populate it with my standard empty stuff to get started. You could really augment this piece to be any web framework and language you choose.

It's worth noting Phoenix is somewhat niche, but I am still confident I can get high quality outputs here.

```bash
mix phx.new tasty --live
```

And with this, we can begin.

I have added a github repository that will keep track of the code for this endeavour along the way [here](https://github.com/notactuallytreyanastasio/tasty)

The first commit with the app created is [here](https://github.com/notactuallytreyanastasio/tasty/commit/eb1eebdc4c567f812449fa6a0701d63f32edf770)

If we examine [commit d4566a519663047e6831c0b8f46614299fffc033](https://github.com/notactuallytreyanastasio/tasty/commit/d4566a519663047e6831c0b8f46614299fffc033) we see that we get a pretty broad top level specification. 357 lines!

The core idea here is clear though: we use our tool to build inputs for our tool.

### Ideal 1: Use The Tool To Make More Tools TM

We can see the diff here, I simply decided to strike things to keep this in scope for a tutorial we can fit in the size of a single post here:

Once we have removed this, we can begin to start to talk about tools and what inputs like this mean as an aside before we get to more hacking.

From here, we now have a real working base. At this point, I am going to let Claude Code rip away with what we have created, but you can choose other tools, and we will dive into using some other tools (such as an editor, or a Desktop client). With this, we end up in a world where we have fundamentally created something that has a lot of moving parts and bells and whistles quite quickly.

I just let claude go and kept hitting yes for about 30 minutes. It got pretty far.

You can see the entire log [here](fake_link)

We can look at this Github Gist to see the entire run log, if you are curious. It shows quite a bit of the methodical approach Claude was allowed to take because of our prior instructions working over having an error-prone person go through this step by step.

From here, we are at a point where we largely have what looks like a real project?! That is pretty hardcore. I thought our goal here was to get *correct* and *refined* and *focused* inputs.

Well, that really is the goal. But first I had to impress you, and also give us a stage to work from that will give us a reasonable jumping off point to have an open problem and some actual real life style nebulous complexity.

But first, let's take a look at what Claude really has made for me. We will want to check in from your end and make sure we have roughly gotten to the same point in your framework of choice once you begin following along.

[Here is the log for anyone wondering](https://gist.github.com/notactuallytreyanastasio/db1c23114eeb01c394285299d8c31bfb#file-claude_session_2-md)

### What we have:

1. Database schemas for everything
2. Backend relationships all set up
3. Channels set up for pubsub
4. Users and Auth
5. Interfaces to all major domain entities

At this point, things look pretty good. We can see the state of the world.

For good measure, at this point, I also had Claude deploy my application to my provider of choice.

I also had it write tests for all functionality it just generated.

## Conquering these steps

So great for me, right? This all just came together. But you are trying to make a working piece of software, and you might not have luckily just one-shotted it.

What do you do if it fails?

### Honestly: try again

These outputs are nondeterministic and its a feature. Let's use it.

As you iterate, keep one thing in mind: it all can be thrown away fast.

## Refining our first LiveView with Claude Code

We are going to review a session with claude here where we ultimately implement this LiveView: (use attached image)

But how do we get there?

Well, there are a few approaches. But with Claude Code, we are going to take the most "freestyle" approach possible. Instead of reaching for a specification, we are going to let it YOLO its way to something functional. In this case, we start off with a pretty simple prompt

> now let's make a liveview. this will be our first one. it will view a random sampling of bookmarks from the database that are labeled public. To get the database off we will seed it with 100 random reddit links. it should also have an ability to click a tag at the top and select it then only show bookmarks with that tag in the feed

This is a bit more of a tall order! I let it run and it started to cook.

```
⏺ Update Todos

  ⎿  ☐ Create database seeding script with 100 Reddit bookmarks
     ☐ Update Bookmarks context for public bookmark queries
     ☐ Create BookmarkLive for browsing public bookmarks
     ☐ Add tag filtering functionality to LiveView
     ☐ Add LiveView routes and test the implementation
```

This is totally a reasonable start, but each of these tasks are pretty large! I guess we can just let it run though, and I did. So here are some highlights of what came next.

> ✻ Thinking…
> Let me also add different source types based on the URL to make it more realistic.
> Let me update the source badge logic to show different types based on the bookmark URL.

So, we can see its reaching to add some color here and that isn't necessarily the worst thing.

We do end up in a position where we have a pretty clear path.

So, I gave it some light prompts for refinement. Here they are:

>  lets start off by writing tests for all the context modules and schemas we have created so far. This is pretty lacking in this first implementation. You can keep them all in one isolated commit if that is easy for you.

This is a pretty good step just to ensure the logic is all thought out. It's an excuse to look at the tests, especially. If we cover the implementations right now, they are pretty well documented and make sense as to how they'd tie together. But let's see if we are actually doing the work described.

Unsurprisingly, its super good at this and the testing loop goes quickly.

> now let's make a liveview. this will be our first one. it will view a random sampling of bookmarks from the database that are labeled public. To get the database off we will seed it with 100 random reddit links. it should also have an ability to click a tag at the top and select it then only show bookmarks with that tag in the feed

This was the next big step and we are really going to get to cooking now that we're giving it input this wide. And this is where our next step comes in.

### Ideal 2: Introduce constraints. Early and often.

I followed up here asking it to compact the UI in various ways. What we ended up with is pretty nice as a start. It even nailed the sorting by tags, which it wrote tests for as well. Everything at this point, I would say, is actually by my judgement decent Elixir code. This is pretty impressive. But its only the beginning. From here, we will move on to having a data layer.

But now that we have gotten some stuff onto a page, we are going to try to get to the same point using another tool.

Once we get to this point with 3 different tools, then we will choose our own adventure to finish this exercise.

## Getting Started With Claude Desktop: Look Mom No Editor

Why on earth write an application with absolutely no text editor?

Because we live in the future. That is the tool that primitive people used to make software. We do not have such constraints.
