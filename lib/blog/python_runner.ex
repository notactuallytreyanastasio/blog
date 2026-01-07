defmodule Blog.PythonRunner do
  require Logger

  def init_python do
    try do
      config_str = """
      [project]
      name = "python_demo"
      version = "0.0.1"
      requires-python = ">=3.8"
      """

      _python_path = System.get_env("PYTHONX_PYTHON_PATH", "not set")
      _cache_dir = System.get_env("PYTHONX_CACHE_DIR", "not set")
      Pythonx.uv_init(config_str)
      :ok
    rescue
      e in RuntimeError ->
        case String.contains?(Exception.message(e), "already been initialized") do
          true ->
            Logger.info("Python interpreter was already initialized, continuing")
            :ok

          false ->
            Logger.error("Failed to initialize Python: #{Exception.message(e)}")
            {:error, Exception.message(e)}
        end

      e ->
        Logger.error("Unexpected error initializing Python: #{inspect(e)}")
        {:error, inspect(e)}
    end
  end

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
