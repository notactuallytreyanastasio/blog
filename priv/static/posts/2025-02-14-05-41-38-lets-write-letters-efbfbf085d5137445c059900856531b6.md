tags: programming,elixir,fun

# How a fun idea came about
I just had a bunch of fun the other night, and we had to enjoy the scene in a very old school way.

We were not allowed to use our phones, so it was everyone enjoying the show like the old days.

Much like the old days, you also had to wait in line in person to get a ticket.
1 ticket per person.
$50.

Not a bad deal to see [Paul McCartney](https://en.wikipedia.org/wiki/Paul_McCartney).

Anyways, this all planted the seed of thinking about doing things the "old" way.

I wanted to make a simple app, and I thought well maybe I should make it so that as you type random letters, you will see some kind of art display as they render.
Maybe they fade in dramatically sometimes, and other times slide in, etc.
Well, I never got that far.
But I did start making something that was right along those lines.

I decided that since recently I had been thinking about using constraints as a feature, I would make a constrained page:

Make art by only knowing what key someone just typed, or all the keys they have typed since starting to visit.

## Well, let's write some code for a Keypress Viewer page
This was remarkably easy.

We can see the entire LiveView at once to get an idea of how simple it really can be for this piece.

This specific piece of this exercise makes me wonder how much harder this would be in JavaScript

```elixir
  # in router.ex
  live "/keylogger", KeyloggerLive
```

And then

```elixir
# keylogger_live.ex
defmodule BlogWeb.KeyloggerLive do
  use BlogWeb, :live_view
  import BlogWeb.CoreComponents
  require Logger

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       pressed_key: "",
       show_modal: true,
       page_title: "Experiment - what key are you pressing"
     )}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    {:noreply, assign(socket, pressed_key: key)}
  end

  def render(assigns) do
    ~H"""
    <div phx-window-keydown="keydown">
      <h1 class="text-[75px]">
        Pressing: <%= @pressed_key %>
      </h1>
    </div>
    """
  end
end
```

So this is pretty simple right?

The entirety of what it gets us, honestly, is pretty impressive.

We simply hook together when someone presses anything on the keyboard with supported bindings for events on keypress, and then we take the state of the page and in the tempate say hey, render the key that was just coming over the wire.

Sometimes I love Elixir.

### What came next?
Well, once I had one letter, I thought, "what if I stored every letter someone typed".

That brought about a deeper process of thought.

Some people really do just type letters and want them in specific orders, and then to share those letters in specific orders with other people.

I figured that I could offer a service doing this by writing some simple software.

So, I started off by figuring out a way to store the state of more than just one letter.

Let's take a look at what we change here

```
defmodule BlogWeb.KeyloggerLive do
  # snip ...

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       pressed_key: "",
       show_modal: true,
       pressed_keys: "",
       page_title: "Experiment - what key are you pressing"
     )}
  end

  def handle_event("keydown", %{"key" => key}, socket) do
      {:noreply,
       socket
       |> assign(pressed_key: key)
       |> assign(pressed_keys: socket.assigns.pressed_keys <> key)
      }
  end

  def render(assigns) do
    ~H"""
    <div phx-window-keydown="keydown">
      <h1 class="text-[75px]">
        Pressing: <%= @pressed_key %>
      </h1>
      <div id="history">
        <%= @pressed_keys %>
      </div>
    </div>
    """
  end
end
```

So we did a couple things:

1. set `pressed_keys` to `""` on mount
2. track pressed keys in state as we go
3. render that pressed key state in a div on the page

Now we can remember the order of the keys someone pressed, and then show that they have pressed them.

**I think we have reached MVP status**

# A product person enters the room
I was telling someone about this brilliant idea and someone alerted me quickly that I shouldn't bet too big on this.

What was their problem with my master plan?

They told me I had just reinvented writing down letters to people, and that you can do this digitally trivially.

But we met at a middle ground: what if I offered a way to send letters like they were written on a typewriter?

This would mean that everything the user typed must be very deliberate and meaningful, much like my usecase of wanting to type letters in a specific order and have that be a tracked state.

So, I decided we could set off with this as an idea.

# Let's write letters to our friends as if we had a typewriter
I'll finish this part in the morning, I wanted to get the inspirational layout for the post done tonight.

