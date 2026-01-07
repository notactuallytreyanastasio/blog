tags: tech,git

# Tangled.sh: Git collaboration on ATProto

I recently learned about a neat little project earlier this week.

I saw [a skeet from my friend Steve](https://bsky.app/profile/steveklabnik.com/post/3ljgsbr2by22k) talking about this weird Git collaboration thing.
And the way you joined it was by asking on an IRC channel.
[Anil](https://bsky.app/profile/anildash.com/post/3ljgtou3hvk22) mentioned he's the type of sicko who loves this, and so am I, so I decided to join before I really understood what it was.

## Getting set up
I first set out into the IRC room politely asking for an invite unsure who was running the show.

They quickly helped out once I gave my bluesky handle [(@bobbby.online)](https://bsky.app/profile/yburyug.bsky.social) to them and got set up with an app password.

Now, I wondered what to do.
So, I just followed a few people who looked like they might be working on cool things.
I figured the early adopters of something like this are usually up to something interesting.

So, from here, I went to create a repo.

I filled out the form with a repo name (blog) and a main branch, and creating it broke.

But then they fixed the bug and I could get my repo created and see the main branch.

Now, I began to wonder how it works.

## Adding a Git Remote
To get started, I added a git remote for tangled:

```
git remote add tangled git@tangled.sh:bobbby.online/blog
```

And after adding my SSH key, I could push.

## What happened here?
Well, a lot of that is yet to be explained, but heres what I can gather:

It's broadcasting, in its own Lexicon on ATProto, a log of the work done (not the entire commit graph).

This would not hit the "firehose" you see in the App View of bluesky.

It has its own constructs to represent the graph of activity happening on the site as a whole.

Soon it looks like they will be bringing in collaboration tools like stacked PR review, and other features to work together socially to code.

This all will be stored using ATProto, rather than something like a central git server.

So this is pretty neat, its a decentralized means to socially code together, stored on a decentralied-first web where you own your data.

## Plans
I figure I'll keep playing with this.

I also am excited about [Flashes](link) -- which uses a cool hack on top of ATProto.
It uses the same lexicon as the bsky app, and therefore it gets cross-posted when you post images on bluesky or from there to bsky as well.

There will be a lot of clever uses of lexicons, the protocol itself, and ways to socially build a web that is not centralized coming from this, I think

## Playing with it further
I'll be opening chains of PRs on this to see how the UI works as it goes on and add some more repositories.

I also am going to begin understanding how to write something using the protocol and Elixir.

I'd like to build a really really really basic slimmed down "App View" using Elixir, or something like that.
