defmodule BlogWeb.Plugs.RemoteIp do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    remote_ip = get_remote_ip(conn)
    put_session(conn, :remote_ip, remote_ip)
  end

  defp get_remote_ip(conn) do
    forwarded_for = get_req_header(conn, "x-forwarded-for")
    
    case forwarded_for do
      [h | _] ->
        h
        |> String.split(",")
        |> List.first()
        |> String.trim()
      [] ->
        case conn.remote_ip do
          {a, b, c, d} -> "#{a}.#{b}.#{c}.#{d}"
          {a, b, c, d, e, f, g, h} -> 
            "#{Integer.to_string(a, 16)}:#{Integer.to_string(b, 16)}:#{Integer.to_string(c, 16)}:#{Integer.to_string(d, 16)}:#{Integer.to_string(e, 16)}:#{Integer.to_string(f, 16)}:#{Integer.to_string(g, 16)}:#{Integer.to_string(h, 16)}"
          _ -> "unknown"
        end
    end
  end
end