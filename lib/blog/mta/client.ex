defmodule Blog.Mta.Client do
  @base_url "https://bustime.mta.info/api/siri/vehicle-monitoring.json"
  @api_key "cddaeca7-eab9-428c-ab34-82f63d533dd2"

  # Manhattan bus routes
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
  }

  # Brooklyn bus routes
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

  # Combine all routes for backwards compatibility
  @all_routes Map.merge(@manhattan_routes, @brooklyn_routes)

  def fetch_buses(opts \\ []) do
    # By default, use all routes
    borough = Keyword.get(opts, :borough, :all)

    routes =
      case borough do
        :manhattan -> @manhattan_routes
        :brooklyn -> @brooklyn_routes
        :all -> @all_routes
      end

    results =
      Enum.map(routes, fn {route_name, line_ref} ->
        case fetch_route(line_ref) do
          {:ok, buses} ->
            require Logger
            Logger.info("Route #{route_name} (#{line_ref}) returned #{length(buses)} buses")
            {route_name, buses}

          {:error, error} ->
            require Logger
            Logger.error("Error fetching #{route_name}: #{inspect(error)}")
            {route_name, []}
        end
      end)

    {:ok, Map.new(results)}
  end

  # Helper function to get routes by borough
  def get_routes(:manhattan), do: @manhattan_routes
  def get_routes(:brooklyn), do: @brooklyn_routes
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

    require Logger
    Logger.info("Fetching route with params: #{inspect(params)}")

    case Req.get(@base_url, params: params) do
      {:ok, %{status: 200, body: body}} ->
        Logger.info("Response for #{line_ref}: #{inspect(body)}")
        {:ok, parse_response(body)}

      {:ok, %{status: status, body: body}} ->
        {:error, "API returned status #{status}: #{inspect(body)}"}

      {:error, error} ->
        {:error, "Request failed: #{inspect(error)}"}
    end
  end

  defp parse_response(%{"Siri" => siri}) do
    case siri do
      %{
        "ServiceDelivery" => %{
          "VehicleMonitoringDelivery" => [%{"VehicleActivity" => activities} | _]
        }
      } ->
        Enum.map(activities, fn activity ->
          journey = activity["MonitoredVehicleJourney"]

          %{
            id: journey["VehicleRef"],
            location: %{
              latitude: journey["VehicleLocation"]["Latitude"],
              longitude: journey["VehicleLocation"]["Longitude"]
            },
            direction: journey["DirectionRef"],
            destination: journey["DestinationName"],
            speed: journey["Speed"],
            recorded_at: activity["RecordedAtTime"]
          }
        end)

      _ ->
        require Logger
        Logger.warn("Unexpected SIRI response structure: #{inspect(siri)}")
        []
    end
  end

  defp parse_response(response) do
    require Logger
    Logger.warn("Unexpected response format: #{inspect(response)}")
    []
  end
end
