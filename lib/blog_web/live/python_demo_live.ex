defmodule BlogWeb.PythonDemoLive do
  use BlogWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      python_result: nil,
      custom_code: "print('Hello from custom Python code!')",
      custom_result: nil,
      error: nil,
      meta_attrs: [
        %{name: "title", content: "A python interpreter in the browser, run via Elixir webserver"},
        %{
          name: "description",
          content:
          "Just go nuts. You really can run arbitrary python code right now"
        },
        %{
          property: "og:title",
          content: "lol a poor man's IDLE or something?"
        },
      ]
    )}
  end

  @impl true
  def handle_event("run-hello-world", _params, socket) do
    # Run the hello world function
    case Blog.PythonRunner.run_hello_world() do
      {:ok, result} ->
        {:noreply, assign(socket, python_result: result, error: nil)}

      {:error, error_msg} ->
        {:noreply, assign(socket, error: error_msg)}
    end
  end

  @impl true
  def handle_event("run-custom-code", %{"code" => code}, socket) do
    case Blog.PythonRunner.run_python_code(code) do
      {:ok, result} ->
        {:noreply, assign(socket, custom_result: result, error: nil)}

      {:error, error_msg} ->
        {:noreply, assign(socket, error: error_msg)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-3xl p-4">
      <h1 class="text-2xl font-bold mb-4">Python Interoperability Demo</h1>

      <div class="mb-8 p-4 bg-gray-100 rounded-lg">
        <h2 class="text-xl font-semibold mb-2">Hello World Example</h2>
        <p class="mb-4">Run a simple Python "Hello World" program:</p>

        <button phx-click="run-hello-world" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
          Run Hello World
        </button>

        <%= if @python_result do %>
          <div class="mt-4 p-3 bg-white rounded border border-gray-300">
            <h3 class="font-semibold text-gray-700">Result:</h3>
            <pre class="mt-2 p-2 bg-gray-50 rounded"><%= @python_result %></pre>
          </div>
        <% end %>
      </div>

      <div class="p-4 bg-gray-100 rounded-lg">
        <h2 class="text-xl font-semibold mb-2">Custom Python Code</h2>
        <p class="mb-4">Enter your own Python code to execute:</p>

        <form phx-submit="run-custom-code">
          <textarea name="code" rows="5" class="w-full p-2 border border-gray-300 rounded mb-4 font-mono"><%= @custom_code %></textarea>

          <button type="submit" class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded">
            Execute Code
          </button>
        </form>

        <%= if @custom_result do %>
          <div class="mt-4 p-3 bg-white rounded border border-gray-300">
            <h3 class="font-semibold text-gray-700">Result:</h3>
            <pre class="mt-2 p-2 bg-gray-50 rounded"><%= @custom_result %></pre>
          </div>
        <% end %>

        <%= if @error do %>
          <div class="mt-4 p-3 bg-red-100 rounded border border-red-300 text-red-700">
            <h3 class="font-semibold">Error:</h3>
            <pre class="mt-2 p-2 bg-red-50 rounded"><%= @error %></pre>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
