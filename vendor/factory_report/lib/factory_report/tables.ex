defmodule FactoryReport.Tables do
  @moduledoc false
  # Cumulative count / errors / duration_us per repo and table, in one public
  # ETS table written from whichever process ran the query.
  #
  # The table is Ecto's `source` in the query event's metadata. Checked by
  # running ecto_sql 3.14.0 + postgrex 0.22.4 against Postgres (not read
  # from memory): `Repo.all/insert/update_all` on a schema or on a
  # schemaless `from p in "posts"` carry the FROM table ("posts"; a join is
  # counted under its first table only); `Repo.query/3`, and the `begin` and
  # `commit` of a transaction, carry `source: nil`. Those are kept under the
  # table `nil`, so a repo's tables add up to its `db.query` total.
  #
  # Rows: {{repo, table}, count, errors, duration_us}   table a string or nil
  #       {:pairs, n}                                    how many pairs it holds
  #
  # A pair seen for the first time is admitted while fewer than @max_pairs
  # are held, else the query goes to {repo, "(other)"}: table names come
  # from schemas, a fixed set, so the cap is only a guard.

  alias FactoryReport.Streams

  @tab :factory_report_tables
  @max_pairs 200
  @other "(other)"

  def create do
    :ets.new(@tab, [:named_table, :public, :set, write_concurrency: true, read_concurrency: true])
  end

  @doc "One query of `repo` (its name) on `source`. O(1) on the usual path."
  def hit(repo, source, native, error?) do
    count({repo, table(source)}, [{2, 1}, {3, if(error?, do: 1, else: 0)}, {4, Streams.to_us(native)}])
  end

  defp table(source) when is_binary(source), do: Streams.cut(source)
  defp table(nil), do: nil
  defp table(source), do: Streams.cut(source)

  defp count(key, ops) do
    :ets.update_counter(@tab, key, ops)
    :ok
  catch
    :error, :badarg -> first(key, ops)
  end

  defp first({repo, _} = key, ops) do
    key =
      if held() < @max_pairs and :ets.insert_new(@tab, {key, 0, 0, 0}) do
        :ets.update_counter(@tab, :pairs, {2, 1}, {:pairs, 0})
        key
      else
        # Full, or another process admitted it in between (then the key is
        # there and update_counter below finds it).
        if :ets.member(@tab, key), do: key, else: {repo, @other}
      end

    :ets.update_counter(@tab, key, ops, {key, 0, 0, 0})
    :ok
  catch
    # No table: the reporter is not running.
    :error, :badarg -> :ok
  end

  defp held do
    case :ets.lookup(@tab, :pairs) do
      [{_, n}] -> n
      [] -> 0
    end
  end

  @doc """
  At most `max` report rows, the most total time first, and how many were
  cut.
  """
  def rows(max) do
    all = for {{repo, table}, count, errors, us} <- :ets.tab2list(@tab), do: {repo, table, count, errors, us}

    {kept, cut} =
      all
      |> Enum.sort_by(fn {repo, table, count, _, us} -> {-us, -count, repo, table} end)
      |> Enum.split(max)

    rows =
      for {repo, table, count, errors, us} <- kept do
        %{
          "repo" => Streams.text(repo),
          "table" => table && Streams.text(table),
          "count" => count,
          "errors" => errors,
          "duration_us" => us
        }
      end

    {rows, length(cut)}
  end
end
