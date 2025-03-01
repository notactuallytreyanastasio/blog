defmodule Blog.PythonRunner do
  @moduledoc """
  Simple module for running Python code using Pythonx.
  """

  require Logger

  @doc """
  Initializes a basic Python environment with no additional packages.
  Safely handles the case where Python is already initialized.
  """
  def init do
    try do
      # Initialize Python with minimal configuration
      Pythonx.uv_init("""
      [project]
      name = "python_demo"
      version = "0.0.1"
      requires-python = ">=3.8"
      dependencies = []
      """)

      Logger.info("Python environment initialized successfully")
      :ok
    rescue
      e in RuntimeError ->
        if String.contains?(Exception.message(e), "already been initialized") do
          Logger.info("Python interpreter was already initialized, continuing")
          :ok
        else
          Logger.error("Failed to initialize Python: #{Exception.message(e)}")
          reraise e, __STACKTRACE__
        end
    end
  end

  @doc """
  Runs a basic hello world Python script and returns the result.
  """
  def hello_world do
    python_code = """
    def say_hello():
        return "Hello from Python! 🐍"

    result = say_hello()
    result
    """

    {result, _} = Pythonx.eval(python_code, %{})
    Pythonx.decode(result)
  end

  @doc """
  Runs arbitrary Python code and returns the result.
  """
  def run_code(code) when is_binary(code) do
    {result, _} = Pythonx.eval(code, %{})
    Pythonx.decode(result)
  end
end
