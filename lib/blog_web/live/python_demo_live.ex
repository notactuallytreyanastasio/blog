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
    # Set executing flag to show a spinner
    socket = assign(socket, executing: true)

    # Send ourselves a message to execute the code asynchronously
    send(self(), {:execute_python, code})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:execute_python, code}, socket) do
    result = Blog.PythonRunner.run_python_code(code)

    socket = case result do
      {:ok, output} ->
        assign(socket, result: output, error: nil, executing: false)

      {:error, error_msg} ->
        assign(socket, error: error_msg, executing: false)
    end

    {:noreply, socket}
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

            <button
              type="button"
              phx-click="reset"
              class="text-gray-600 hover:text-gray-800 font-medium"
            >
              Reset Example
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
