# What the BEAM does with IEEE special cases. Run: elixir probes/08_float_specials.exs
big = 1.7976931348623157e308
for {name, f} <- [
  {"big*2", fn -> big * 2.0 end},
  {"1/0", fn -> 1.0 / 0.0 end},
  {"sqrt -1", fn -> :math.sqrt(-1.0) end},
  {"log 0", fn -> :math.log(0.0) end},
  {"exp 1000", fn -> :math.exp(1000.0) end},
  {"<<inf>>", fn -> <<x::float>> = <<0x7FF0000000000000::64>>; x end},
  {"<<nan>>", fn -> <<x::float>> = <<0x7FF8000000000000::64>>; x end},
  {"String.to 1e999", fn -> String.to_float("1.0e999") end},
  {"fmod", fn -> :math.fmod(-2.25, 2.0) end},
] do
  r = try do inspect(f.()) rescue e -> "raises " <> inspect(e.__struct__) catch k, v -> "#{k} #{inspect v}" end
  IO.puts("#{name}: #{r}")
end
IO.puts(System.version() <> " / OTP " <> System.otp_release())
