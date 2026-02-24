defmodule Blog.CollageMaker.RateLimiter do
  @table :collage_maker_rate_limits
  @hourly_limit 5
  @daily_limit 20

  def check(ip_hash) do
    now = System.system_time(:second)
    cleanup_old_entries(ip_hash, now)

    entries = get_entries(ip_hash)
    hourly = Enum.count(entries, fn ts -> now - ts < 3600 end)
    daily = Enum.count(entries, fn ts -> now - ts < 86400 end)

    cond do
      hourly >= @hourly_limit -> {:error, "Rate limit reached. Try again in an hour."}
      daily >= @daily_limit -> {:error, "Daily limit reached. Try again tomorrow."}
      true -> :ok
    end
  end

  def record(ip_hash) do
    now = System.system_time(:second)
    entries = get_entries(ip_hash)
    :ets.insert(@table, {ip_hash, [now | entries]})
  end

  defp get_entries(ip_hash) do
    case :ets.lookup(@table, ip_hash) do
      [{_, entries}] -> entries
      [] -> []
    end
  end

  defp cleanup_old_entries(ip_hash, now) do
    entries = get_entries(ip_hash)
    cleaned = Enum.filter(entries, fn ts -> now - ts < 86400 end)

    if length(cleaned) != length(entries) do
      :ets.insert(@table, {ip_hash, cleaned})
    end
  end
end
