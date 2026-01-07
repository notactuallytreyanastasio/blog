defmodule BlogWeb.PythonDemoLive do
  use BlogWeb, :live_view
  require Logger

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
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

    socket =
      case result do
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
    <div class="os-desktop-win98">
      <div class="os-window os-window-win98" style="width: 100%; height: calc(100vh - 40px); max-width: none;">
        <div class="os-titlebar">
          <span class="os-titlebar-title">🐍 Python.exe - Elixir Integration</span>
          <div class="os-titlebar-buttons">
            <span class="os-btn">_</span>
            <span class="os-btn">□</span>
            <a href="/" class="os-btn">×</a>
          </div>
        </div>
        <div class="os-menubar">
          <span>File</span>
          <span>Edit</span>
          <span>Run</span>
          <span>Help</span>
        </div>
        <div class="os-content" style="height: calc(100% - 80px); overflow-y: auto; background: #c0c0c0;">
          <div class="p-4">
            <div class="bg-white border-2 inset p-4 mb-4">
              <h2 class="font-bold mb-2">Execute Python Code</h2>
              <p class="mb-3 text-sm text-gray-600">
                Write your Python code below and execute it directly from Elixir:
              </p>

              <form phx-submit="run-code">
                <div class="mb-3">
                  <label for="code" class="block text-sm font-bold mb-1">
                    Python Code:
                  </label>
                  <textarea
                    id="code"
                    name="code"
                    rows="8"
                    class="w-full p-2 border-2 inset font-mono text-sm bg-white"
                    spellcheck="false"
                  ><%= @code %></textarea>
                </div>

                <div class="flex items-center gap-2">
                  <button
                    type="submit"
                    class="px-4 py-2 border-2 outset bg-[#c0c0c0] font-bold flex items-center hover:bg-[#d0d0d0] active:border-inset"
                    disabled={@executing}
                  >
                    <%= if @executing do %>
                      <span class="animate-pulse mr-2">⏳</span> Executing...
                    <% else %>
                      ▶ Execute Code
                    <% end %>
                  </button>

                  <button
                    type="button"
                    phx-click="reset"
                    class="px-4 py-2 border-2 outset bg-[#c0c0c0] hover:bg-[#d0d0d0] active:border-inset"
                  >
                    Reset Example
                  </button>
                </div>
              </form>

              <%= if @result do %>
                <div class="mt-4">
                  <h3 class="font-bold mb-2">Result:</h3>
                  <div class="p-3 bg-black text-green-400 font-mono text-sm border-2 inset overflow-auto">
                    <pre class="whitespace-pre-wrap"><%= @result %></pre>
                  </div>
                </div>
              <% end %>

              <%= if @error do %>
                <div class="mt-4">
                  <h3 class="font-bold text-red-700 mb-2">Error:</h3>
                  <div class="p-3 bg-red-100 border-2 inset overflow-auto">
                    <pre class="text-sm font-mono text-red-700 whitespace-pre-wrap"><%= @error %></pre>
                  </div>
                </div>
              <% end %>
            </div>

            <div class="bg-[#ffffcc] border-2 outset p-3">
              <h3 class="font-bold mb-2">💡 Examples to Try:</h3>
              <ul class="list-disc pl-5 space-y-2 text-sm">
                <li>
                  <code class="font-mono bg-white px-1">
                    import math<br />print("The square root of 16 is", math.sqrt(16))
                  </code>
                </li>
                <li>
                  <code class="font-mono bg-white px-1">
                    print("Current date and time:")<br />import datetime<br />print(datetime.datetime.now())
                  </code>
                </li>
                <li>
                  <code class="font-mono bg-white px-1">
                    data = [1, 2, 3, 4, 5]<br />sum_of_squares = sum([x**2 for x in data])<br />print("The sum of squares is", sum_of_squares)
                  </code>
                </li>
              </ul>
            </div>
          </div>
        </div>
        <div class="os-statusbar">
          <div class="os-statusbar-section">Python 3.x</div>
          <div class="os-statusbar-section" style="flex: 1;">{if @executing, do: "Running...", else: "Ready"}</div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply,
     assign(socket,
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
