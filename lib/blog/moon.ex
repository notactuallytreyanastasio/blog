defmodule Blog.Moon do
  @moduledoc """
  Lunar phase calculations based on Meeus, "Astronomical Algorithms" ch. 49.

  Computes the instants of new and full moons to within a couple of minutes,
  which is far more precision than needed to answer "was this show on a full
  moon?" at calendar-day resolution.
  """

  @synodic_month 29.530588853
  @deg :math.pi() / 180.0

  @type phase_info :: %{
          age: float(),
          illumination: float(),
          phase_name: String.t(),
          emoji: String.t(),
          full_moon?: boolean(),
          days_from_full: float()
        }

  @doc """
  UTC instants of every full moon whose date falls within `from_year..to_year`.
  """
  @spec full_moons(integer(), integer()) :: [DateTime.t()]
  def full_moons(from_year, to_year), do: phase_instants(from_year, to_year, 0.5)

  @doc """
  UTC instants of every new moon whose date falls within `from_year..to_year`.
  """
  @spec new_moons(integer(), integer()) :: [DateTime.t()]
  def new_moons(from_year, to_year), do: phase_instants(from_year, to_year, 0.0)

  @doc """
  MapSet of UTC calendar dates that contain a full moon instant.
  """
  @spec full_moon_dates(integer(), integer()) :: MapSet.t(Date.t())
  def full_moon_dates(from_year, to_year) do
    from_year
    |> full_moons(to_year)
    |> Enum.map(&DateTime.to_date/1)
    |> MapSet.new()
  end

  @doc """
  Phase details for a calendar date, given precomputed new/full moon instants
  covering the surrounding years. `age` is days since the last new moon,
  `illumination` is the lit fraction (0.0-1.0), and `days_from_full` is the
  signed distance in days to the nearest full moon (negative = before it).
  """
  @spec phase_info(Date.t(), [DateTime.t()], [DateTime.t()]) :: phase_info()
  def phase_info(date, new_moons, full_moons) do
    noon = date_noon_unix(date)

    last_new =
      new_moons
      |> Enum.take_while(fn dt -> DateTime.to_unix(dt) <= noon end)
      |> List.last()

    age =
      case last_new do
        nil -> 0.0
        dt -> (noon - DateTime.to_unix(dt)) / 86_400
      end

    nearest_full =
      Enum.min_by(full_moons, fn dt -> abs(DateTime.to_unix(dt) - noon) end, fn -> nil end)

    days_from_full =
      case nearest_full do
        nil -> 0.0
        dt -> (noon - DateTime.to_unix(dt)) / 86_400
      end

    full? = nearest_full != nil and DateTime.to_date(nearest_full) == date

    fraction = age / @synodic_month
    illumination = (1.0 - :math.cos(fraction * 2 * :math.pi())) / 2.0

    # "Full Moon" is reserved for dates containing the actual full moon
    # instant; near-full nights fall into the neighboring gibbous buckets.
    {name, emoji} =
      cond do
        full? -> {"Full Moon", "🌕"}
        fraction >= 0.467 and fraction < 0.5 -> {"Waxing Gibbous", "🌔"}
        fraction >= 0.5 and fraction < 0.533 -> {"Waning Gibbous", "🌖"}
        true -> phase_name(fraction)
      end

    %{
      age: age,
      illumination: illumination,
      phase_name: name,
      emoji: emoji,
      full_moon?: full?,
      days_from_full: days_from_full
    }
  end

  defp phase_name(fraction) do
    cond do
      fraction < 0.033 -> {"New Moon", "🌑"}
      fraction < 0.216 -> {"Waxing Crescent", "🌒"}
      fraction < 0.283 -> {"First Quarter", "🌓"}
      fraction < 0.467 -> {"Waxing Gibbous", "🌔"}
      fraction < 0.533 -> {"Full Moon", "🌕"}
      fraction < 0.717 -> {"Waning Gibbous", "🌖"}
      fraction < 0.784 -> {"Last Quarter", "🌗"}
      fraction < 0.967 -> {"Waning Crescent", "🌘"}
      true -> {"New Moon", "🌑"}
    end
  end

  defp date_noon_unix(date) do
    date |> DateTime.new!(~T[12:00:00], "Etc/UTC") |> DateTime.to_unix()
  end

  # phase_offset: 0.0 for new moon, 0.5 for full moon
  defp phase_instants(from_year, to_year, phase_offset) do
    k_first = Float.floor((from_year - 2000) * 12.3685) - 1
    k_last = Float.ceil((to_year + 1 - 2000) * 12.3685) + 1

    trunc(k_first)..trunc(k_last)
    |> Enum.map(fn k -> jde_to_datetime(phase_jde(k + phase_offset)) end)
    |> Enum.filter(fn dt -> dt.year >= from_year and dt.year <= to_year end)
  end

  # Meeus ch. 49: JDE of the mean phase for lunation index k, plus periodic
  # corrections. k integer = new moon, k + 0.5 = full moon.
  defp phase_jde(k) do
    t = k / 1236.85
    t2 = t * t
    t3 = t2 * t
    t4 = t3 * t

    mean =
      2_451_550.09766 + 29.530588861 * k + 0.00015437 * t2 - 0.000000150 * t3 +
        0.00000000073 * t4

    e = 1.0 - 0.002516 * t - 0.0000074 * t2

    # Sun's mean anomaly, Moon's mean anomaly, argument of latitude,
    # longitude of ascending node — all in degrees.
    m = 2.5534 + 29.10535670 * k - 0.0000014 * t2 - 0.00000011 * t3
    mp = 201.5643 + 385.81693528 * k + 0.0107582 * t2 + 0.00001238 * t3 - 0.000000058 * t4
    f = 160.7108 + 390.67050284 * k - 0.0016118 * t2 - 0.00000227 * t3 + 0.000000011 * t4
    om = 124.7746 - 1.56375588 * k + 0.0020672 * t2 + 0.00000215 * t3

    full? = k - Float.floor(k) > 0.25

    correction = phase_correction(full?, e, m, mp, f, om) + planetary_correction(k, t2)

    mean + correction
  end

  defp phase_correction(full?, e, m, mp, f, om) do
    {c1, c2, c3, c4, c5, c6, c7} =
      if full? do
        {-0.40614, 0.17302, 0.01614, 0.01043, 0.00734, -0.00515, 0.00209}
      else
        {-0.40720, 0.17241, 0.01608, 0.01039, 0.00739, -0.00514, 0.00208}
      end

    c1 * sin_d(mp) +
      c2 * e * sin_d(m) +
      c3 * sin_d(2 * mp) +
      c4 * sin_d(2 * f) +
      c5 * e * sin_d(mp - m) +
      c6 * e * sin_d(mp + m) +
      c7 * e * e * sin_d(2 * m) +
      -0.00111 * sin_d(mp - 2 * f) +
      -0.00057 * sin_d(mp + 2 * f) +
      0.00056 * e * sin_d(2 * mp + m) +
      -0.00042 * sin_d(3 * mp) +
      0.00042 * e * sin_d(m + 2 * f) +
      0.00038 * e * sin_d(m - 2 * f) +
      -0.00024 * e * sin_d(2 * mp - m) +
      -0.00017 * sin_d(om) +
      -0.00007 * sin_d(mp + 2 * m) +
      0.00004 * sin_d(2 * mp - 2 * f) +
      0.00004 * sin_d(3 * m) +
      0.00003 * sin_d(mp + m - 2 * f) +
      0.00003 * sin_d(2 * mp + 2 * f) +
      -0.00003 * sin_d(mp + m + 2 * f) +
      0.00003 * sin_d(mp - m + 2 * f) +
      -0.00002 * sin_d(mp - m - 2 * f) +
      -0.00002 * sin_d(3 * mp + m) +
      0.00002 * sin_d(4 * mp)
  end

  defp planetary_correction(k, t2) do
    [
      {0.000325, 299.77 + 0.107408 * k - 0.009173 * t2},
      {0.000165, 251.88 + 0.016321 * k},
      {0.000164, 251.83 + 26.651886 * k},
      {0.000126, 349.42 + 36.412478 * k},
      {0.000110, 84.66 + 18.206239 * k},
      {0.000062, 141.74 + 53.303771 * k},
      {0.000060, 207.14 + 2.453732 * k},
      {0.000056, 154.84 + 7.306860 * k},
      {0.000047, 34.52 + 27.261239 * k},
      {0.000042, 207.19 + 0.121824 * k},
      {0.000040, 291.34 + 1.844379 * k},
      {0.000037, 161.72 + 24.198154 * k},
      {0.000035, 239.56 + 25.513099 * k},
      {0.000023, 331.55 + 3.592518 * k}
    ]
    |> Enum.reduce(0.0, fn {coef, angle}, acc -> acc + coef * sin_d(angle) end)
  end

  defp sin_d(degrees), do: :math.sin(degrees * @deg)

  # JDE is in dynamical time; ΔT over 1983-2030 is ~1 minute, far below the
  # day-level resolution needed here, so it is ignored.
  defp jde_to_datetime(jde) do
    unix = round((jde - 2_440_587.5) * 86_400)
    DateTime.from_unix!(unix)
  end
end
