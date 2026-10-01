alias Temper.Bank.{Account, Pinger, Box, Ledger}
Temper.Bank.__temper_init__()
a = Account.new("ann")
b = Account.new("bob")
IO.inspect(a, label: "an actor")

# 1,000 processes deposit into one shared account at once
1..1000 |> Enum.map(fn _ -> Task.async(fn -> Account.deposit(a, 1) end) end) |> Task.await_many()
IO.puts("after 1000 concurrent deposits: #{Account.get_balance(a)}")
ledger = TemperCore.Global.get(:"Temper.Bank.ledger")
IO.puts("the shared ledger saw: #{Ledger.get_entries(ledger)}")

Account.transferTo(a, b, 300)
IO.puts("after transfer: ann #{Account.get_balance(a)}, bob #{Account.get_balance(b)}")

r = try do Account.withdraw(b, 5000) rescue e in TemperCore.Bubble -> "bubbled back to the caller (#{inspect(e.__struct__)})" end
IO.puts("withdraw too much: #{r}")

p = Pinger.new()
r = try do Account.pingBack(a, p) rescue e in TemperCore.Panic -> "Panic: " <> Exception.message(e) end
IO.puts("cycle: #{r}")

r = try do Account.stash(a, Box.new()) rescue e in TemperCore.Panic -> "Panic: " <> Exception.message(e) end
IO.puts("mutable argument: #{r}")

parent = self()
spawn(fn -> c = Account.new("short-lived"); send(parent, {:made, c}) end)
c = receive do {:made, c} -> c end
Process.sleep(50)
r = try do Account.deposit(c, 1) rescue e in TemperCore.Panic -> "Panic: " <> Exception.message(e) end
IO.puts("actor whose creator ended: #{r}")

# supervised: outlives the process that made it
spawn(fn -> send(parent, {:made, TemperCore.Actor.supervised(fn -> Account.new("kept") end)}) end)
kept = receive do {:made, k} -> k end
Process.sleep(50)
IO.puts("supervised actor whose creator ended: #{Account.deposit(kept, 5)}")
IO.puts("the ledger, seen from another process: #{Task.async(fn -> Ledger.get_entries(TemperCore.Global.get(:"Temper.Bank.ledger")) end) |> Task.await()}")
