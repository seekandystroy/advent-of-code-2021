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

    [
      Matrex.concat([matrix, matrix2, matrix3, matrix4, matrix5]),
      Matrex.concat([matrix2, matrix3, matrix4, matrix5, matrix6]),
      Matrex.concat([matrix3, matrix4, matrix5, matrix6, matrix7]),
      Matrex.concat([matrix4, matrix5, matrix6, matrix7, matrix8]),
      Matrex.concat([matrix5, matrix6, matrix7, matrix8, matrix9])
    ]
  end

  def min_spt_row_by_row([first | list_of_matrices]) do
    {first_spt, first_costs} = min_spt(first, MapSet.new(), %{{1, 1} => 0})

    {_, _, costs} =
      Enum.reduce(list_of_matrices, {first, first_spt, first_costs}, fn next_matrix,
                                                                        {acc_matrix, spt, costs} ->
        # update adjacents to the last row of the previous matrix, to kick off the algorithm
        # after joining the matrices
        prev_row = acc_matrix[:rows]

        new_costs =
          Enum.reduce(1..acc_matrix[:cols], costs, fn col, new_costs ->
            Map.put(
              new_costs,
              {prev_row + 1, col},
              next_matrix[1][col] + Map.get(new_costs, {prev_row, col})
            )
          end)

        new_acc_matrix =
          Matrex.concat(acc_matrix, next_matrix, :rows)
          |> IO.inspect()

        {new_spt, new_costs} = min_spt(new_acc_matrix, spt, new_costs)

        {new_acc_matrix, new_spt, new_costs}
      end)

    costs
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

    if MapSet.size(new_spt) == Matrex.size(matrix) |> Tuple.product() do
      {new_spt, clean_distances(new_distances, matrix[:rows])}
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

  defp clean_distances(distances, r) do
    Enum.filter(distances, fn {{row, _}, _} -> row == r end)
    |> Map.new()
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
|> MatrixTraversal.min_spt_row_by_row()
|> Map.get({500, 500})
|> IO.inspect()
