defmodule Blog.Mta.Client do
  @base_url "https://bustime.mta.info/api/siri/vehicle-monitoring.json"
  @api_key "cddaeca7-eab9-428c-ab34-82f63d533dd2"

  @routes %{
    "M14A" => "MTA NYCT_M14A+",
    "M14D" => "MTA NYCT_M14D+",
    "M21" => "MTA NYCT_M21" # ,
    # "M22" => "MTA NYCT_M22",
    # "M9" => "MTA NYCT_M9",
    # "M15" => "MTA NYCT_M15",
    # "M15-SBS" => "MTA NYCT_M15+",
    # "M103" => "MTA NYCT_M103"
  }

  def fetch_buses do
    results = Enum.map(@routes, fn {route_name, line_ref} ->
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
      %{"ServiceDelivery" => %{"VehicleMonitoringDelivery" => [%{"VehicleActivity" => activities} | _]}} ->
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
