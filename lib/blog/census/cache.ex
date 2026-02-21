defmodule Blog.Census.Cache do
  @moduledoc """
  Census tract population lookups backed by PostgreSQL.

  Maintains an ETS cache for hot-path lookups to avoid repeated DB queries.
  Data is loaded from the census_tracts table (populated by mix import_census).
  """
  use GenServer

  alias Blog.Census.Tract
  alias Blog.Repo

  import Ecto.Query

  @table :census_population_cache

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc "Get population for a census tract by geoid (e.g., \"061000100\")."
  @spec get_population(String.t()) :: non_neg_integer()
  def get_population(geoid) do
    case :ets.lookup(@table, geoid) do
      [{^geoid, pop}] -> pop
      [] -> load_from_db(geoid)
    end
  end

  @doc "Get populations for multiple tracts at once. Returns %{geoid => population}."
  @spec get_populations([String.t()]) :: %{String.t() => non_neg_integer()}
  def get_populations(geoids) do
    {cached, missing} =
      Enum.reduce(geoids, {%{}, []}, fn geoid, {found, miss} ->
        case :ets.lookup(@table, geoid) do
          [{^geoid, pop}] -> {Map.put(found, geoid, pop), miss}
          [] -> {found, [geoid | miss]}
        end
      end)

    db_results = fetch_missing(missing)
    Map.merge(cached, db_results)
  end

  defp fetch_missing([]), do: %{}

  defp fetch_missing(geoids) do
    results =
      Tract
      |> where([t], t.geoid in ^geoids)
      |> select([t], {t.geoid, t.population})
      |> Repo.all()
      |> Map.new()

    Enum.each(results, fn {geoid, pop} -> :ets.insert(@table, {geoid, pop}) end)
    results
  end

  @impl true
  def init(_opts) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    {:ok, %{}}
  end

  defp load_from_db(geoid) do
    case Repo.one(from(t in Tract, where: t.geoid == ^geoid, select: t.population)) do
      nil ->
        0

      pop ->
        :ets.insert(@table, {geoid, pop})
        pop
    end
  end
end
