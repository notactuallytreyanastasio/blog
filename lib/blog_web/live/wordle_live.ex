defmodule BlogWeb.WordleLive do
  use BlogWeb, :live_view
  require Logger
  alias Blog.Wordle.WordStore

  @max_attempts 6
  @word_length 5

  @impl true
  def mount(_params, _session, socket) do
    # Pick a random word using WordStore
    word = WordStore.get_random_word()

    {:ok,
     assign(socket,
       target_word: word,
       page_title: "Wordle Clone",
       meta_attrs: [
         %{name: "description", content: "A LiveView wordle clone"},
         %{property: "og:title", content: "Wordle Clone"},
         %{
           property: "og:description",
           content: "A LiveView wordle clone"
         },
         %{property: "og:type", content: "website"}
       ],
       current_guess: "",
       guesses: [],
       game_over: false,
       message: nil,
       used_letters: %{}, # Will store letters and their states (correct, present, absent)
       max_attempts: @max_attempts
     )}
  end

  @impl true
  def handle_event("new-game", _params, socket) do
    {:noreply,
     assign(socket,
       target_word: WordStore.get_random_word(),
       current_guess: "",
       guesses: [],
       game_over: false,
       message: nil,
       used_letters: %{},
       max_attempts: @max_attempts
     )}
  end

  @impl true
  def handle_event("key-press", %{"key" => key}, socket) do
    case {socket.assigns.game_over, key, String.length(socket.assigns.current_guess)} do
      {true, _key, _length} ->
        {:noreply, socket}

      {false, "Enter", @word_length} ->
        handle_guess(socket)

      {false, "Backspace", _length} ->
        {:noreply, assign(socket, current_guess: String.slice(socket.assigns.current_guess, 0..-2))}

      {false, key, length} when length < @word_length ->
        if key =~ ~r/^[a-zA-Z]$/ do
          {:noreply,
           assign(socket,
             current_guess: socket.assigns.current_guess <> String.downcase(key)
           )}
        else
          {:noreply, socket}
        end

      {false, _key, _length} ->
        {:noreply, socket}
    end
  end

  defp handle_guess(socket) do
    guess = socket.assigns.current_guess

    if WordStore.valid_guess?(guess) do
      result = check_guess(guess, socket.assigns.target_word)
      used_letters = update_used_letters(socket.assigns.used_letters, guess, result)
      guesses = socket.assigns.guesses ++ [{guess, result}]

      won = guess == socket.assigns.target_word
      lost = length(guesses) >= socket.assigns.max_attempts

      socket =
        socket
        |> assign(
          current_guess: "",
          guesses: guesses,
          used_letters: used_letters,
          game_over: won || lost,
          message:
            case {won, lost} do
              {true, _} -> "Congratulations! You won!"
              {false, true} -> "Game Over! The word was #{socket.assigns.target_word}"
              {false, false} -> nil
            end
        )

      {:noreply, socket}
    else
      {:noreply, assign(socket, message: "Not in word list")}
    end
  end

  defp check_guess(guess, target) do
    # Convert strings to character lists
    guess_chars = String.graphemes(guess)
    target_chars = String.graphemes(target)

    # First pass: Find correct letters (green)
    {greens, remaining_target} =
      Enum.zip(guess_chars, target_chars)
      |> Enum.reduce({[], target_chars}, fn {g, t}, {results, target_acc} ->
        case g == t do
          true -> {results ++ [:correct], List.delete(target_acc, t)}
          false -> {results ++ [nil], target_acc}
        end
      end)

    # Second pass: Find present letters (yellow)
    guess_chars
    |> Enum.with_index()
    |> Enum.map(fn {char, i} ->
      case {Enum.at(greens, i), char in remaining_target} do
        {:correct, _} -> :correct
        {_, true} ->
          remaining_target = List.delete(remaining_target, char)
          :present
        _ -> :absent
      end
    end)
  end

  defp update_used_letters(used_letters, guess, results) do
    Enum.zip(String.graphemes(guess), results)
    |> Enum.reduce(used_letters, fn {char, result}, acc ->
      # Only upgrade the status of a letter (absent -> present -> correct)
      current_status = Map.get(acc, char)

      cond do
        current_status == :correct -> acc
        result == :correct -> Map.put(acc, char, :correct)
        current_status == :present -> acc
        result == :present -> Map.put(acc, char, :present)
        is_nil(current_status) -> Map.put(acc, char, result)
        true -> acc
      end
    end)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-[500px] p-2 md:p-4">
      <h1 class="text-3xl font-bold text-center mb-4">Wordle Clone</h1>

      <div class="grid grid-rows-6 gap-[5px] mb-4" id="game-board" phx-window-keyup="key-press">
        <%= for {guess, result} <- @guesses do %>
          <div class="grid grid-cols-5 gap-[5px]">
            <%= for {letter, status} <- Enum.zip(String.graphemes(guess), result) do %>
              <div class={"w-full aspect-square flex items-center justify-center text-2xl font-bold text-white rounded-none uppercase transition-colors duration-500 #{color_class(status)}"}>
                <%= letter %>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if length(@guesses) < @max_attempts && !@game_over do %>
          <div class="grid grid-cols-5 gap-[5px]">
            <%= for i <- 0..4 do %>
              <div class={"w-full aspect-square flex items-center justify-center text-2xl font-bold rounded-none uppercase border-2 #{if i < String.length(@current_guess), do: "border-gray-600", else: "border-gray-300"}"}>
                <%= String.at(@current_guess, i) %>
              </div>
            <% end %>
          </div>

          <%= if length(@guesses) < @max_attempts - 1 do %>
            <%= for _i <- (length(@guesses) + 1)..(@max_attempts - 1) do %>
              <div class="grid grid-cols-5 gap-[5px]">
                <%= for _j <- 1..5 do %>
                  <div class="w-full aspect-square flex items-center justify-center text-2xl font-bold rounded-none border-2 border-gray-200">
                  </div>
                <% end %>
              </div>
            <% end %>
          <% end %>
        <% end %>
      </div>

      <%= if @message do %>
        <div class="text-center mb-4 font-bold text-lg">
          <%= @message %>
        </div>
      <% end %>

      <div class="grid grid-rows-3 gap-1.5 px-2">
        <%= for row <- keyboard_layout() do %>
          <div class="flex justify-center gap-1.5">
            <%= for key <- row do %>
              <button
                class={"px-2 py-4 rounded text-sm font-bold min-w-[2rem] md:min-w-[2.5rem] #{if key in ["Enter", "Backspace"], do: "text-xs min-w-[4rem]"} #{keyboard_color_class(Map.get(@used_letters, key))}"}
                phx-click="key-press"
                phx-value-key={key}
              >
                <%= if key == "Backspace" do %>
                  ⌫
                <% else %>
                  <%= String.upcase(key) %>
                <% end %>
              </button>
            <% end %>
          </div>
        <% end %>
      </div>

      <%= if @game_over do %>
        <div class="text-center mt-8">
          <button
            class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700"
            phx-click="new-game"
          >
            New Game
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp keyboard_layout do
    [
      ~w(q w e r t y u i o p),
      ~w(a s d f g h j k l),
      ~w(Enter z x c v b n m Backspace)
    ]
  end

  defp color_class(:correct), do: "bg-green-600 border-green-600"
  defp color_class(:present), do: "bg-yellow-500 border-yellow-500"
  defp color_class(:absent), do: "bg-gray-600 border-gray-600"
  defp color_class(_), do: "border-2 border-gray-300"

  defp keyboard_color_class(:correct), do: "bg-green-600 text-white"
  defp keyboard_color_class(:present), do: "bg-yellow-500 text-white"
  defp keyboard_color_class(:absent), do: "bg-gray-600 text-white"
  defp keyboard_color_class(_), do: "bg-gray-200"

end
