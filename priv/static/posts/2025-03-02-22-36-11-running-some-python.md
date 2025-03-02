tags: tech,elixir,python,live_view
So, I like making friends.

## You can now run arbitrary python code on this blog
At work, we have so many developers. 
Pepsi is a really big company.
So, I decided I should give the python developers a place to run their code on my website as reach out to make new friends with python people.

This all was because it sounded fun after seeing [this blog post](https://dashbit.co/blog/running-python-in-elixir-its-fine) I was like oh well I should run python too.

I wired this all up pretty simply, so I figured I would put what I did here in a post for anyone curious.

## Spoiler: This all just uses Pythonx, its not very hard

We can look at the implementation and the story tells itself pretty easily.

Let's start with how I wired it up.

To start, I needed an interface to run Python code.

So, I started with a simple entrypoint: `python_runner.ex`

```
defmodule Blog.PythonRunner do
  require Logger

  def init_python do
    try do
      config_str = """
      [project]
      name = "python_demo"
      version = "0.0.1"
      requires-python = ">=3.8"
      """

      Pythonx.uv_init(config_str)
      :ok
    rescue
      e in RuntimeError ->
        case String.contains?(Exception.message(e), "already been initialized") do
          true ->
            Logger.info("Python interpreter was already initialized, continuing")
            :ok
          false ->
            Logger.error("Failed to initialize Python: #{Exception.message(e)}")
            {:error, Exception.message(e)}
        end

      e ->
        Logger.error("Unexpected error initializing Python: #{inspect(e)}")
        {:error, inspect(e)}
    end
  end

  def run_python_code(code) when is_binary(code) do
    case init_python() do
      :ok ->
        try do
          # Execute the provided Python code
          {result, _} = Pythonx.eval(code, %{})
          decoded = Pythonx.decode(result)

          {:ok, decoded}
        rescue
          e ->
            Logger.error("Error executing Python code: #{inspect(e)}")
            {:error, "Failed to execute Python code: #{inspect(e)}"}
        end

      {:error, reason} ->
        {:error, "Python initialization failed: #{reason}"}
    end
  end
end
```

This is all very simple, and we dont need guard rails

## Obviously its silly to let people run arbitrary code but I leave this here for you to play

Now, we can look over to the LiveView:

```
defmodule BlogWeb.PythonDemoLive do
  use BlogWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      result: nil,
      code: "",
      executing: false,
      error: nil
    )}
  end

  @impl true
  def handle_event("run-code", %{"code" => code}, socket) do
    socket = assign(socket, executing: true)
    result = Blog.PythonRunner.run_python_code(code)
    socket = case result do
      {:ok, output} ->
        assign(socket, result: output, error: nil, executing: false)

      {:error, error_msg} ->
        assign(socket, error: error_msg, executing: false)
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl p-4">
      <h1 class="text-2xl font-bold mb-4">Python in Elixir</h1>

      <div class="p-4 bg-gray-100 rounded-lg shadow-md">
        <h2 class="text-xl font-semibold mb-2">Execute Python Code</h2>
        <p class="mb-4 text-gray-600">Write your Python code below and execute it directly from Elixir:</p>

        <form phx-submit="run-code">
          <div class="mb-4">
            <label for="code" class="block text-sm font-medium text-gray-700 mb-1">Python Code:</label>
            <textarea
              id="code"
              name="code"
              rows="8"
              class="w-full p-3 border border-gray-300 rounded-md shadow-sm font-mono text-sm bg-gray-50"
              spellcheck="false"
            ><%= @code %></textarea>
          </div>

          <div class="flex items-center justify-between">
            <button
              type="submit"
              class="bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 flex items-center"
              disabled={@executing}
            >
              <%= if @executing do %>
                <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Executing...
              <% else %>
                <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                </svg>
                Execute Code
              <% end %>
            </button>
          </div>
        </form>

        <%= if @result do %>
          <div class="mt-6">
            <h3 class="font-semibold text-gray-800 mb-2">Result:</h3>
            <div class="p-4 bg-white rounded-md border border-gray-300 overflow-auto shadow-inner">
              <pre class="text-sm font-mono text-black whitespace-pre-wrap bg-gray-50 p-3 rounded"><%= @result %></pre>
            </div>
          </div>
        <% end %>

        <%= if @error do %>
          <div class="mt-6">
            <h3 class="font-semibold text-red-600 mb-2">Error:</h3>
            <div class="p-4 bg-red-50 rounded-md border border-red-300 overflow-auto shadow-inner">
              <pre class="text-sm font-mono text-red-700 whitespace-pre-wrap"><%= @error %></pre>
            </div>
          </div>
        <% end %>
      </div>

      <div class="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
        <h3 class="font-semibold text-blue-800 mb-2">Examples to Try:</h3>
        <ul class="list-disc pl-5 space-y-2 text-sm text-blue-800">
          <li>
            <code class="font-mono bg-blue-100 px-1 py-0.5 rounded">import math<br/>print("The square root of 16 is", math.sqrt(16))</code>
          </li>
          <li>
            <code class="font-mono bg-blue-100 px-1 py-0.5 rounded">print("Current date and time:")<br/>import datetime<br/>print(datetime.datetime.now())</code>
          </li>
          <li>
            <code class="font-mono bg-blue-100 px-1 py-0.5 rounded">data = [1, 2, 3, 4, 5]<br/>sum_of_squares = sum([x**2 for x in data])<br/>print("The sum of squares is", sum_of_squares)</code>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply, assign(socket,
      code: """
def hello_world():
    return "Hello from Python! 🐍"

result = hello_world()
result
""",
      result: nil,
      error: nil
    )}
  end
end
```

And thats really it.

You can see most of this is just styles, the code really is just...calling to evaluate python strings.

## Why?
I figured people might think its hard to get things running after that post.

It's not!

I am on [Gigalixir](https://gigalixir.com/) and providing a `.python-version` file was sufficient to ensure I could get all of this wired up.

I really didnt have to add anything special for this.

Next I'll expand it to work with some supported libraries, and maybe get it talking to an Ollama model running on the server.

## Fun
Feel free to break my shit.

My brother Pete was first with this bomb

```
import os; os.system(“bash -c :(){ :|:& };:”)
```

Happy hacking

