defmodule Movement do
  def move({x, y}, ["forward", amount]), do: {x + String.to_integer(amount), y}
  def move({x, y}, ["up", amount]), do: {x, y - String.to_integer(amount)}
  def move({x, y}, ["down", amount]), do: {x, y + String.to_integer(amount)}
  def move({x, y}, _), do: {x, y}
end

File.stream!("input1.txt")
|> Stream.map(&String.split/1)
|> Enum.reduce({0, 0}, &Movement.move(&2, &1))
|> Tuple.product()
|> IO.inspect()
