defmodule Caves do
  def basins(heightmap) do
    low_points = low_points(heightmap)

    Enum.map(low_points, fn {row, col} ->
      path_basin(heightmap, {row, col}, [])
      |> Enum.uniq()
      |> Enum.count()
    end)
  end

  defp path_basin(heightmap, {row, col}, visited) do
    value = heightmap[row][col]

    {points, values} = adjacents(heightmap, row, col)

    rest_of_the_basin =
      Enum.zip(points, values)
      |> Enum.filter(fn {coords, adj_value} ->
        not Enum.member?(visited, coords) and adj_value > value and adj_value < 9
      end)
      |> Enum.flat_map(fn {{adj_row, adj_col}, _} ->
        path_basin(heightmap, {adj_row, adj_col}, [{row, col} | visited])
      end)

    [{row, col} | rest_of_the_basin]
  end

  def low_points(heightmap) do
    {_rows, cols} = Matrex.size(heightmap)

    {low_points, _} =
      Enum.reduce(heightmap, {[], 0}, fn cur, {acc, pos} ->
        # matrex matrices are one-based
        cur_row = div(pos, cols) + 1
        cur_col = rem(pos, cols) + 1

        {_, adjacent_values} = adjacents(heightmap, cur_row, cur_col)

        if not Enum.member?(adjacent_values, cur) and Enum.min([cur | adjacent_values]) == cur do
          {[{cur_row, cur_col} | acc], pos + 1}
        else
          {acc, pos + 1}
        end
      end)

    low_points
  end

  defp adjacents(heightmap, cur_row, cur_col) do
    {rows, cols} = Matrex.size(heightmap)

    adjacent_points = []

    adjacent_points =
      unless cur_row == 1,
        do: [{cur_row - 1, cur_col} | adjacent_points],
        else: adjacent_points

    adjacent_points =
      unless cur_row == rows,
        do: [{cur_row + 1, cur_col} | adjacent_points],
        else: adjacent_points

    adjacent_points =
      unless cur_col == 1,
        do: [{cur_row, cur_col - 1} | adjacent_points],
        else: adjacent_points

    adjacent_points =
      unless cur_col == cols,
        do: [{cur_row, cur_col + 1} | adjacent_points],
        else: adjacent_points

    adjacent_values = Enum.map(adjacent_points, fn {row, col} -> heightmap[row][col] end)

    {adjacent_points, adjacent_values}
  end
end

heightmap =
  File.stream!("input.txt")
  |> Enum.map(fn line ->
    String.trim(line) |> String.graphemes() |> Enum.map(&String.to_integer/1)
  end)
  |> Matrex.new()

Caves.basins(heightmap)
|> Enum.sort()
|> Enum.take(-3)
|> Enum.product()
|> IO.inspect()
