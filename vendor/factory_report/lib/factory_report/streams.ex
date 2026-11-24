defmodule FactoryReport.Streams do
  @moduledoc false
  # Cumulative count / errors / duration_us per stream, in one public ETS
  # table written from whichever process the event happened in.
  #
  # Rows: {{kind, name}, count, errors, duration_us}                the total
  #       {{kind, name, by_kind, by_name}, count, errors, us}       a breakdown
  #       {{:names, kind}, n}   how many rows the kind holds (the cap)

  alias FactoryReport.Attribution

  @tab :factory_report_streams
  @max_name 120
  @other "(other)"

  def create do
    :ets.new(@tab, [
      :named_table,
      :public,
      :set,
      write_concurrency: true,
      read_concurrency: true
    ])
  end

  @doc """
  One occurrence. `native` is a duration in native time units. O(1): one
  `:ets.update_counter/3` on the usual path. A name seen for the first time
  takes the slow path once: it is admitted while its kind has room, else the
  occurrence goes to the kind's `"(other)"` row.

  `new_on_error: false` is for names a client can choose (LiveView and
  channel event names): a failing occurrence never admits a new name, so a
  stream of made-up event names cannot fill the table.
  """
  def hit(kind, name, native, error?, new_on_error \\ true) do
    total(kind, cut(name), ops(native, error?), error? and not new_on_error)
  end

  @doc """
  One occurrence, attributed: the total row as `hit/4`, and a breakdown row
  for the page (`{by_kind, by_name}`) whose process caused it, when there is
  one. One more `:ets.update_counter/3`.
  """
  def hit_by(kind, name, native, error?, by \\ Attribution.current()) do
    name = cut(name)
    ops = ops(native, error?)
    total(kind, name, ops, false)

    case by do
      {by_kind, by_name} -> breakdown(kind, {kind, name, by_kind, by_name}, ops)
      _ -> :ok
    end
  end

  defp ops(native, error?), do: [{2, 1}, {3, if(error?, do: 1, else: 0)}, {4, to_us(native)}]

  defp total(kind, name, ops, refuse?) do
    :ets.update_counter(@tab, {kind, name}, ops)
    :ok
  catch
    :error, :badarg -> first(kind, {kind, name}, ops, refuse?)
  end

  defp first(kind, key, ops, refuse?) do
    cap = FactoryReport.meta(:max_stream_names) || 0

    cond do
      refuse? or elem(key, 1) == @other ->
        other(kind, ops)

      admit(kind, key, cap) ->
        :ets.update_counter(@tab, key, ops, {key, 0, 0, 0})
        :ok

      true ->
        other(kind, ops)
    end
  catch
    # No table: the reporter is not running. Nothing to count into.
    :error, :badarg -> :ok
  end

  # A breakdown row that finds no room is simply not kept: the occurrence is
  # in the total already. Breakdowns may take three quarters of a kind's
  # room, never the last quarter, so they cannot push a total into "(other)".
  defp breakdown(kind, key, ops) do
    :ets.update_counter(@tab, key, ops)
    :ok
  catch
    :error, :badarg ->
      try do
        cap = FactoryReport.meta(:max_stream_names) || 0

        if admit(kind, key, div(cap * 3, 4)) do
          :ets.update_counter(@tab, key, ops, {key, 0, 0, 0})
        end

        :ok
      catch
        :error, :badarg -> :ok
      end
  end

  defp admit(kind, key, limit) do
    names = {:names, kind}

    if held(names) < limit do
      # Two processes meeting the same new name both land here; only the
      # one whose insert wins takes a slot.
      if :ets.insert_new(@tab, {key, 0, 0, 0}) do
        :ets.update_counter(@tab, names, {2, 1}, {names, 0})
      end

      true
    else
      false
    end
  end

  defp held(names) do
    case :ets.lookup(@tab, names) do
      [{_, n}] -> n
      [] -> 0
    end
  end

  defp other(kind, ops) do
    key = {kind, @other}
    :ets.update_counter(@tab, key, ops, {key, 0, 0, 0})
    :ok
  end

  @doc false
  def to_us(native) when is_integer(native) and native > 0,
    do: System.convert_time_unit(native, :native, :microsecond)

  def to_us(_), do: 0

  @doc "A name no longer than #{@max_name} bytes, in O(1)."
  def cut(name) when is_binary(name) and byte_size(name) > @max_name,
    do: binary_part(name, 0, @max_name)

  def cut(name) when is_binary(name), do: name
  def cut(name), do: name |> inspect() |> cut()

  @doc """
  At most `max` report rows and how many were cut. Totals come first (the
  busiest by count), then breakdown rows (the busiest by count), so a cut
  takes breakdowns before it takes any total.
  """
  def rows(max) do
    all =
      Enum.flat_map(:ets.tab2list(@tab), fn
        {{kind, name}, count, errors, us} when is_binary(kind) ->
          [{0, count, kind, name, nil, errors, us}]

        {{kind, name, by_kind, by_name}, count, errors, us} ->
          [{1, count, kind, name, {by_kind, by_name}, errors, us}]

        _ ->
          []
      end)

    sorted =
      Enum.sort(all, fn {r1, c1, k1, n1, b1, _, _}, {r2, c2, k2, n2, b2, _, _} ->
        {r1, -c1, k1, n1, b1} <= {r2, -c2, k2, n2, b2}
      end)

    {kept, cut} = Enum.split(sorted, max)

    rows =
      for {_, count, kind, name, by, errors, us} <- kept do
        row = %{
          "kind" => kind,
          "name" => text(name),
          "count" => count,
          "errors" => errors,
          "duration_us" => us
        }

        if by, do: Map.put(row, "by", by_map(by)), else: row
      end

    {rows, length(cut)}
  end

  @doc "A `by` as it goes on the wire, or nil."
  def by_map({kind, name}), do: %{"kind" => text(kind), "name" => text(name)}
  def by_map(_), do: nil

  @doc """
  Valid UTF-8 of at most `max` characters: what goes on the wire. A name was
  cut by bytes when it was counted, so it may end inside a character, and a
  client-chosen name may not be text at all.
  """
  def text(name, max \\ @max_name)

  def text(name, max) when is_binary(name) do
    name = if String.valid?(name), do: name, else: scrub(name, <<>>)
    if byte_size(name) > max, do: String.slice(name, 0, max), else: name
  end

  def text(name, max), do: name |> inspect() |> text(max)

  defp scrub(<<c::utf8, rest::binary>>, acc), do: scrub(rest, <<acc::binary, c::utf8>>)
  defp scrub(<<_, rest::binary>>, acc), do: scrub(rest, <<acc::binary, "?">>)
  defp scrub(<<>>, acc), do: acc
end
