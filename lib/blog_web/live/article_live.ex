defmodule BlogWeb.ArticleLive do
  use BlogWeb, :live_view

  alias BlogWeb.SectionComponent
  alias BlogWeb.AsideComponent
  alias BlogWeb.EnhancedMediaComponent

  def mount(_params, _session, socket) do
    # Placeholder Lorem Ipsum text
    section_markdown = """
    # Writing A Job Runner (In Elixir) (Again) (10 years later)
    Ten years ago, [I wrote a job runner in Elixir after some inspiration from Jose](https://github.com/ybur-yug/genstage_tutorial/blob/master/README.md)

    This is an update on that post.

    Almost no code has changed, but I wrote it up a lot better, and added some more detail.

    I find it wildly amusing it held up this well, and felt like re-sharing with everyone and see if someone with fresh eyes may get some enjoyment or learn a bit from this.

    ### I also take things quite a bit further


    ## Who is this for?
    Are you curious?

    If you know a little bit of Elixir, this is a great "levelling up" piece.

    If you're seasoned, it might be fun to implement if you have not.

    If you don't know Elixir, it will hopefully be an interesting case study and sales pitch.

    Anyone with a Claude or Open AI subscription can easily follow along knowing no Elixir.

    ## Work?
    Applications must do work. This is typical of just about any program that reaches a sufficient size. In order to do that work, sometimes it's desirable to have it happen *elsewhere*. If you have built software, you have probably needed a background job.

    In this situation, you are fundamentally using code to run other code. Erlang has a nice format for this, called the Erlang term format. It can store its data in a way it can be passed around and run by other nodes We are going to examine doing this in Elixir with "tools in the shed". We will have a single dependency called `gen_stage` that is built and maintained by the language's creator, Jose Valim.

    For beginners, we will first cover a bit about Elixir and what it offers that might make this appealing

    ## The Landscape of Job Processing

    In Ruby, you might reach for Sidekiq. It's battle-tested, using Redis for storage and threads for concurrency. Jobs are JSON objects, workers pull from queues, and if something crashes, you hope your monitoring catches it. It works well until you need to scale beyond a single Redis instance or handle complex job dependencies.

    Python developers often turn to Celery. It's more distributed by design, supporting multiple brokers and result backends. But the complexity shows - you're configuring RabbitMQ, dealing with serialization formats, and debugging issues across multiple moving parts. When a worker dies mid-job, recovery depends on how well you've configured acknowledgments and retries.

    Go developers might use machinery or asynq, leveraging goroutines for concurrency. The static typing helps catch errors early, but you're still manually managing worker pools and carefully handling panics to prevent the whole process from dying.

    Each solution reflects its language's strengths and limitations. They all converge on similar patterns: a persistent queue, worker processes, and lots of defensive programming. What if the language itself provided better primitives for this problem?
    """

    aside_markdown = """
    **Quick Note:** Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium.
    """

    media_caption_markdown = """
    A placeholder image representing the *core theme* of our discussion. Notice the **subtle details**.
    """

    socket =
      assign(socket,
        page_title: "Building a Job Runner in Elixir (Again) (10 years later)",
        article_items: [
          %{
            type: :section,
            id: "section_intro",
            title: "The Dawn of an Idea",
            content: section_markdown
          },
          %{
            type: :aside,
            id: "aside_quick_thought",
            title: "A Fleeting Observation",
            content: aside_markdown
          },
          %{
            type: :enhanced_media,
            id: "media_visual_break",
            title: "Visualizing the Concept",
            content: media_caption_markdown,
            media_url:
              "https://via.placeholder.com/800x400.png/eee/888?text=Enhanced+Media+Placeholder"
          }
        ]
      )

    {:ok, socket, layout: {BlogWeb.Layouts, :reader}}
  end

  def render(assigns) do
    ~H"""
    <div class="reader-container">
      <h1>{@page_title}</h1>

      <%= for item <- @article_items do %>
        <%= case item.type do %>
          <% :section -> %>
            <.live_component
              module={SectionComponent}
              id={item.id}
              title={item.title}
              content={item.content}
            />
          <% :aside -> %>
            <.live_component
              module={AsideComponent}
              id={item.id}
              title={item.title}
              content={item.content}
            />
          <% :enhanced_media -> %>
            <.live_component
              module={EnhancedMediaComponent}
              id={item.id}
              title={item.title}
              content={item.content}
              media_url={item.media_url}
            />
        <% end %>
      <% end %>
    </div>
    """
  end
end
