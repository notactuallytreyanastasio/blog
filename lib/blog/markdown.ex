defmodule Blog.Markdown do
  @moduledoc """
  Earmark's interface, rendered by MDEx.

  Earmark is retired and carries a stored-XSS advisory, and its vendored
  parser does not compile on OTP 28 -- it keeps compiled regexes in module
  attributes, which can no longer be escaped:

      ** (ArgumentError) cannot inject attribute @rgx_map into function/macro
      because cannot escape #Reference<...>

  MDEx was already a dependency and already in use. This is the shape of the
  calls that were still on Earmark, so that swapping them was a change of name
  and nothing else. Sixteen call sites across seven modules is a lot of places
  to also change the shape of a return value, and most of them are pages that
  are hard to exercise.

  It is a step in a migration rather than a thing to keep. Once the call sites
  are happy with MDEx's own `{:ok, html}`, this module has no reason to exist.
  """

  @doc """
  Earmark's `as_html/2`: `{:ok, html, []}` or `{:error, source, [reason]}`.

  Earmark returned warnings in the third element and every caller ignores
  them, so this always returns an empty list there.
  """
  @spec as_html(String.t(), keyword()) :: {:ok, String.t(), list()} | {:error, String.t(), list()}
  def as_html(markdown, options \\ []) when is_binary(markdown) do
    case MDEx.to_html(markdown, mdex_options(options)) do
      {:ok, html} -> {:ok, html, []}
      {:error, reason} -> {:error, markdown, [reason]}
    end
  end

  @doc "Earmark's `as_html!/2`: the HTML, or a raise."
  @spec as_html!(String.t(), keyword()) :: String.t()
  def as_html!(markdown, options \\ []) when is_binary(markdown) do
    MDEx.to_html!(markdown, mdex_options(options))
  end

  # Two of Earmark's options are load-bearing here and the rest are not.
  #
  # `escape: false` means "let raw HTML through", which MDEx spells
  # `render: [unsafe_: true]`. Posts rely on it; the default stays escaping,
  # as Earmark's did.
  #
  # `code_class_prefix: "language-"` asked Earmark for `<code class="language-elixir">`,
  # which is what the site's highlighter reads. MDEx would otherwise highlight
  # the block itself and emit spans, so highlighting is turned off and the
  # class comes out on its own.
  #
  # `breaks: true` is Earmark's "a newline is a <br>", which MDEx calls
  # `hardbreaks`. One caller wants it.
  #
  # The extensions are on because Earmark parsed tables, strikethrough and
  # autolinks by default and MDEx does not. Turning them off would quietly
  # change how existing posts render.
  defp mdex_options(options) do
    [
      extension: [
        table: true,
        strikethrough: true,
        autolink: true,
        tasklist: true,
        footnotes: true
      ],
      render: [
        unsafe_: Keyword.get(options, :escape, true) == false,
        hardbreaks: Keyword.get(options, :breaks, false) == true
      ],
      syntax_highlight: nil
    ]
  end
end
