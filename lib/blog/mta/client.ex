defmodule Blog.Mta.Client do
  @moduledoc """
  Client for the MTA Bus Time API.
  """
  require Logger

  @base_url "https://bustime.mta.info/api/siri/vehicle-monitoring.json"
  @api_key "cddaeca7-eab9-428c-ab34-82f63d533dd2"

  @manhattan_routes %{
    # Crosstown Routes
    "M14A-SBS" => "MTA NYCT_M14A+",
    "M14D-SBS" => "MTA NYCT_M14D+",
    "M21" => "MTA NYCT_M21",
    "M22" => "MTA NYCT_M22",
    "M23-SBS" => "MTA NYCT_M23+",
    "M34-SBS" => "MTA NYCT_M34+",
    "M34A-SBS" => "MTA NYCT_M34A+",
    "M42" => "MTA NYCT_M42",
    "M50" => "MTA NYCT_M50",
    "M66" => "MTA NYCT_M66",
    "M72" => "MTA NYCT_M72",
    "M79-SBS" => "MTA NYCT_M79+",
    "M86-SBS" => "MTA NYCT_M86+",
    "M96" => "MTA NYCT_M96",
    "M106" => "MTA NYCT_M106",
    "M116" => "MTA NYCT_M116",
    # North-South Routes
    "M1" => "MTA NYCT_M1",
    "M2" => "MTA NYCT_M2",
    "M3" => "MTA NYCT_M3",
    "M4" => "MTA NYCT_M4",
    "M5" => "MTA NYCT_M5",
    "M7" => "MTA NYCT_M7",
    "M8" => "MTA NYCT_M8",
    "M9" => "MTA NYCT_M9",
    "M10" => "MTA NYCT_M10",
    "M11" => "MTA NYCT_M11",
    "M12" => "MTA NYCT_M12",
    "M15" => "MTA NYCT_M15",
    "M15-SBS" => "MTA NYCT_M15+",
    "M20" => "MTA NYCT_M20",
    "M31" => "MTA NYCT_M31",
    "M35" => "MTA NYCT_M35",
    "M55" => "MTA NYCT_M55",
    "M57" => "MTA NYCT_M57",
    "M60-SBS" => "MTA NYCT_M60+",
    "M98" => "MTA NYCT_M98",
    "M100" => "MTA NYCT_M100",
    "M101" => "MTA NYCT_M101",
    "M102" => "MTA NYCT_M102",
    "M103" => "MTA NYCT_M103",
    "M104" => "MTA NYCT_M104",
    # Limited & Express Routes
    "M15-LTD" => "MTA NYCT_M15L",
    "M101-LTD" => "MTA NYCT_M101L",
    "M102-LTD" => "MTA NYCT_M102L",
    "M103-LTD" => "MTA NYCT_M103L",
    "M1-LTD" => "MTA NYCT_M1L",
    "M2-LTD" => "MTA NYCT_M2L",
    "M3-LTD" => "MTA NYCT_M3L",
    "M4-LTD" => "MTA NYCT_M4L",
    "M5-LTD" => "MTA NYCT_M5L"
  }

  @brooklyn_routes %{
    # Local routes
    "B1" => "MTA NYCT_B1",
    "B2" => "MTA NYCT_B2",
    "B3" => "MTA NYCT_B3",
    "B4" => "MTA NYCT_B4",
    "B6" => "MTA NYCT_B6",
    "B7" => "MTA NYCT_B7",
    "B8" => "MTA NYCT_B8",
    "B9" => "MTA NYCT_B9",
    "B11" => "MTA NYCT_B11",
    "B12" => "MTA NYCT_B12",
    "B13" => "MTA NYCT_B13",
    "B14" => "MTA NYCT_B14",
    "B15" => "MTA NYCT_B15",
    "B16" => "MTA NYCT_B16",
    "B17" => "MTA NYCT_B17",
    "B24" => "MTA NYCT_B24",
    "B25" => "MTA NYCT_B25",
    "B26" => "MTA NYCT_B26",
    "B31" => "MTA NYCT_B31",
    "B32" => "MTA NYCT_B32",
    "B35" => "MTA NYCT_B35",
    "B36" => "MTA NYCT_B36",
    "B37" => "MTA NYCT_B37",
    "B38" => "MTA NYCT_B38",
    "B39" => "MTA NYCT_B39",
    "B41" => "MTA NYCT_B41",
    "B43" => "MTA NYCT_B43",
    "B44" => "MTA NYCT_B44",
    "B45" => "MTA NYCT_B45",
    "B46" => "MTA NYCT_B46",
    "B47" => "MTA NYCT_B47",
    "B48" => "MTA NYCT_B48",
    "B49" => "MTA NYCT_B49",
    "B52" => "MTA NYCT_B52",
    "B54" => "MTA NYCT_B54",
    "B57" => "MTA NYCT_B57",
    "B60" => "MTA NYCT_B60",
    "B61" => "MTA NYCT_B61",
    "B62" => "MTA NYCT_B62",
    "B63" => "MTA NYCT_B63",
    "B64" => "MTA NYCT_B64",
    "B65" => "MTA NYCT_B65",
    "B67" => "MTA NYCT_B67",
    "B68" => "MTA NYCT_B68",
    "B69" => "MTA NYCT_B69",
    "B70" => "MTA NYCT_B70",
    "B74" => "MTA NYCT_B74",
    "B82" => "MTA NYCT_B82",
    "B83" => "MTA NYCT_B83",
    "B84" => "MTA NYCT_B84",
    "B100" => "MTA NYCT_B100",
    "B103" => "MTA NYCT_B103",
    # Select Bus Service (SBS)
    "B44-SBS" => "MTA NYCT_B44+",
    "B46-SBS" => "MTA NYCT_B46+",
    "B82-SBS" => "MTA NYCT_B82+"
  }

  @queens_routes %{
    # Local routes
    "Q1" => "MTA NYCT_Q1",
    "Q2" => "MTA NYCT_Q2",
    "Q3" => "MTA NYCT_Q3",
    "Q4" => "MTA NYCT_Q4",
    "Q5" => "MTA NYCT_Q5",
    "Q6" => "MTA NYCT_Q6",
    "Q7" => "MTA NYCT_Q7",
    "Q8" => "MTA NYCT_Q8",
    "Q9" => "MTA NYCT_Q9",
    "Q10" => "MTA NYCT_Q10",
    "Q11" => "MTA NYCT_Q11",
    "Q12" => "MTA NYCT_Q12",
    "Q13" => "MTA NYCT_Q13",
    "Q15" => "MTA NYCT_Q15",
    "Q15A" => "MTA NYCT_Q15A",
    "Q16" => "MTA NYCT_Q16",
    "Q17" => "MTA NYCT_Q17",
    "Q18" => "MTA NYCT_Q18",
    "Q19" => "MTA NYCT_Q19",
    "Q20A" => "MTA NYCT_Q20A",
    "Q20B" => "MTA NYCT_Q20B",
    "Q21" => "MTA NYCT_Q21",
    "Q22" => "MTA NYCT_Q22",
    "Q23" => "MTA NYCT_Q23",
    "Q24" => "MTA NYCT_Q24",
    "Q25" => "MTA NYCT_Q25",
    "Q26" => "MTA NYCT_Q26",
    "Q27" => "MTA NYCT_Q27",
    "Q28" => "MTA NYCT_Q28",
    "Q29" => "MTA NYCT_Q29",
    "Q30" => "MTA NYCT_Q30",
    "Q31" => "MTA NYCT_Q31",
    "Q32" => "MTA NYCT_Q32",
    "Q33" => "MTA NYCT_Q33",
    "Q34" => "MTA NYCT_Q34",
    "Q35" => "MTA NYCT_Q35",
    "Q36" => "MTA NYCT_Q36",
    "Q37" => "MTA NYCT_Q37",
    "Q38" => "MTA NYCT_Q38",
    "Q39" => "MTA NYCT_Q39",
    "Q40" => "MTA NYCT_Q40",
    "Q41" => "MTA NYCT_Q41",
    "Q42" => "MTA NYCT_Q42",
    "Q43" => "MTA NYCT_Q43",
    "Q44" => "MTA NYCT_Q44",
    "Q46" => "MTA NYCT_Q46",
    "Q47" => "MTA NYCT_Q47",
    "Q48" => "MTA NYCT_Q48",
    "Q49" => "MTA NYCT_Q49",
    "Q50" => "MTA NYCT_Q50",
    "Q52" => "MTA NYCT_Q52",
    "Q53" => "MTA NYCT_Q53",
    "Q54" => "MTA NYCT_Q54",
    "Q55" => "MTA NYCT_Q55",
    "Q56" => "MTA NYCT_Q56",
    "Q58" => "MTA NYCT_Q58",
    "Q59" => "MTA NYCT_Q59",
    "Q60" => "MTA NYCT_Q60",
    "Q64" => "MTA NYCT_Q64",
    "Q65" => "MTA NYCT_Q65",
    "Q66" => "MTA NYCT_Q66",
    "Q67" => "MTA NYCT_Q67",
    "Q69" => "MTA NYCT_Q69",
    "Q70" => "MTA NYCT_Q70",
    "Q72" => "MTA NYCT_Q72",
    "Q76" => "MTA NYCT_Q76",
    "Q77" => "MTA NYCT_Q77",
    "Q83" => "MTA NYCT_Q83",
    "Q84" => "MTA NYCT_Q84",
    "Q85" => "MTA NYCT_Q85",
    "Q88" => "MTA NYCT_Q88",
    "Q100" => "MTA NYCT_Q100",
    "Q101" => "MTA NYCT_Q101",
    "Q102" => "MTA NYCT_Q102",
    "Q103" => "MTA NYCT_Q103",
    "Q104" => "MTA NYCT_Q104",
    "Q110" => "MTA NYCT_Q110",
    "Q111" => "MTA NYCT_Q111",
    "Q112" => "MTA NYCT_Q112",
    "Q113" => "MTA NYCT_Q113",
    # Select Bus Service (SBS)
    "Q44-SBS" => "MTA NYCT_Q44+",
    "Q52-SBS" => "MTA NYCT_Q52+",
    "Q53-SBS" => "MTA NYCT_Q53+",
    "Q70-SBS" => "MTA NYCT_Q70+"
  }

  # Combine all routes for backwards compatibility
  @all_routes Map.merge(Map.merge(@manhattan_routes, @brooklyn_routes), @queens_routes)

  @doc """
  Fetch buses for all routes.
  Options:
  - :borough - Fetch buses for a specific borough (:manhattan, :brooklyn, :queens, or :all)
  """
  def fetch_buses(opts \\ []) do
    # By default, use all routes
    borough = Keyword.get(opts, :borough, :all)
    routes = get_routes(borough)

    results =
      Enum.map(routes, fn {route_name, line_ref} ->
        case fetch_route(line_ref) do
          {:ok, buses} ->
            Logger.info("Received #{length(buses)} buses for #{route_name}")
            %{route: route_name, buses: buses}

          {:error, _} ->
            %{route: route_name, buses: []}
        end
      end)

    {:ok, results}
  end

  @doc """
  Get routes for a specific borough
  """
  def get_routes(:manhattan), do: @manhattan_routes
  def get_routes(:brooklyn), do: @brooklyn_routes
  def get_routes(:queens), do: @queens_routes
  def get_routes(:all), do: @all_routes
  def get_routes(_), do: @all_routes

  @spec fetch_route(any()) :: {:error, <<_::64, _::_*8>>} | {:ok, list()}
  def fetch_route(line_ref) do
    params = %{
      key: @api_key,
      version: 2,
      LineRef: line_ref,
      OperatorRef: "MTA NYCT",
      VehicleMonitoringDetailLevel: "normal"
    }

    Logger.info("Fetching route with params: #{inspect(params)}")

    case Req.get(@base_url, params: params) do
      {:ok, %{status: 200, body: body}} ->
        Logger.info("Response for #{line_ref}: #{inspect(body)}")
        {:ok, parse_response(body)}

      {:ok, %{status: status, body: body}} ->
        Logger.error("Error fetching route: #{status}, #{inspect(body)}")
        {:error, "API returned status #{status}: #{inspect(body)}"}

      {:error, error} ->
        Logger.error("Error fetching route: #{inspect(error)}")
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp parse_response(%{"Siri" => siri}) do
    case siri do
      %{"ServiceDelivery" => %{"VehicleMonitoringDelivery" => [%{"VehicleActivity" => vehicles} | _]}} ->
        parse_vehicles(vehicles)

      _ ->
        []
    end
  end

  defp parse_response(_), do: []

  defp parse_vehicles(vehicles) when is_list(vehicles) do
    vehicles
    |> Enum.map(&parse_vehicle/1)
    |> Enum.filter(& &1)
  end

  defp parse_vehicles(_), do: []

  defp parse_vehicle(%{"MonitoredVehicleJourney" => journey, "RecordedAtTime" => recorded_at}) do
    case journey do
      %{
        "VehicleLocation" => %{"Latitude" => lat, "Longitude" => lng},
        "VehicleRef" => vehicle_ref
      } ->
        destination =
          journey
          |> Map.get("DestinationName", ["Unknown"])
          |> List.first()

        # Format the bus data to match what the JavaScript expects
        %{
          id: vehicle_ref,
          location: %{
            latitude: lat,
            longitude: lng
          },
          direction: Map.get(journey, "DirectionRef", ""),
          destination: destination,
          speed: Map.get(journey, "Velocity", 0), # Changed from Speed to Velocity
          recorded_at: recorded_at
        }

      _ ->
        nil
    end
  end

  defp parse_vehicle(_), do: nil
end
