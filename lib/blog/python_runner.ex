defmodule Blog.PythonRunner do
  @moduledoc """
  Module for interacting with Python code using Pythonx.
  """
  require Logger

  @doc """
  Initializes the Python interpreter with minimal configuration.
  This only needs to be called once per application start.
  """
  def init_python do
    try do
      # Check if Python is already initialized
      # This is idempotent - safely handles being called multiple times
      config_str = """
      [project]
      name = "python_demo"
      version = "0.0.1"
      requires-python = ">=3.8"
      """

      # Log the environment variables to help with debugging
      python_path = System.get_env("PYTHONX_PYTHON_PATH", "not set")
      cache_dir = System.get_env("PYTHONX_CACHE_DIR", "not set")

      # Use uv_init without options - relying on environment variables
      Pythonx.uv_init(config_str)
      :ok
    rescue
      e in RuntimeError ->
        if String.contains?(Exception.message(e), "already been initialized") do
          Logger.info("Python interpreter was already initialized, continuing")
          :ok
        else
          Logger.error("Failed to initialize Python: #{Exception.message(e)}")
          {:error, Exception.message(e)}
        end

      e ->
        Logger.error("Unexpected error initializing Python: #{inspect(e)}")
        {:error, inspect(e)}
    end
  end

  @doc """
  Runs a simple Python "Hello World" program and logs the result.

  ## Examples

      iex> Blog.PythonRunner.run_hello_world()
      {:ok, "Hello from Python 7!"}
  """
  def run_hello_world do
    case init_python() do
      :ok ->
        try do
          # Use eval/2 which takes Python code and a map of variables
          {result, _} = Pythonx.eval("f'Hello from Python {3 + 4}!'", %{})
          message = Pythonx.decode(result)

          # Log the result
          Logger.info("Python execution result: #{message}")

          {:ok, message}
        rescue
          e ->
            Logger.error("Error executing Python code: #{inspect(e)}")
            {:error, "Failed to execute Python code: #{inspect(e)}"}
        end

      {:error, reason} ->
        {:error, "Python initialization failed: #{reason}"}
    end
  end

  @doc """
  Runs a custom Python script with the provided code.

  ## Parameters

    * `code` - The Python code to execute as a string

  ## Examples

      iex> Blog.PythonRunner.run_python_code("print('Custom message')")
      {:ok, "Custom message\\n"}
  """
  def run_python_code(code) when is_binary(code) do
    case init_python() do
      :ok ->
        try do
          # Execute the provided Python code
          {result, _} = Pythonx.eval(code, %{})
          decoded = Pythonx.decode(result)

          {:ok, decoded}
        rescue
          e ->
            Logger.error("Error executing Python code: #{inspect(e)}")
            {:error, "Failed to execute Python code: #{inspect(e)}"}
        end

      {:error, reason} ->
        {:error, "Python initialization failed: #{reason}"}
    end
  end
end
