defmodule Blog.LiveDraft do
  @moduledoc """
  In-memory cache for live draft content being streamed from the author's editor.
  Stores rendered HTML in ETS and broadcasts updates via PubSub.
  """
  use GenServer

  @table :live_drafts
  @staleness_seconds 120
  @posts_dir (:code.priv_dir(:blog) |> to_string()) <> "/static/posts/"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_) do
    if :ets.whereis(@table) == :undefined do
      :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    end

    {:ok, %{commit_timers: %{}}}
  end

  @impl true
  def handle_cast({:schedule_commit, slug}, %{commit_timers: timers} = state) do
    if timer = Map.get(timers, slug) do
      Process.cancel_timer(timer)
    end

    timer = Process.send_after(self(), {:git_commit, slug}, 10_000)
    {:noreply, %{state | commit_timers: Map.put(timers, slug, timer)}}
  end

  @impl true
  def handle_info({:git_commit, slug}, %{commit_timers: timers} = state) do
    git_commit_post(slug)
    {:noreply, %{state | commit_timers: Map.delete(timers, slug)}}
  end

  @doc "Store a live draft, persist to disk, and broadcast via PubSub"
  def update(slug, content) do
    rendered_html = render_markdown(content)
    now = DateTime.utc_now()
    :ets.insert(@table, {slug, content, rendered_html, now})

    persist_to_file(slug, content)
    GenServer.cast(__MODULE__, {:schedule_commit, slug})

    Phoenix.PubSub.broadcast!(
      Blog.PubSub,
      "live_draft:#{slug}",
      {:live_draft_update, slug, rendered_html, now}
    )

    {:ok, rendered_html}
  end

  @doc "Apply a line-level diff to the stored content for a slug"
  def apply_diff(slug, ops) do
    current_content =
      case :ets.lookup(@table, slug) do
        [{^slug, content, _html, _at}] -> content
        [] -> ""
      end

    current_lines = String.split(current_content, "\n")
    new_lines = apply_ops(current_lines, ops)
    new_content = Enum.join(new_lines, "\n")

    update(slug, new_content)
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

  defp apply_ops(lines, ops) do
    {result, remaining} =
      Enum.reduce(ops, {[], lines}, fn
        ["eq", n], {acc, rem} ->
          {eq, rest} = Enum.split(rem, n)
          {acc ++ eq, rest}

        ["del", n], {acc, rem} ->
          {_deleted, rest} = Enum.split(rem, n)
          {acc, rest}

        ["ins", new_lines], {acc, rem} ->
          {acc ++ new_lines, rem}
      end)

    result ++ remaining
  end

  defp find_post_file(slug) do
    Path.wildcard(@posts_dir <> "*-#{slug}.md")
    |> Enum.reject(fn file ->
      file |> Path.basename(".md") |> String.split("-") |> List.last() |> String.length() == 32
    end)
    |> List.first()
  end

  defp persist_to_file(slug, content) do
    case find_post_file(slug) do
      nil -> :ok
      path -> File.write(path, content)
    end
  end

  defp git_commit_post(slug) do
    case find_post_file(slug) do
      nil ->
        :ok

      path ->
        try do
          dir = Path.dirname(path)

          case System.cmd("git", ["rev-parse", "--show-toplevel"], cd: dir, stderr_to_stdout: true) do
            {root, 0} ->
              root = String.trim(root)
              System.cmd("git", ["add", path], cd: root, stderr_to_stdout: true)

              System.cmd("git", ["commit", "-m", "live draft: update #{slug}"],
                cd: root,
                stderr_to_stdout: true
              )

            _ ->
              :ok
          end
        rescue
          _ -> :ok
        end
    end
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
