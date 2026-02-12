tags: programming,elixir,fun

# A Quick Typewriter-Set Letter Project/Experiment

I decided to start off by coding up a vim-style scroller for live skeets.

Let's say I have a context called `Social`, with a function `sample/1` that returns lists of skeets.

Who cares where they come from, its a simple enough API that we can use as the basis here.

I wanted to have a simple setup where we would scroll through a list of posts with `j` and `k`.
I make that database table of skeets get populated live.
I ingest the entire network, and every second I save about 1 of the 60ish skeets coming over the network.
So this page is always fresh, and you will want to quickly mindlessly scroll.

I started off with a pretty simpe LiveView:

```elixir
defmodule BlogWeb.VimTweetsLive do
  use BlogWeb, :live_view

  @window_size 25

  def mount(_params, _session, socket) do
    tweets = Social.sample(100) |> Enum.map(& &1.skeet)

    socket = socket
    |> assign(
      cursor: 0,
      tweets: tweets,
      visible_tweets: Enum.take(tweets, @window_size),
      page_title: "Thoughts and Tidbits Blog: Bobby Experiment - vim navigation",
      meta_attrs: @meta_attrs
    )

    {:ok, socket}
  end

  def handle_event("keydown", %{"key" => "j"}, socket) do
    new_cursor = min(socket.assigns.cursor + 1, length(socket.assigns.tweets) - 1)
    visible_tweets = get_visible_tweets(socket.assigns.tweets, new_cursor)
    {:noreply, assign(socket, cursor: new_cursor, visible_tweets: visible_tweets)}
  end

  def handle_event("keydown", %{"key" => "k"}, socket) do
    new_cursor = max(socket.assigns.cursor - 1, 0)
    visible_tweets = get_visible_tweets(socket.assigns.tweets, new_cursor)
    {:noreply, assign(socket, cursor: new_cursor, visible_tweets: visible_tweets)}
  end

  def handle_event("keydown", _key, socket), do: {:noreply, socket}

  defp get_visible_tweets(tweets, cursor) do
    start_idx = max(0, cursor - 2)
    Enum.slice(tweets, start_idx, @window_size)
  end

  def render(assigns) do
    ~H"""
    <.head_tags meta_attrs={@meta_attrs} page_title={@page_title} />
    <div class="mt-4 text-gray-500">
      Cursor position: <%= @cursor %>
    </div>
    <div class="p-4" phx-window-keydown="keydown">
      <div class="space-y-4">
        <%= for {tweet, index} <- Enum.with_index(@visible_tweets) do %>
          <div class={"p-4 border rounded #{if index == 2, do: 'bg-blue-100'}"}>
            <%= tweet %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
```

Let's break this down into pieces.

### Key Events
We can really easily intercept key events in Phoenix/LiveView.

Let's take a look at the core of how that works:

```elixir
  # liveview definition with mount

  require Logger

  def handle_event("keydown", _key, socket), do: {:noreply, socket}
    Logger.info("Pressed: #{key}")
    {:noreply, socket}
  end

  def render(assigns)
    ~H"""
      <div class="p-4" phx-window-keydown="keydown">
        hi
      </div>
    """
  end
```

Now, this starts off with `phx-window-keydown` which is set to `"keydown"`.

We can get [key events](https://hexdocs.pm/phoenix_live_view/bindings.html#key-events) from the provided APIs using this.

```
The onkeydown, and onkeyup events are supported via the phx-keydown, and phx-keyup bindings.
Each binding supports a phx-key attribute, which triggers the event for the specific key press.
If no phx-key is provided, the event is triggered for any key press.
When pushed, the value sent to the server will contain the "key" that was pressed, plus any user-defined metadata.
For example, pressing the Escape key looks like this:

%{"key" => "Escape"}
```

Great, so with this, we are now logging what we are pressing.

So now, we can wire into `j` and `k` and make it so the "visible" batch of skeets is offset by the change in index.

With that change, we make a new "cursor" which is just an index position, and a new batch of "visible skeets" that are simply the ones from the batch we have deemed currenty viewable.

This all is quite simple and elegant, in my opinion.

If we go and look at the HTML we can see how this ties together so simply:

```elixir
  def render(assigns) do
    ~H"""
    <.head_tags meta_attrs={@meta_attrs} page_title={@page_title} />
    <div class="mt-4 text-gray-500">
      Cursor position: <%= @cursor %>
    </div>
    <div class="p-4" phx-window-keydown="keydown">
      <div class="space-y-4">
        <%= for {tweet, index} <- Enum.with_index(@visible_tweets) do %>
          <div class={"p-4 border rounded #{if index == 2, do: 'bg-blue-100'}"}>
            <%= tweet %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
```

We are handling keydown and for the indexed tweet, highlighting its coor.
Then if we key up or down, we redefine whats viewable here, and the rest are just displayed.

What we end up with is beautifully simple looking.

You can check it out [here](https://salmon-unselfish-aphid.gigalixirapp.com/vim).

## Making this
This all was fun, and inspired something else:

A letter writer. 
Where you cannot copy and paste. 
You must take the time to write.
You must be truly original and keep your mistakes except for backspace being allowed.

That project is partially shipped and I will write more about it later.
