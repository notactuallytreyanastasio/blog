defmodule Blog.PythonRunner do
  @moduledoc """
  Simple module for running Python code using Pythonx.
  """

  require Logger

  @doc """
  Checks if the application is running on Gigalixir.
  """
  def running_on_gigalixir? do
    # Check for typical Gigalixir environment indicators
    System.get_env("GIGALIXIR") == "true" ||
    String.contains?(System.get_env("RELEASE_COOKIE", ""), "gigalixir") ||
    File.exists?("/app/rel")
  end

  @doc """
  Checks if a directory is writable by attempting to create a test file.
  """
  def directory_writable?(path) do
    test_file = Path.join(path, "write_test_#{:rand.uniform(1000000)}")
    try do
      :ok = File.write(test_file, "test")
      File.rm(test_file)
      true
    rescue
      _ -> false
    end
  end

  @doc """
  Gets Python environment information for debugging.
  """
  def get_python_info do
    python_path = System.get_env("PYTHONX_PYTHON_PATH") || "not set"
    cache_dir = System.get_env("PYTHONX_CACHE_DIR") || "not set"

    # Check if key directories are writable
    tmp_writable = directory_writable?("/tmp")
    app_cache_writable = directory_writable?("/app/.cache")
    current_dir_writable = directory_writable?(".")

    %{
      pythonx_version: Application.spec(:pythonx, :vsn) |> to_string(),
      python_path: python_path,
      cache_dir: cache_dir,
      cache_dir_exists: if(cache_dir != "not set", do: File.exists?(cache_dir), else: false),
      cache_dir_writable: if(cache_dir != "not set", do: directory_writable?(cache_dir), else: false),
      tmp_writable: tmp_writable,
      app_cache_writable: app_cache_writable,
      current_dir_writable: current_dir_writable,
      inets_started: Application.started_applications() |> Enum.any?(fn {app, _, _} -> app == :inets end),
      on_gigalixir: running_on_gigalixir?()
    }
  end

  @doc """
  Initializes a basic Python environment with no additional packages.
  Safely handles the case where Python is already initialized.
  """
  def init do
    # Ensure cache directory exists
    cache_dir = System.get_env("PYTHONX_CACHE_DIR", "/tmp")

    # Try to create all possible cache directories
    try do
      File.mkdir_p!("/tmp/pythonx_cache")
      File.mkdir_p!("/tmp/pythonx_venv")
      File.mkdir_p!(cache_dir)
    rescue
      e -> Logger.warning("Failed to create cache directories: #{inspect(e)}")
    end

    try do
      # Initialize Python with minimal configuration
      # Use a simpler project configuration with no dependencies
      config_str = """
      [project]
      name = "python_demo"
      version = "0.0.1"
      requires-python = ">=3.8"
      """

      # Log Python environment information for debugging
      python_info = get_python_info()
      Logger.info("Python environment details: #{inspect(python_info)}")

      # Options for uv_init - use absolute paths for all values
      options = [
        cache_dir: "/tmp",
        venv_path: "/tmp/pythonx_venv",
        python_path: System.get_env("PYTHONX_PYTHON_PATH", "/usr/bin/python3")
      ]

      # Use uv_init with explicit settings
      Pythonx.uv_init(config_str, options)

      Logger.info("Python environment initialized successfully")
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

      e in UndefinedFunctionError ->
        Logger.error("UndefinedFunctionError: #{inspect(e)}")
        if e.function == :stop and e.arity == 2 and e.module == :inets do
          Logger.error("The :inets application is not started. This is required by Pythonx.")
          {:error, ":inets not started"}
        else
          {:error, "Undefined function: #{e.module}.#{e.function}/#{e.arity}"}
        end

      e in File.Error ->
        Logger.error("File system error: #{inspect(e)}")
        {:error, "File system error: #{Exception.message(e)}"}

      e ->
        Logger.error("Unexpected error initializing Python: #{inspect(e)}")
        {:error, "Failed to initialize Python: #{inspect(e)}"}
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

    case init() do
      :ok ->
        try do
          {result, _} = Pythonx.eval(python_code, %{})
          Pythonx.decode(result)
        rescue
          e -> "Error executing Python code: #{inspect(e)}"
        end
      {:error, reason} ->
        "Python is unavailable: #{reason}"
    end
  end

  @doc """
  Runs arbitrary Python code and returns the result.
  """
  def run_code(code) when is_binary(code) do
    case init() do
      :ok ->
        try do
          {result, _} = Pythonx.eval(code, %{})
          Pythonx.decode(result)
        rescue
          e -> "Error executing Python code: #{inspect(e)}"
        end
      {:error, reason} ->
        "Python is unavailable: #{reason}"
    end
  end
end
