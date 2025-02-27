defmodule Mix.Tasks.MakePost do
  use Mix.Task

  def run(args) do
    [title, tags] = args
    [date, time] = "#{DateTime.utc_now()}" |> String.split(" ")
    [time | _] = time |> String.replace(":", "-") |> String.split(".")
    fname = date <> "-" <> time
    path = "priv/static/posts/"
    file = fname <> "-" <> title <> ".md"
    body = "tags: " <> tags <> "\n"
    full_path = path <> file
    File.write(full_path, body)
    IO.puts("Wrote #{full_path}")
  end
end
