# What heap collection relies on: a closure's captured values are readable
# through :erlang.fun_info(f, :env), and a process's dictionary is freed when
# it exits. Run: elixir probes/09_closures_and_process_memory.exs
cell = %{id: make_ref()}
x = 41
f = fn y -> {cell, x + y} end
IO.inspect(:erlang.fun_info(f, :env), label: "local fn env")
IO.inspect(:erlang.fun_info(&Enum.map/2, :env), label: "external capture env")
g = fn -> f end
IO.inspect(:erlang.fun_info(g, :env), label: "fn holding fn")
# does a process's dictionary memory go away with it?
parent = self()
pid = spawn(fn ->
  for i <- 1..200_000, do: Process.put({:obj, i}, %{v: i, s: "field #{i}"})
  send(parent, {:mem, :erlang.process_info(self(), :memory)})
  receive do :stop -> :ok end
end)
receive do {:mem, m} -> IO.inspect(m, label: "child memory with 200k objects") end
before = :erlang.memory(:processes)
send(pid, :stop); Process.sleep(200)
IO.inspect({before, :erlang.memory(:processes), Process.alive?(pid)}, label: "processes memory before/after exit, alive?")
