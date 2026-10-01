# which float spellings does the parser take? Kotlin's Double.toString gives "1.0E10"
for src <- ["1.0E10", "1.0e10", "1e10", "1.5E-7", "1.", ".5", "1_000", "-0.0", "9007199254740993"] do
  r = try do
    {v, _} = Code.eval_string(src); {:ok, v}
  rescue e -> {:error, e.__struct__}
  end
  IO.inspect(r, label: src)
end
# NaN and infinity: can a float even hold them?
r = try do {:ok, 1.0 / 0.0} rescue e -> {:error, e.__struct__} end
IO.inspect(r, label: "1.0 / 0.0")
r = try do {:ok, :math.pow(10.0, 400)} rescue e -> {:error, e.__struct__} end
IO.inspect(r, label: "10.0 ** 400")
r = try do {:ok, 1.0e308 * 10} rescue e -> {:error, e.__struct__} end
IO.inspect(r, label: "1.0e308 * 10")
IO.inspect(0.0 == -0.0, label: "0.0 == -0.0")
IO.inspect(0.0 === -0.0, label: "0.0 === -0.0")
IO.inspect(1 == 1.0, label: "1 == 1.0")
IO.inspect(1 === 1.0, label: "1 === 1.0")
