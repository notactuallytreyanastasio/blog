tags: blog, programming, elixir, phoenix

# Building and Deploying This Blog

## Introduction
I didn't want to have an Ecto dependency here because I am serving static content.
So, I made the app LiveView but didn't add Ecto at all.
I have vendored the posts in to `priv` and read them all out from there with a primitive tagging system.

I will be building some more features on top of that later, but let's cover this blog as a whole.

## Building The Blog
I created a new project with no Ecto but LiveView flagged with `--live`.
From here. I told claude-3.5-sonnet to build me a blog.

The specific prompts were pretty general.
There was a good bit of problem solving for me to get the formatting right.

We ended up at a pretty sane model.

We have a content context, which controls the posts.

The public API is quite simple here:

```elixir

```

Now that this gets us some posts, we can make a LiveView that will display them.

Here is the heex.

```elixir

```

We store the posts in markdown and parse them live, rather than just save HTML.
This is low-overhead enough I hope that it just doesn't matter.
If it does later, I can adapt.

Posts are routed by slug, which is implicit by title in filename.

For example, `priv/static/posts/2024-03-10-14-45-00-pattern-matching-in-elixir.md` would be routed as `/post/pattern-matching-in-elixir`.

### To be continued...I am still toying with this block format
