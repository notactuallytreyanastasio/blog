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
defmodule Blog.Content.Post do
  defstruct [:body, :title, :written_on, :tags, :slug]

  def all do
    "priv/posts/*.md"
    |> Path.wildcard()
    |> Enum.map(&parse_post_file/1)
    |> Enum.sort_by(& &1.written_on, {:desc, NaiveDateTime})
  end

  @spec get_by_slug(any()) :: any()
  def get_by_slug(slug) do
    all()
    |> Enum.find(&(&1.slug == slug))
  end

  # snip, prive helpers
end
```

Now that this gets us some posts, we can make a LiveView that will display them.

Here is the heex.

```elixir
    <div class="px-8 py-12 font-mono text-gray-700">
      <div class="max-w-7xl mx-auto">
        <div class="mb-12 p-6 bg-gray-50 rounded-lg border-2 border-gray-200">
          <h2 class="text-xl font-bold mb-4 pb-2 border-b-2 border-gray-200">Table of Contents</h2>
          <ul class="space-y-2">
            <%= for {text, level} <- @headers do %>
              <li class={[
                "hover:text-blue-600 transition-colors",
                level_to_padding(level)
              ]}>
                <a href={"##{generate_id(text)}"}><%= text %></a>
              </li>
            <% end %>
          </ul>
        </div>

        <article class="p-8 bg-white rounded-lg border-2 border-gray-200">
          <div class="prose prose-lg prose-headings:font-mono prose-headings:font-bold prose-h1:text-4xl prose-h2:text-3xl prose-h3:text-2xl max-w-none">
            <%= raw(@html) %>
          </div>
        </article>
      </div>
    </div>
```

We store the posts in markdown and parse them live, rather than just save HTML.
This is low-overhead enough I hope that it just doesn't matter.
If it does later, I can adapt.

Posts are routed by slug, which is implicit by title in filename.

For example, `priv/static/posts/2024-03-10-14-45-00-pattern-matching-in-elixir.md` would be `pattern
