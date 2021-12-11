defmodule Octopi do
  def steps(octopi, num_steps) do
    Enum.reduce(1..num_steps, {octopi, 0}, fn _, {octopi, flashes} ->
      {updated_octopi, new_flashes} = step(octopi)
      {updated_octopi, flashes + new_flashes}
    end)
  end

  defp step(octopi) do
    octopi_to_flash = Matrex.add(octopi, 1)
    {_rows, cols} = Matrex.size(octopi)

    {flash_points, _} =
      Enum.reduce(octopi, {[], 0}, fn cur, {acc, pos} ->
        # matrex matrices are one-based
        cur_row = div(pos, cols) + 1
        cur_col = rem(pos, cols) + 1

        if octopi[cur_row][cur_col] == 10 do
          {[{cur_row, cur_col} | acc], pos + 1}
        else
          {acc, pos + 1}
        end
      end)

    flash(octopi_to_flash, flash_points, MapSet.new())
  end

  defp flash(octopi, [], flashed), do: {octopi, MapSet.size(flashed)}

  defp flash(octopi, flash_points, flashed) do
    Enum.reduce(flash_points,[], fn -> {row, col}, acc ->
      {adj_points, adj_values} = adjacents(octopi, row, col)
    end
  end

  defp adjacents(octopi, cur_row, cur_col) do
    {rows, cols} = Matrex.size(octopi)

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

    adjacent_values = Enum.map(adjacent_points, fn {row, col} -> octopi[row][col] end)

    {adjacent_points, adjacent_values}
  end
end

File.stream!("ex_input.txt")
|> Enum.map(fn line ->
  String.trim(line) |> String.graphemes() |> Enum.map(&String.to_integer/1)
end)
|> Matrex.new()
|> Octopi.steps(100)
|> IO.inspect()
