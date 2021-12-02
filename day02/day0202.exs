defmodule Movement do
  def move({x, y, a}, ["forward", amount]), do: {x + amount, y + a * amount, a}
  def move({x, y, a}, ["up", amount]), do: {x, y, a - amount}
  def move({x, y, a}, ["down", amount]), do: {x, y, a + amount}
end

{x, y, _} =
  File.stream!("input1.txt")
  |> Stream.reject(&(&1 == "\n"))
  |> Stream.map(fn cmd ->
    [instruction, string_amount] = String.split(cmd)
    [instruction, String.to_integer(string_amount)]
  end)
  |> Enum.reduce({0, 0, 0}, &Movement.move(&2, &1))

IO.puts(x * y)
