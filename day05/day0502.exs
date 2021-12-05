defmodule LinesAndPoints do
  def line_points([{x, y1}, {x, y2}]) do
    Enum.map(y1..y2, fn y -> {x, y} end)
  end

  def line_points([{x1, y}, {x2, y}]) do
    Enum.map(x1..x2, fn x -> {x, y} end)
  end

  def line_points([{x1, y1}, {x2, y2}]) do
    Enum.zip(x1..x2, y1..y2)
  end
end

File.stream!("input.txt")
|> Stream.map(fn line ->
  String.trim(line)
  |> String.split(" -> ")
  |> Enum.map(fn pair ->
    String.split(pair, ",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
  end)
end)
|> Stream.flat_map(&LinesAndPoints.line_points/1)
|> Enum.frequencies()
|> Stream.reject(fn {_, freq} -> freq == 1 end)
|> Enum.count()
|> IO.inspect()
