defmodule FactoryReport.Cluster do
  @moduledoc false
  # This node's view of the cluster it is in: its own name, the nodes it is
  # connected to and the traffic on each connection, and the :global names
  # it can see and where they live. Each node reports only what it sees;
  # the observer puts the views side by side, which is how a connection one
  # side lists and the other does not (a partial partition) shows up.
  #
  # Constant-time reads plus one :inet.getstat per connection. The cookie is
  # never read.

  @max_globals 50

  def section do
    %{
      "node" => to_string(node()),
      "distributed" => Node.alive?(),
      "connections" => connections(),
      "globals" => globals()
    }
  end

  # %{node => controlling port or pid} for every connected node, visible or
  # hidden. With the default TCP distribution the controller is a port and
  # :inet.getstat counts its bytes; a carrier that is a process (TLS, a
  # custom one) reports the connection without byte counts.
  defp connections do
    ctrl = Map.new(:erlang.system_info(:dist_ctrl))

    (Node.list(:visible) |> Enum.map(&{&1, "visible"})) ++ (Node.list(:hidden) |> Enum.map(&{&1, "hidden"}))
    |> Enum.map(fn {name, kind} ->
      Map.merge(%{"node" => to_string(name), "kind" => kind}, stats(Map.get(ctrl, name)))
    end)
    |> Enum.sort_by(& &1["node"])
  end

  defp stats(port) when is_port(port) do
    case :inet.getstat(port, [:recv_oct, :send_oct, :send_pend]) do
      {:ok, s} -> %{"in_bytes" => s[:recv_oct], "out_bytes" => s[:send_oct], "send_queue_bytes" => s[:send_pend]}
      _ -> %{}
    end
  end

  defp stats(_), do: %{}

  # Registered names are atoms or terms the app chose; inspect keeps any of
  # them printable. Only the first @max_globals, sorted, so the list is
  # stable from read to read.
  defp globals do
    :global.registered_names()
    |> Enum.map(fn name ->
      case :global.whereis_name(name) do
        pid when is_pid(pid) -> %{"name" => inspect(name), "node" => to_string(node(pid))}
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1["name"])
    |> Enum.take(@max_globals)
  end
end
