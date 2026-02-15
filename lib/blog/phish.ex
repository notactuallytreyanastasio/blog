defmodule Blog.Phish do
  import Ecto.Query
  alias Blog.Repo
  alias Blog.Phish.Track

  def list_years do
    Track
    |> select([t], fragment("DISTINCT extract(year from ?)::integer", t.show_date))
    |> order_by([t], fragment("1"))
    |> Repo.all()
  end

  def song_list(year) do
    base = year_filter(Track, year)

    base
    |> group_by([t], t.song_name)
    |> select([t], %{
      song_name: t.song_name,
      times_played: count(t.id),
      jamchart_count: sum(fragment("CASE WHEN ? THEN 1 ELSE 0 END", t.is_jamchart)),
      jamchart_pct:
        fragment(
          "ROUND(100.0 * SUM(CASE WHEN ? THEN 1 ELSE 0 END) / COUNT(*)::numeric, 1)",
          t.is_jamchart
        )
    })
    |> order_by([t], [desc: sum(fragment("CASE WHEN ? THEN 1 ELSE 0 END", t.is_jamchart)), desc: count(t.id)])
    |> Repo.all()
    |> Enum.map(fn s ->
      %{s |
        jamchart_count: s.jamchart_count || 0,
        jamchart_pct: if(is_struct(s.jamchart_pct, Decimal), do: Decimal.to_float(s.jamchart_pct), else: s.jamchart_pct || 0.0)
      }
    end)
  end

  def song_history(song_name, year) do
    tracks =
      Track
      |> year_filter(year)
      |> where([t], t.song_name == ^song_name)
      |> order_by([t], t.show_date)
      |> Repo.all()
      |> Enum.map(fn t ->
        %{
          song_name: t.song_name,
          show_date: Date.to_iso8601(t.show_date),
          set_name: t.set_name,
          position: t.position,
          duration_ms: t.duration_ms,
          likes: t.likes,
          is_jamchart: if(t.is_jamchart, do: 1, else: 0),
          jam_notes: t.jam_notes || "",
          venue: t.venue,
          location: t.location,
          jam_url: t.jam_url || ""
        }
      end)

    %{song_name: song_name, tracks: tracks}
  end

  defp year_filter(query, "all"), do: query

  defp year_filter(query, year) when is_binary(year) do
    case Integer.parse(year) do
      {y, _} ->
        start_date = Date.new!(y, 1, 1)
        end_date = Date.new!(y, 12, 31)
        where(query, [t], t.show_date >= ^start_date and t.show_date <= ^end_date)

      :error ->
        query
    end
  end

  defp year_filter(query, _), do: query
end
