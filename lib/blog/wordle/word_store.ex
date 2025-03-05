defmodule Blog.Wordle.WordStore do
  @moduledoc """
  Manages ETS tables for storing valid Wordle words.
  """
  use GenServer

  @potential_words_table :wordle_potential_words
  @valid_guesses_table :wordle_valid_guesses

  def start_link(_opts \\ []) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    # Create ETS tables
    :ets.new(@potential_words_table, [:named_table, :set, :public])
    :ets.new(@valid_guesses_table, [:named_table, :set, :public])

    # Initialize tables with words
    Blog.WordleWords.potential_words()
    |> Enum.each(fn word ->
      :ets.insert(@potential_words_table, {word, true})
    end)

    Blog.WordleWords.valid_guesses()
    |> Enum.each(fn word ->
      :ets.insert(@valid_guesses_table, {word, true})
    end)

    {:ok, %{}}
  end

  def valid_guess?(word) do
    case :ets.lookup(@valid_guesses_table, word) do
      [{^word, true}] -> true
      _ -> false
    end
  end

  def potential_word?(word) do
    case :ets.lookup(@potential_words_table, word) do
      [{^word, true}] -> true
      _ -> false
    end
  end

  def get_random_word do
    # Get a random word from the potential words table
    word =
      :ets.tab2list(@potential_words_table)
      |> Enum.random()
      |> elem(0)

    word
  end
end
