defmodule BlogWeb.PostLive do
  use BlogWeb, :live_view

  def mount(%{"slug" => slug}, _session, socket) do
    case Blog.Content.Post.get_by_slug(slug) do
      nil ->
        {:ok, push_navigate(socket, to: "/")}

      post ->
        case Earmark.as_html(post.body) do
          {:ok, html, _} ->
            headers = extract_headers(post.body)
            socket = assign(socket,
              html: html,
              headers: headers,
              post: post
            )
            {:ok, socket}

          {:error, _html, errors} ->
            # Log the error and show a friendly message
            require Logger
            Logger.error("Failed to parse markdown: #{inspect(errors)}")
            {:ok, push_navigate(socket, to: "/")}
        end
    end
  end

  def render(assigns) do
    ~H"""
    <div class="px-8 py-12 font-mono text-gray-700">
      <div class="max-w-7xl mx-auto">
        <div class="mb-12 p-6 bg-gray-50 rounded-lg border-2 border-gray-200">
          <h2 class="text-xl font-bold mb-4 pb-2 border-b-2 border-gray-200">Table of Contents</h2>
          <ul class="space-y-2">
            <%= for {text, level} <- @headers do %>
              <li class={[
                "hover:text-blue-600 transition-colors",
                level_to_padding(level)
              ]}>
                <a href={"##{generate_id(text)}"}><%= text %></a>
              </li>
            <% end %>
          </ul>
        </div>

        <article class="p-8 bg-white rounded-lg border-2 border-gray-200">
          <div class="prose prose-lg prose-headings:font-mono prose-headings:font-bold prose-h1:text-4xl prose-h2:text-3xl prose-h3:text-2xl max-w-none">
            <%= raw(@html) %>
          </div>
        </article>
      </div>
    </div>
    """
  end

  defp extract_headers(markdown) do
    markdown
    |> String.split("\n")
    |> Enum.filter(&header?/1)
    |> Enum.map(fn line ->
      {text, level} = parse_header(line)
      {text, level}
    end)
  end

  defp header?(line) do
    String.match?(line, ~r/^#+\s+.+$/)
  end

  defp parse_header(line) do
    [hashes | words] = String.split(line, " ")
    level = String.length(hashes)
    text = Enum.join(words, " ")
    {text, level}
  end

  defp generate_id(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w-]+/, "-")
    |> String.trim("-")
  end

  defp level_to_padding(1), do: "pl-0"
  defp level_to_padding(2), do: "pl-4"
  defp level_to_padding(3), do: "pl-8"
  defp level_to_padding(4), do: "pl-12"
  defp level_to_padding(_), do: "pl-16"
end
