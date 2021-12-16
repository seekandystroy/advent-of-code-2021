defmodule MatrixTraversal do
  def gigantamax_maze(matrix) do
    # 1 is matrix, the initial one
    # 1 2 3 4 5
    # 2 3 4 5 6
    # 3 4 5 6 7
    # 4 5 6 7 8
    # 5 6 7 8 9
    matrix2 = plus_one_matrix(matrix)
    matrix3 = plus_one_matrix(matrix2)
    matrix4 = plus_one_matrix(matrix3)
    matrix5 = plus_one_matrix(matrix4)
    matrix6 = plus_one_matrix(matrix5)
    matrix7 = plus_one_matrix(matrix6)
    matrix8 = plus_one_matrix(matrix7)
    matrix9 = plus_one_matrix(matrix8)

    row1 = Matrex.concat([matrix, matrix2, matrix3, matrix4, matrix5])
    row2 = Matrex.concat([matrix2, matrix3, matrix4, matrix5, matrix6])
    row3 = Matrex.concat([matrix3, matrix4, matrix5, matrix6, matrix7])
    row4 = Matrex.concat([matrix4, matrix5, matrix6, matrix7, matrix8])
    row5 = Matrex.concat([matrix5, matrix6, matrix7, matrix8, matrix9])

    Matrex.concat(row1, row2, :rows)
    |> Matrex.concat(row3, :rows)
    |> Matrex.concat(row4, :rows)
    |> Matrex.concat(row5, :rows)
  end

  defp plus_one_matrix(matrix) do
    Matrex.add(matrix, 1)
    |> Matrex.apply(fn val ->
      if val == 10 do
        1
      else
        val
      end
    end)
  end

  def lowest_cost(matrix) do
    cost_map = min_spt(matrix, MapSet.new(), %{{1, 1} => 0})

    Map.get(cost_map, {matrix[:rows], matrix[:cols]})
  end

  defp min_spt(matrix, spt, distances) do
    {{r, c}, cost} =
      Enum.reject(distances, fn {pair, _} -> MapSet.member?(spt, pair) end)
      |> Enum.min(fn {_, val1}, {_, val2} -> val1 < val2 end)

    new_spt = MapSet.put(spt, {r, c})

    new_distances =
      adjacents(matrix, r, c)
      |> Enum.reduce(distances, fn {r, c}, distances ->
        new_cost = matrix[r][c] + cost

        Map.update(distances, {r, c}, new_cost, fn existing_cost ->
          min(existing_cost, new_cost)
        end)
      end)

    if MapSet.size(new_spt) == 250_000 do
      new_distances
    else
      min_spt(matrix, new_spt, new_distances)
    end
  end

  defp adjacents(matrix, cur_row, cur_col) do
    {rows, cols} = Matrex.size(matrix)

    adjacent_points =
      [
        {cur_row - 1, cur_col},
        {cur_row + 1, cur_col},
        {cur_row, cur_col - 1},
        {cur_row, cur_col + 1}
        # diagonals not relevant for now
        # {cur_row - 1, cur_col - 1},
        # {cur_row - 1, cur_col + 1},
        # {cur_row + 1, cur_col - 1},
        # {cur_row + 1, cur_col + 1}
      ]
      |> Enum.reject(fn {r, c} -> r < 1 || r > rows || c < 1 || c > cols end)

    adjacent_points
  end
end

File.stream!("input.txt")
|> Enum.map(fn line ->
  String.trim(line)
  |> String.graphemes()
  |> Enum.map(&String.to_integer/1)
end)
|> Matrex.new()
|> MatrixTraversal.gigantamax_maze()
|> MatrixTraversal.lowest_cost()
|> IO.inspect()
