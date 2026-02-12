defmodule BlogWeb.SmartStepsLive.Connect do
  use BlogWeb, :live_view

  alias Blog.SmartSteps.SessionServer

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Smart Steps - Join",
       session_code: "",
       error: nil
     )}
  end

  @impl true
  def handle_event("update_code", %{"code" => code}, socket) do
    clean = String.replace(code, ~r/[^0-9]/, "") |> String.slice(0, 6)
    {:noreply, assign(socket, session_code: clean, error: nil)}
  end

  @impl true
  def handle_event("join_session", _params, socket) do
    code = socket.assigns.session_code

    if String.length(code) != 6 do
      {:noreply, assign(socket, error: "Please enter a 6-digit session code")}
    else
      if SessionServer.session_exists?(code) do
        {:noreply, push_navigate(socket, to: ~p"/smart-steps/play/#{code}?role=participant")}
      else
        {:noreply, assign(socket, error: "Session not found. Check the code and try again.")}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="ss-page flex items-center justify-center">
      <div class="max-w-sm w-full px-4 py-20 text-center">
        <.link
          navigate={~p"/smart-steps"}
          class="inline-flex items-center gap-1 text-xs mb-8 transition-colors"
          style="color: #636E72;"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m12 19-7-7 7-7"/><path d="M19 12H5"/></svg>
          Back
        </.link>

        <h1 class="text-2xl font-bold mb-2" style="color: #2D3436;">Join a Session</h1>
        <p class="text-sm mb-8" style="color: #636E72;">
          Enter the 6-digit session code from your facilitator.
        </p>

        <form phx-submit="join_session">
          <input
            type="text"
            name="code"
            value={@session_code}
            phx-change="update_code"
            placeholder="000000"
            maxlength="6"
            inputmode="numeric"
            autocomplete="off"
            class="w-full text-center text-3xl font-mono tracking-[0.3em] py-4 rounded-xl focus:outline-none transition-colors"
            style={"border: 2px solid #{if @error, do: "#EC407A", else: "#E0E0E0"}; color: #2D3436;"}
          />
          <p :if={@error} class="mt-2 text-sm text-center" style="color: #EC407A;"><%= @error %></p>

          <button
            type="submit"
            disabled={String.length(@session_code) != 6}
            class="w-full mt-4 py-3 rounded-xl font-semibold text-sm transition-colors"
            style={if String.length(@session_code) == 6, do: "background-color: #42A5F5; color: white;", else: "background-color: #F5F5F5; color: #636E72; cursor: not-allowed;"}
          >
            Connect
          </button>
        </form>
      </div>
    </div>
    """
  end
end
