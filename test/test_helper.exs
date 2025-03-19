ExUnit.start(exclude: [:db])

# Add tags for different test categories
ExUnit.configure(include: [:wordle], exclude: [:db])

if System.get_env("SKIP_DB") == "true" do
  IO.puts("Running tests without database connection")
else
  # Setup normal database sandbox mode
  try do
    Ecto.Adapters.SQL.Sandbox.mode(Blog.Repo, :manual)
  rescue
    e ->
      IO.puts("Error setting up database sandbox: #{inspect(e)}")
      IO.puts("Consider running with SKIP_DB=true or use test tags (mix test --only wordle)")
  end
end
