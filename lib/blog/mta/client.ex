defmodule Blog.Mta.Client do
  @moduledoc """
  Client for the MTA Bus Time API.
  """

  alias Blog.Mta.Routes

  require Logger

  @base_url "https://bustime.mta.info/api/siri/vehicle-monitoring.json"
  @api_key "cddaeca7-eab9-428c-ab34-82f63d533dd2"

  @doc """
  Fetch buses for all routes.

  Options:
    - `:borough` - Fetch buses for a specific borough (`:manhattan`, `:brooklyn`, `:queens`, or `:all`)
  """
  def fetch_buses(opts \\ []) do
    borough = Keyword.get(opts, :borough, :all)
    routes = Routes.for_borough(borough)

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

  @doc "Get routes for a specific borough. Delegates to `Blog.Mta.Routes.for_borough/1`."
  defdelegate get_routes(borough), to: Routes, as: :for_borough

  @spec fetch_route(String.t()) :: {:error, String.t()} | {:ok, list()}
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
      %{
        "ServiceDelivery" => %{
          "VehicleMonitoringDelivery" => [%{"VehicleActivity" => vehicles} | _]
        }
      } ->
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

        %{
          id: vehicle_ref,
          location: %{
            latitude: lat,
            longitude: lng
          },
          direction: Map.get(journey, "DirectionRef", ""),
          destination: destination,
          speed: Map.get(journey, "Velocity", 0),
          recorded_at: recorded_at
        }

      _ ->
        nil
    end
  end

  defp parse_vehicle(_), do: nil
end
