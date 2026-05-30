defmodule Blog.Content do
  @moduledoc """
  Categorizes posts into tech / non-tech buckets by tag.

  Post loading/parsing lives in `Blog.Content.Post`; this module only sorts an
  existing list of posts into categories.
  """

  @tech_tags ~w(programming tech software coding elixir javascript phoenix blog)

  @spec categorize_posts([Blog.Content.Post.t()]) :: %{
          tech: [Blog.Content.Post.t()],
          non_tech: [Blog.Content.Post.t()]
        }
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
