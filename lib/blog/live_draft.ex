defmodule Blog.LiveDraft do
  @moduledoc """
  In-memory cache for live draft content being streamed from the author's editor.
  Stores rendered HTML in ETS and broadcasts updates via PubSub.
  """
  use GenServer

  @table :live_drafts
  @staleness_seconds 120

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    end

    {:ok, %{}}
  end

  @doc "Store a live draft and broadcast it via PubSub"
  def update(slug, content) do
    rendered_html = render_markdown(content)
    now = DateTime.utc_now()
    :ets.insert(@table, {slug, content, rendered_html, now})

    Phoenix.PubSub.broadcast!(
      Blog.PubSub,
      "live_draft:#{slug}",
      {:live_draft_update, slug, rendered_html, now}
    )

    {:ok, rendered_html}
  end

  @doc "Get the current live draft for a slug, or :stale/:none"
  def get(slug) do
    case :ets.lookup(@table, slug) do
      [{^slug, _content, rendered_html, updated_at}] ->
        if DateTime.diff(DateTime.utc_now(), updated_at) < @staleness_seconds do
          {:ok, rendered_html, updated_at}
        else
          :stale
        end

      [] ->
        :none
    end
  end

  @doc "Clear a live draft"
  def clear(slug) do
    :ets.delete(@table, slug)

    Phoenix.PubSub.broadcast!(
      Blog.PubSub,
      "live_draft:#{slug}",
      {:live_draft_cleared, slug}
    )

    :ok
  end

  defp render_markdown(content) do
    content
    |> remove_tags_line()
    |> Earmark.as_html(code_class_prefix: "language-", escape: false)
    |> case do
      {:ok, html, _} -> process_details_in_html(html)
      {:error, html, _} -> process_details_in_html(html)
    end
  end

  defp remove_tags_line(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&String.starts_with?(String.trim(&1), "tags:"))
    |> Enum.join("\n")
  end

  defp process_details_in_html(html) do
    pattern = ~r/<details([^>]*)>\s*<summary([^>]*)>(.*?)<\/summary>\s*(.*?)<\/details>/s

    Regex.scan(pattern, html)
    |> Enum.reduce(html, fn [full_match, details_attrs, summary_attrs, summary_content, details_content], acc ->
      trimmed = String.trim(details_content)

      processed =
        case Earmark.as_html(trimmed, code_class_prefix: "language-", escape: false) do
          {:ok, inner_html, _} ->
            "<details#{details_attrs}><summary#{summary_attrs}>#{summary_content}</summary><div class=\"details-content\">#{inner_html}</div></details>"

          {:error, _, _} ->
            "<details#{details_attrs}><summary#{summary_attrs}>#{summary_content}</summary><div class=\"details-content\">#{trimmed}</div></details>"
        end

      String.replace(acc, full_match, processed, global: false)
    end)
  end
end
