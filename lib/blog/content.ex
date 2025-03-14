defmodule Blog.Content do
  @moduledoc """
  Handles parsing and categorizing posts from markdown files.
  """

  @tech_tags ~w(programming tech software coding elixir javascript phoenix blog)
  @posts_dir "priv/static/posts/"

  def list_posts do
    File.ls!(@posts_dir)
    |> Enum.map(&parse_post/1)
    |> Enum.sort_by(& &1.written_on, {:desc, Date})
  end

  defp parse_post(filename) do
    content = File.read!(@posts_dir <> filename)

    %{
      title: parse_title(content),
      tags: parse_tags(content),
      content: content,
      written_on: parse_date_from_filename(filename),
      slug: Path.basename(filename, ".md")
    }
  end

  defp parse_date_from_filename(filename) do
    case Regex.run(~r/(\d{4}-\d{2}-\d{2})/, filename) do
      [_, date] ->
        {:ok, date} = Date.from_iso8601(date)
        date

      nil ->
        {:ok, stat} = File.stat(@posts_dir <> filename)
        NaiveDateTime.to_date(stat.mtime)
    end
  end

  defp parse_title(content) do
    [_, title] = Regex.run(~r/title: (.+)/, content)
    title
  end

  defp parse_tags(content) do
    [_, tags] = Regex.run(~r/tags: (.+)/, content)
    String.split(tags, ",") |> Enum.map(&String.trim/1)
  end

  def categorize_posts(posts) do
    data =
      %{tech: tech_list, non_tech: non_tech_list} =
      Enum.reduce(posts, %{tech: [], non_tech: []}, fn post, acc ->
        has_tech_tag =
          post.tags
          |> Enum.map(& &1.name)
          |> Enum.map(&String.downcase/1)
          |> Enum.any?(fn tag ->
            Enum.any?(@tech_tags, &String.contains?(tag, &1))
          end)

        if has_tech_tag do
          Map.update!(acc, :tech, fn posts -> [post | posts] end)
        else
          Map.update!(acc, :non_tech, fn posts -> [post | posts] end)
        end
      end)

    sorted_tech = Enum.sort_by(tech_list, & &1.written_on, {:desc, Date})
    sorted_non_tech = Enum.sort_by(non_tech_list, & &1.written_on, {:desc, Date})

    data
    |> Map.put(:tech, sorted_tech)
    |> Map.put(:non_tech, sorted_non_tech)
  end
end
