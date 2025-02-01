defmodule BlogWeb.PostLive do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    # This is example markdown - you'll want to load this from a file or database
    markdown = """
    # My Amazing Blog Post

    ## Introduction
    This is a sample blog post written in markdown.

    ## Main Ideas
    Here are some key points to consider:

    ### First Point
    This is an important consideration.

    ### Second Point
    Another crucial element to discuss.

    ## Conclusion
    That wraps up our main points.
    """

    {:ok, html, _} = Earmark.as_html(markdown)
    headers = extract_headers(markdown)

    socket = assign(socket,
      html: html,
      headers: headers
    )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8 font-mono text-gray-700">
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

      <div class="prose prose-lg max-w-none p-6 bg-white rounded-lg border-2 border-gray-200">
        <%= raw(@html) %>
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
