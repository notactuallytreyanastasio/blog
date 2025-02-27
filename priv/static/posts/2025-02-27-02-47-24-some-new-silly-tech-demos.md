tags: tech,hacking,elxiir,phoenix,liveview

# Some new tech demos

## I've been hacking on some silly LiveView demos

### Cursor Tracker
[Demo](https://www.bobbby.online/cursor-tracker)

This is simple. We

1. track each users cursor position
2. keep that state
3. allow users to see each others position live on a canvas
4. allow users to draw points on that canvas
5. allow users to clear that canvas if someone draws something stupid or it gets too full

This all is done with a minimal amount of JavaScript.

We can break down the code for this in a few pretty easy pieces, for anyone curious.

We begin at our `mount/3`:

```
    socket = assign(socket,
      x_pos: 0,
      y_pos: 0,
      relative_x: 0,
      relative_y: 0,
      in_visualization: false,
      favorite_points: [],
      other_users: %{},
      user_id: nil,
      user_color: nil,
      next_clear: calculate_next_clear(),
      # snip away meta tag attrs and page config
    )
```

This is our most minimal state: we get a default position (and relative position for use later to coordinate movement in our bounding box), and have no points saved or other users.
We also set the timer for things to be able to be cleared.

Next we handle if the user is connected or not and get our baseline state set up:

```
    if connected?(socket) do
      # Generate a unique user ID and color
      user_id = generate_user_id()
      user_color = generate_user_color(user_id)

      # Subscribe to the PubSub topic
      Phoenix.PubSub.subscribe(Blog.PubSub, @topic)

      # Subscribe to presence diff events
      Phoenix.PubSub.subscribe(Blog.PubSub, "presence:" <> @topic)

      # Track presence
      {:ok, _} = BlogWeb.Presence.track(
        self(),
        @topic,
        user_id,
        %{
          color: user_color,
          joined_at: DateTime.utc_now(),
          cursor: %{x: 0, y: 0, in_viz: false}
        }
      )

      # Get current users
      other_users = list_present_users(user_id)

      # Broadcast that we've joined
      broadcast_join(user_id, user_color)

      # Load shared points
      shared_points = get_shared_points()

      Process.send_after(self(), :tick, 1000)

      {:ok, assign(socket,
        user_id: user_id,
        user_color: user_color,
        other_users: other_users,
        favorite_points: shared_points
      )}
```

The comments here pretty much explain it all.

We are setting a color for the user, getting a cursor set, and assuming they arent inside the visualization that tracks the mouse.

We also figure out how many other users are here, and load our shared points.
This detail can be hand-waved away right now, but its loading from ETS if there have been any points saved.
We will cover this momentarily.

Next, we are going to look at the hook we implement on the JavaScript side to track the mouse as a whole.

Since the entire page centers around this hook from here, we should cover it first thing.

```
const CursorTracker = {
  mounted() {
    this.handleMouseMove = (e) => {
      // Get the mouse position relative to the viewport
      const x = e.clientX;
      const y = e.clientY;

      // Get the visualization container
      const visualizationContainer = this.el.querySelector('.relative.h-64.border');

      if (visualizationContainer) {
        // Get the bounding rectangle of the visualization container
        const rect = visualizationContainer.getBoundingClientRect();

        // Calculate the position relative to the visualization container
        const relativeX = x - rect.left;
        const relativeY = y - rect.top;

        // Only send the event if the cursor is within the visualization area
        // or send viewport coordinates for the main display and relative coordinates for visualization
        this.pushEvent("mousemove", {
          x: x,
          y: y,
          relativeX: relativeX,
          relativeY: relativeY,
          inVisualization: relativeX >= 0 && relativeX <= rect.width &&
                          relativeY >= 0 && relativeY <= rect.height
        });
      } else {
        // Fallback if visualization container is not found
        this.pushEvent("mousemove", { x: x, y: y });
      }
    };

    // Add the event listener to the document
    document.addEventListener("mousemove", this.handleMouseMove);
  },

  destroyed() {
    // Remove the event listener when the element is removed
    document.removeEventListener("mousemove", this.handleMouseMove);
  }
};

export default CursorTracker;
```

As we can see, the comments mostly explain this as well.

We are handling mouse movement by beginning with getting our position.

Next, we get the visualization container and calculate the position of the mouse relative to it.

Now, if the cursor is within hte viewing area, we send the event if the cursor is within it to allow user users to be able to track this.

If its not in the container, we just keep tracking the state.

With these pieces, we can now broadcast this hook as an event to handle it on the backend:

```
  def handle_event("mousemove", %{"x" => x, "y" => y} = params, socket) do
    # Extract relative coordinates if available
    relative_x = Map.get(params, "relativeX", 0)
    relative_y = Map.get(params, "relativeY", 0)
    in_visualization = Map.get(params, "inVisualization", false)

    # Only broadcast if we have a user_id (connected)
    if socket.assigns.user_id do
      # Update presence with new cursor position
      BlogWeb.Presence.update(
        self(),
        @topic,
        socket.assigns.user_id,
        fn existing_meta ->
          Map.put(existing_meta, :cursor, %{
            x: x,
            y: y,
            relative_x: relative_x,
            relative_y: relative_y,
            in_viz: in_visualization
          })
        end
      )

      # Broadcast cursor position to all users
      broadcast_cursor_position(
        socket.assigns.user_id,
        socket.assigns.user_color,
        x,
        y,
        relative_x,
        relative_y,
        in_visualization
      )
    end

    {:noreply, assign(socket,
      x_pos: x,
      y_pos: y,
      relative_x: relative_x,
      relative_y: relative_y,
      in_visualization: in_visualization
    )}
  end
```

Where to broadcast our cursor position we:

```
  defp broadcast_cursor_position(user_id, color, x, y, relative_x, relative_y, in_viz) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:cursor_position, user_id, color, x, y, relative_x, relative_y, in_viz}
    )
  end
```

So in this case we push out the pubsub with our new coordinates and in viz status, allowing this all to be drawn if we're in those bounds.

Our `broadcast_join` function is quite similar:

```
  defp broadcast_join(user_id, color) do
    Phoenix.PubSub.broadcast(
      Blog.PubSub,
      @topic,
      {:user_joined, user_id, color}
    )
  end
```

Which in turn sends a `user_joined` message that we handle like this, to get them set up at first:

```
  def handle_info({:user_joined, user_id, color}, socket) do
    # Skip our own join messages
    if user_id != socket.assigns.user_id do
      # Add the new user to our list of other users
      other_users = Map.put(socket.assigns.other_users, user_id, %{
        color: color,
        x: 0,
        y: 0,
        relative_x: 0,
        relative_y: 0,
        in_viz: false
      })

      {:noreply, assign(socket, other_users: other_users)}
    else
      {:noreply, socket}
    end
  end
```

And now we're tracking the other users that are around as well.

We can take a look at our view piece by piece to get an idea of how this all translates to a page now:

```
          <h1 class="text-3xl mb-2 glitch-text">CURSOR POSITION TRACKER</h1>
          <div class="text-2xl glitch-text mb-2"><h1>// ACTIVE USERS: <%= map_size(@other_users) + 1 %></h1></div>
          <div class="text-2xl glitch-text mb-2"><h1>Click to draw a point</h1></div>
          <div class="grid grid-cols-2 gap-4 mb-8">
            <div class="border border-green-500 p-4">
              <div class="text-xs mb-1 opacity-70">X-COORDINATE</div>
              <div class="text-2xl font-bold tracking-wider"><%= @x_pos %></div>
            </div>
            <div class="border border-green-500 p-4">
              <div class="text-xs mb-1 opacity-70">Y-COORDINATE</div>
              <div class="text-2xl font-bold tracking-wider"><%= @y_pos %></div>
            </div>
          </div>


```

This works right off the user's state normally.

We have a count of users that looks at the other users who we are tracking around as a count + us.

It let's you know you can click to draw a point, and lists your x and y coordinates.

This all has been set in pretty straightforward ways

## Saving Points and Persistence

Now let's look at how we save points when a user clicks in the visualization area:

```elixir
def handle_event("save_point", _params, socket) do
  if socket.assigns.in_visualization do
    # Create a new favorite point with the current coordinates and user color
    new_point = %{
      x: socket.assigns.relative_x,
      y: socket.assigns.relative_y,
      color: socket.assigns.user_color,
      user_id: socket.assigns.user_id,
      timestamp: DateTime.utc_now()
    }

    # Add the new point to the list of favorite points
    updated_points = [new_point | socket.assigns.favorite_points]

    # Store the point in the ETS table
    CursorPoints.add_point(new_point)

    # Broadcast the new point to all users
    broadcast_new_point(new_point)

    {:noreply, assign(socket, favorite_points: updated_points)}
  else
    {:noreply, socket}
  end
end
```

When a user clicks in the visualization area, we:
1. Create a new point with the current coordinates, user color, and user ID
2. Add it to our local list of favorite points
3. Store it in an ETS table for persistence
4. Broadcast the new point to all connected users

The `CursorPoints` module handles the persistence using Erlang Term Storage (ETS):

```elixir
defmodule Blog.CursorPoints do
  use GenServer
  require Logger

  @table_name :cursor_favorite_points
  @max_points 1000  # Limit the number of points to prevent unbounded growth
  @clear_interval 60 * 60 * 1000  # 60 minutes in milliseconds

  # Client API functions...

  @impl true
  def init(_) do
    # Create ETS table
    table = :ets.new(@table_name, [:named_table, :set, :public])

    # Schedule periodic clearing
    schedule_clear()

    {:ok, %{table: table}}
  end

  @impl true
  def handle_cast({:add_point, point}, state) do
    # Generate a unique key for the point
    key = "#{point.user_id}-#{:os.system_time(:millisecond)}"

    # Add the point to the ETS table
    :ets.insert(@table_name, {key, point})

    # Trim the table if it gets too large
    trim_table()

    {:noreply, state}
  end

  # More implementation...
end
```

This module:
1. Creates and manages an ETS table to store points
2. Provides functions to add, retrieve, and clear points
3. Automatically trims the table if it gets too large
4. Schedules automatic clearing every 60 minutes

## Handling Other Users' Cursors

When another user moves their cursor, we receive a message via PubSub:

```elixir
def handle_info({:cursor_position, user_id, color, x, y, relative_x, relative_y, in_viz}, socket) do
  # Skip our own cursor updates
  if user_id != socket.assigns.user_id do
    # Update the other user's cursor position
    other_users = Map.put(socket.assigns.other_users, user_id, %{
      color: color,
      x: x,
      y: y,
      relative_x: relative_x,
      relative_y: relative_y,
      in_viz: in_viz
    })

    {:noreply, assign(socket, other_users: other_users)}
  else
    {:noreply, socket}
  end
end
```

This updates our local state with the other user's cursor position, which we then render in the UI.

## Automatic Clearing and Countdown Timer

To keep the canvas from getting too cluttered, we implemented an automatic clearing mechanism:

```elixir
def handle_info(:tick, socket) do
  # Update the next clear time
  next_clear = calculate_next_clear()

  # Schedule the next tick
  if connected?(socket) do
    Process.send_after(self(), :tick, 1000)
  end

  {:noreply, assign(socket, next_clear: next_clear)}
end

defp calculate_next_clear do
  # Calculate time until next scheduled clear
  now = DateTime.utc_now() |> DateTime.to_unix()
  elapsed = rem(now, @clear_interval)
  remaining = @clear_interval - elapsed

  # Format the remaining time
  hours = div(remaining, 3600)
  minutes = div(rem(remaining, 3600), 60)
  seconds = rem(remaining, 60)

  %{
    hours: hours,
    minutes: minutes,
    seconds: seconds,
    total_seconds: remaining
  }
end
```

This creates a countdown timer that shows users when the next automatic clearing will happen. The actual clearing is handled by the `CursorPoints` GenServer:

```elixir
@impl true
def handle_info(:scheduled_clear, state) do
  # Clear all points from the ETS table
  :ets.delete_all_objects(@table_name)

  # Broadcast that points were cleared
  broadcast_clear("SYSTEM")

  # Reschedule the next clearing
  schedule_clear()

  {:noreply, state}
end

defp schedule_clear do
  Process.send_after(self(), :scheduled_clear, @clear_interval)
end
```

## Presence for User Tracking

We use Phoenix Presence to track connected users:

```elixir
defp list_present_users(current_user_id) do
  BlogWeb.Presence.list(@topic)
  |> Enum.reject(fn {user_id, _} -> user_id == current_user_id end)
  |> Enum.map(fn {user_id, %{metas: [meta | _]}} ->
    {user_id, %{
      color: meta.color,
      x: get_in(meta, [:cursor, :x]) || 0,
      y: get_in(meta, [:cursor, :y]) || 0,
      relative_x: get_in(meta, [:cursor, :relative_x]) || 0,
      relative_y: get_in(meta, [:cursor, :relative_y]) || 0,
      in_viz: get_in(meta, [:cursor, :in_viz]) || false
    }}
  end)
  |> Enum.into(%{})
end
```

This function:
1. Gets the list of present users from Phoenix Presence
2. Filters out the current user
3. Extracts the relevant information for each user
4. Converts the list to a map for easy access

We also handle presence diff events to update our list of users when someone joins or leaves:

```elixir
def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
  # Update the other users list when presence changes
  other_users = list_present_users(socket.assigns.user_id)

  {:noreply, assign(socket, other_users: other_users)}
end
```

## Rendering the UI

The UI is rendered using HEEx templates with a retro hacker aesthetic:

```elixir
<div class="min-h-screen bg-black text-green-500 font-mono p-4" phx-hook="CursorTracker" id="cursor-tracker">
  <!-- Header and user info -->

  <!-- Visualization area -->
  <div
    class="relative h-64 border border-green-500 overflow-hidden cursor-crosshair"
    phx-click="save_point"
  >
    <!-- Current user's cursor -->
    <%= if @in_visualization do %>
      <!-- Cursor visualization -->
    <% else %>
      <!-- Prompt to move cursor into visualization area -->
    <% end %>

    <!-- Other users' cursors -->
    <%= for {user_id, user} <- @other_users do %>
      <%= if user.in_viz do %>
        <!-- Other user cursor visualization -->
      <% end %>
    <% end %>

    <!-- Saved points -->
    <%= for point <- @favorite_points do %>
      <!-- Point visualization -->
    <% end %>
  </div>

  <!-- System log and other UI elements -->
</div>
```

The UI includes:
1. A header showing the current cursor position
2. A visualization area where users can see cursors and points
3. A list of connected users
4. A countdown timer to the next automatic clearing
5. A button to manually clear all points
6. A system log showing recent activity

So with that, we have a pretty fun little demo in about 50 lines of JS and 100 lines of Elixir.