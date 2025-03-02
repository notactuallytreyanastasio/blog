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
    # Get Python environment information
    python_info = PythonRunner.get_python_info()

    # Initialize the Python environment
    python_status = case PythonRunner.init() do
      :ok -> :available
      {:error, reason} -> {:unavailable, reason}
    end

    # Get the hello world result if Python is available
    hello_result = PythonRunner.hello_world()

    {:ok, assign(socket,
      code: @python_example,
      result: "",
      hello_result: hello_result,
      python_status: python_status,
      python_info: python_info
    )}
  end

  @impl true
  def handle_event("run-code", %{"code" => code}, socket) do
    result = PythonRunner.run_code(code)
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
            <p>Reason: <%= if is_tuple(@python_status), do: elem(@python_status, 1), else: @python_status %></p>
          </div>
        <% end %>

        <div class="mt-4">
          <h3 class="text-lg font-semibold">Python Environment Info</h3>
          <div class="bg-white p-2 rounded mt-2 text-sm font-mono">
            <div><span class="font-bold">Pythonx Version:</span> <%= @python_info.pythonx_version %></div>
            <div><span class="font-bold">Python Path:</span> <%= @python_info.python_path %></div>
            <div><span class="font-bold">Cache Dir:</span> <%= @python_info.cache_dir %></div>
            <div><span class="font-bold">Cache Exists:</span> <%= @python_info.cache_dir_exists %></div>
            <div><span class="font-bold">Cache Writable:</span> <%= @python_info.cache_dir_writable %></div>
            <div><span class="font-bold">/tmp Writable:</span> <%= @python_info.tmp_writable %></div>
            <div><span class="font-bold">/app/.cache Writable:</span> <%= @python_info.app_cache_writable %></div>
            <div><span class="font-bold">Current Dir Writable:</span> <%= @python_info.current_dir_writable %></div>
            <div><span class="font-bold">Inets Started:</span> <%= @python_info.inets_started %></div>
            <div><span class="font-bold">On Gigalixir:</span> <%= @python_info.on_gigalixir %></div>
          </div>
        </div>
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
