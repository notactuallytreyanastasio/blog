defmodule BlogWeb.PythonLive.Index do
  use BlogWeb, :live_view
  alias Blog.PythonRunner
  require Logger

  @python_example """
  import random

  # Roll some dice
  dice = [random.randint(1, 6) for _ in range(3)]
  f"You rolled: {dice} (sum: {sum(dice)})"
  """

  @impl true
  def mount(_params, _session, socket) do
    # Initialize the Python environment - now returns :ok instead of {:ok, _}
    python_status = case PythonRunner.init() do
      :ok -> :available
      {:error, reason} -> {:unavailable, reason}
    end

    # Get the hello world result
    hello_result = if python_status == :available do
      try do
        {result, _} = PythonRunner.hello_world()
        result
      rescue
        e ->
          Logger.error("Error running hello world: #{inspect(e)}")
          "Error: #{inspect(e)}"
      end
    else
      "Python unavailable"
    end

    {:ok, assign(socket,
      code: @python_example,
      result: "",
      hello_result: hello_result,
      python_status: python_status
    )}
  end

  @impl true
  def handle_event("run-code", %{"code" => code}, socket) do
    result = if socket.assigns.python_status == :available do
      try do
        PythonRunner.run_code(code)
      rescue
        e ->
          Logger.error("Error executing Python code: #{inspect(e)}")
          "Error: #{inspect(e)}"
      end
    else
      "Python is unavailable"
    end

    Logger.info("Python code execution result: #{inspect(result)}")
    {:noreply, assign(socket, result: result)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-2xl font-bold mb-4">Python Integration Demo</h1>

      <div class="mb-6 p-4 rounded bg-gray-100">
        <h2 class="text-xl font-semibold mb-2">Python Status</h2>
        <%= if @python_status == :available do %>
          <div class="text-green-600 font-bold">✅ Python is available</div>
        <% else %>
          <div class="text-red-600 font-bold">❌ Python is unavailable</div>
          <div class="mt-2 p-2 bg-yellow-100 rounded">
            <p>Reason: <%= inspect(@python_status) %></p>
          </div>
        <% end %>
      </div>

      <div class="mb-6 p-4 rounded bg-gray-100">
        <h2 class="text-xl font-semibold mb-2">Hello from Python</h2>
        <div class="p-2 bg-white rounded border">
          <%= @hello_result %>
        </div>
      </div>

      <div class="mb-6">
        <h2 class="text-xl font-semibold mb-2">Try Python Code</h2>
        <form phx-submit="run-code">
          <div class="mb-4">
            <textarea
              name="code"
              rows="10"
              class="w-full p-2 border rounded font-mono"
              placeholder="Enter Python code here"
              disabled={@python_status != :available}
            ><%= @code %></textarea>
          </div>
          <button
            type="submit"
            class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"
            disabled={@python_status != :available}
          >
            Run Code
          </button>
        </form>
      </div>

      <%= if @result != "" do %>
        <div class="mt-4">
          <h3 class="text-lg font-semibold mb-2">Result</h3>
          <div class="p-4 bg-gray-100 rounded font-mono whitespace-pre-wrap">
            <%= @result %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
