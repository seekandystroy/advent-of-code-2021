defmodule Octopi do
  def steps_to_100(octopi, step_num) do
    case step(octopi) do
      {_, 100} -> IO.puts("Sync at step #{step_num}")
      {updated_octopi, _} -> steps_to_100(updated_octopi, step_num + 1)
    end
  end

  defp step(octopi) do
    octopi_to_flash = Matrex.add(octopi, 1)
    {_rows, cols} = Matrex.size(octopi)

    {flash_points, _} =
      Enum.reduce(octopi_to_flash, {[], 0}, fn cur, {acc, pos} ->
        # matrex matrices are one-based
        cur_row = div(pos, cols) + 1
        cur_col = rem(pos, cols) + 1

        if cur >= 10 do
          {[{cur_row, cur_col} | acc], pos + 1}
        else
          {acc, pos + 1}
        end
      end)

    {stepped_octopi, flashes} = flash(octopi_to_flash, MapSet.new(flash_points), MapSet.new())

    {
      Matrex.apply(stepped_octopi, fn val ->
        if val >= 10 do
          0
        else
          val
        end
      end),
      flashes
    }
  end

  defp flash(octopi, flash_points, flashed) do
    if Enum.empty?(flash_points) do
      {octopi, MapSet.size(flashed)}
    else
      {updated_octopi, new_flash_points, new_flashed} =
        Enum.reduce(flash_points, {octopi, MapSet.new(), flashed}, fn {row, col},
                                                                      {octopi, new_flash_points,
                                                                       flashed} ->
          new_flashed = MapSet.put(flashed, {row, col})

          {adj_points, adj_values} = adjacents(octopi, row, col)

          {updated_octopi, new_flash_points} =
            Enum.zip(adj_points, adj_values)
            |> Enum.reject(fn {point, _} ->
              MapSet.member?(new_flashed, point) or MapSet.member?(flash_points, point)
            end)
            |> Enum.reduce({octopi, new_flash_points}, fn {{r, c} = point, value},
                                                          {updated_octopi, new_flash_points} ->
              if value + 1 >= 10 do
                {Matrex.set(updated_octopi, r, c, value + 1), MapSet.put(new_flash_points, point)}
              else
                {Matrex.set(updated_octopi, r, c, value + 1), new_flash_points}
              end
            end)

          {updated_octopi, new_flash_points, new_flashed}
        end)

      flash(updated_octopi, new_flash_points, new_flashed)
    end
  end

  defp adjacents(octopi, cur_row, cur_col) do
    {rows, cols} = Matrex.size(octopi)

    adjacent_points =
      [
        {cur_row - 1, cur_col},
        {cur_row + 1, cur_col},
        {cur_row, cur_col - 1},
        {cur_row, cur_col + 1},
        {cur_row - 1, cur_col - 1},
        {cur_row - 1, cur_col + 1},
        {cur_row + 1, cur_col - 1},
        {cur_row + 1, cur_col + 1}
      ]
      |> Enum.reject(fn {r, c} -> r < 1 || r > rows || c < 1 || c > cols end)

    adjacent_values = Enum.map(adjacent_points, fn {row, col} -> octopi[row][col] end)

    {adjacent_points, adjacent_values}
  end
end

File.stream!("input.txt")
|> Enum.map(fn line ->
  String.trim(line) |> String.graphemes() |> Enum.map(&String.to_integer/1)
end)
|> Matrex.new()
|> Octopi.steps_to_100(1)
