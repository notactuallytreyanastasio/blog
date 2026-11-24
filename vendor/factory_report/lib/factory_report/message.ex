defmodule FactoryReport.Message do
  @moduledoc false
  # A `:logger` message as text, for every shape `:logger` allows, without
  # ever raising. `limit` is a number of characters or `:infinity`; with a
  # number, the work is bounded too (a huge message is not flattened whole).

  alias FactoryReport.Streams

  def text(msg, meta, limit) do
    msg |> raw(meta, limit) |> finish(limit)
  catch
    _, _ -> "(unformattable log message)"
  end

  defp raw({:string, chardata}, _meta, limit), do: take(chardata, limit)

  defp raw({:report, report}, meta, limit) do
    case meta do
      %{report_cb: callback} when is_function(callback, 1) ->
        {format, args} = callback.(report)
        format(format, args, limit)

      %{report_cb: callback} when is_function(callback, 2) ->
        report
        |> callback.(%{depth: :unlimited, chars_limit: chars(limit), single_line: true})
        |> take(limit)

      _ ->
        report(report, limit)
    end
  catch
    # The app's own callback failed: show the report itself.
    _, _ -> report(report, limit)
  end

  defp raw({format, args}, _meta, limit) when is_list(args), do: format(format, args, limit)
  defp raw(other, _meta, _limit), do: inspect(other, limit: 20, printable_limit: 500)

  defp format(format, args, limit) do
    opts = if is_integer(limit), do: [chars_limit: limit], else: []
    format |> :io_lib.format(args, opts) |> take(limit)
  catch
    _, _ -> inspect({format, args}, limit: 20, printable_limit: 500)
  end

  # A report with no callback: key=value pairs, as Logger prints them.
  defp report(report, _limit) when is_map(report) or is_list(report) do
    report
    |> Enum.take(20)
    |> Enum.map_join(" ", fn {key, value} ->
      "#{key}=#{inspect(value, limit: 10, printable_limit: 200)}"
    end)
  catch
    _, _ -> inspect(report, limit: 20, printable_limit: 500)
  end

  defp report(report, _limit), do: inspect(report, limit: 20, printable_limit: 500)

  defp chars(limit) when is_integer(limit), do: limit
  defp chars(_), do: :unlimited

  defp take(chardata, :infinity) do
    IO.chardata_to_string(chardata)
  catch
    _, _ -> walk(chardata, <<>>, 1_000_000) |> elem(0)
  end

  # Four bytes per character is the most UTF-8 needs.
  defp take(chardata, limit), do: walk(chardata, <<>>, limit * 4) |> elem(0)

  defp walk(_, acc, left) when left <= 0, do: {acc, 0}

  defp walk(bin, acc, left) when is_binary(bin) do
    size = byte_size(bin)

    if size > left,
      do: {<<acc::binary, binary_part(bin, 0, left)::binary>>, 0},
      else: {<<acc::binary, bin::binary>>, left - size}
  end

  defp walk(char, acc, left) when is_integer(char) and char >= 0 and char <= 0x10FFFF do
    {<<acc::binary, char::utf8>>, left - 1}
  catch
    _, _ -> {<<acc::binary, "?">>, left - 1}
  end

  defp walk([head | tail], acc, left) do
    {acc, left} = walk(head, acc, left)
    walk(tail, acc, left)
  end

  defp walk(_, acc, left), do: {acc, left}

  defp finish(text, limit) when is_binary(text) do
    text = String.trim(text)
    if is_integer(limit), do: Streams.text(text, limit), else: Streams.text(text, byte_size(text))
  end

  defp finish(text, limit), do: text |> inspect(limit: 20) |> finish(limit)

  @doc "The module that logged, from the event's `mfa`, as text; or nil."
  def module(%{mfa: {module, _, _}}) when is_atom(module), do: inspect(module)
  def module(_), do: nil

  @doc "Microseconds since the epoch as ISO 8601 UTC."
  def iso(us, precision) when is_integer(us) do
    us |> DateTime.from_unix!(:microsecond) |> DateTime.truncate(precision) |> DateTime.to_iso8601()
  end
end
