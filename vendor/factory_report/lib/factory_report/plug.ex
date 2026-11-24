defmodule FactoryReport.Plug do
  @moduledoc """
  Serves the report: `GET /report` (or `GET /` of wherever it is mounted)
  answers 200 `application/json`; anything else answers 404.

  The listener `FactoryReport` starts uses this plug. To serve the report
  from your own endpoint instead, start the reporter with `port: false` and
  forward to the plug from a scope the public proxy does not route:

      forward "/internal/factory-report", FactoryReport.Plug

  `/observer/...` is `FactoryReport.Observer` (see the README, "Observer"):
  reads with the report's token, actions (POST) with the actions token.
  With no report token, reads answer 403 unless the app set
  `observer: true` explicitly.

  ## Options

    * `:token` - overrides the token given to `FactoryReport`. When a token
      is in force the request must carry `authorization: Bearer <token>`,
      otherwise the answer is 401. `nil` or `""` here means no token.
    * `:observer` (`true` also serves reads without a token),
      `:inspect_state`, `:actions_token` - override the
      reporter's options of the same names (see `FactoryReport`).
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{method: "GET", path_info: path} = conn, opts) when path in [[], ["report"]] do
    if authorized?(conn, token(opts)) do
      case report() do
        {:ok, body} ->
          conn
          |> put_resp_header("content-type", "application/json")
          |> put_resp_header("cache-control", "no-store")
          |> send_resp(200, body)

        :error ->
          text(conn, 503, "factory_report is not running")
      end
    else
      conn
      |> put_resp_header("www-authenticate", "Bearer")
      |> text(401, "unauthorized")
    end
    |> halt()
  end

  def call(%Plug.Conn{path_info: ["observer" | path]} = conn, opts) do
    config = observer_config(opts)

    cond do
      not config.enabled ->
        ojson(conn, 404, %{"error" => "the observer is off (observer: false)"})

      conn.method == "POST" and FactoryReport.Observer.action?(path) ->
        action(conn, path, config)

      conn.method in ["GET", "HEAD"] ->
        cond do
          # with no token every read would be open to whoever reaches the
          # port (0.0.0.0 by default): only when the app says so
          token(opts) == nil and not config.open ->
            ojson(conn, 403, %{
              "error" =>
                "observer reads need a token: set the reporter's token (or FACTORY_REPORT_TOKEN), or observer: true to serve them without one"
            })

          authorized?(conn, token(opts)) ->
            {status, body} = FactoryReport.Observer.dispatch("GET", path, fetch_query(conn), inspect_state: config.inspect_state)
            json(conn, status, body)

          true ->
            conn |> put_resp_header("www-authenticate", "Bearer") |> ojson(401, %{"error" => "unauthorized"})
        end

      true ->
        {status, body} = FactoryReport.Observer.dispatch(conn.method, path, %{})
        json(conn, status, body)
    end
    |> halt()
  end

  def call(conn, _opts), do: conn |> text(404, "not found") |> halt()

  # Actions have their own token and no other: without one configured they
  # are off, whatever the read token says.
  defp action(conn, path, %{actions_token: nil}) do
    ojson(conn, 403, %{"error" => "actions are off: no actions_token configured", "path" => Enum.join(path, "/")})
  end

  defp action(conn, path, %{actions_token: token}) do
    if authorized?(conn, token) do
      case body_params(conn) do
        {:ok, params, conn} ->
          by = conn |> get_req_header("x-factory-by") |> List.first() |> by_text()
          {status, body} = FactoryReport.Observer.dispatch("POST", path, params, by: by)
          json(conn, status, body)

        {:error, status, message, conn} ->
          ojson(conn, status, %{"error" => message})
      end
    else
      conn |> put_resp_header("www-authenticate", "Bearer") |> ojson(401, %{"error" => "unauthorized: actions need authorization: Bearer <actions_token>"})
    end
  end

  @max_body 8_192

  # Already parsed (mounted behind Plug.Parsers) or read here: at most 8 kB
  # of JSON object, or nothing.
  defp body_params(%Plug.Conn{body_params: %Plug.Conn.Unfetched{}} = conn) do
    case read_body(conn, length: @max_body) do
      {:ok, "", conn} ->
        {:ok, %{}, conn}

      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, map} when is_map(map) -> {:ok, map, conn}
          _ -> {:error, 400, "the body must be a JSON object", conn}
        end

      {:more, _, conn} ->
        {:error, 413, "the body is over #{@max_body} bytes", conn}

      {:error, reason} ->
        {:error, 400, "could not read the body: #{inspect(reason)}", conn}
    end
  end

  defp body_params(%Plug.Conn{body_params: params} = conn) when is_map(params), do: {:ok, params, conn}

  defp by_text(nil), do: nil

  defp by_text(by) do
    by = by |> String.replace(~r/[^[:print:]]/u, "") |> String.slice(0, 80)
    if by == "", do: nil, else: by
  end

  defp fetch_query(conn), do: Plug.Conn.Query.decode(conn.query_string || "")

  defp observer_config(opts) do
    base =
      FactoryReport.meta(:observer) ||
        %{enabled: true, open: false, inspect_state: false, actions_token: env_token()}

    base
    |> override(opts, :observer, :enabled, &(&1 != false))
    |> override(opts, :observer, :open, &(&1 == true))
    |> override(opts, :inspect_state, :inspect_state, &(&1 == true))
    |> override(opts, :actions_token, :actions_token, fn
      t when is_binary(t) and t != "" -> t
      _ -> nil
    end)
  end

  defp env_token do
    case System.get_env("FACTORY_REPORT_ACTIONS_TOKEN") do
      t when is_binary(t) and t != "" -> t
      _ -> nil
    end
  end

  defp override(config, opts, opt, key, fun) do
    case Keyword.fetch(opts, opt) do
      {:ok, value} -> Map.put(config, key, fun.(value))
      :error -> config
    end
  end

  # An error the plug answers itself, shaped like every engine answer.
  defp ojson(conn, status, body),
    do: json(conn, status, Map.merge(%{"node" => Atom.to_string(node()), "took_ms" => 0.0}, body))

  defp json(conn, status, body) do
    conn
    |> put_resp_header("content-type", "application/json")
    |> put_resp_header("cache-control", "no-store")
    |> send_resp(status, Jason.encode_to_iodata!(body))
  end

  defp report do
    if FactoryReport.meta(:app) do
      {:ok, Jason.encode_to_iodata!(FactoryReport.report())}
    else
      :error
    end
  end

  defp token(opts) do
    case Keyword.fetch(opts, :token) do
      {:ok, token} when is_binary(token) and token != "" -> token
      {:ok, _} -> nil
      :error -> FactoryReport.meta(:token)
    end
  end

  defp authorized?(_conn, nil), do: true

  defp authorized?(conn, token) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> given] -> Plug.Crypto.secure_compare(given, token)
      _ -> false
    end
  end

  defp text(conn, status, body) do
    conn
    |> put_resp_header("content-type", "text/plain; charset=utf-8")
    |> send_resp(status, body)
  end
end
