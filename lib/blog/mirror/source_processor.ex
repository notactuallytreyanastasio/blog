defmodule Blog.Mirror.SourceProcessor do
  @moduledoc """
  Pure functions for processing source code into animated character data.

  Converts source code strings into structured data where each character
  has animation properties (duration, delay, direction) for the spinning
  code display in MirrorLive.
  """

  @type char_data :: %{
          char: String.t(),
          duration: pos_integer(),
          delay: non_neg_integer(),
          direction: -1 | 1
        }

  @doc """
  Processes source code into a list of lines, each containing character data.

  Each character gets random animation properties for the spinning display.
  """
  @spec process(String.t()) :: [[char_data()]]
  def process(source) when is_binary(source) do
    source
    |> String.split("\n")
    |> Enum.map(&process_line/1)
  end

  def process({:error, _reason}), do: process(fallback_source())
  def process(_other), do: process(fallback_source())

  @doc """
  Processes a single line of source code into character data.
  """
  @spec process_line(String.t()) :: [char_data()]
  def process_line(line) when is_binary(line) do
    line
    |> String.graphemes()
    |> Enum.map(&build_char_data/1)
  end

  @doc """
  Builds animation data for a single character.
  """
  @spec build_char_data(String.t()) :: char_data()
  def build_char_data(char) do
    %{
      char: char,
      duration: :rand.uniform(10) + 5,
      delay: :rand.uniform(5000),
      direction: if(:rand.uniform() > 0.5, do: 1, else: -1)
    }
  end

  @doc """
  Returns fallback source code when the actual source cannot be loaded.
  """
  @spec fallback_source() :: String.t()
  def fallback_source do
    """
    defmodule BlogWeb.MirrorLive do
      use BlogWeb, :live_view

      # Source code could not be loaded
      # This is a fallback representation

      def render(assigns) do
        ~H\"\"\"
        <div>
          <h1>Mirror Mirror on the wall</h1>
          <p>Source code could not be loaded</p>
        </div>
        \"\"\"
      end
    end
    """
  end
end
