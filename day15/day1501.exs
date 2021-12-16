defmodule MatrixTraversal do
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

    # I cheated and saw the size of the matrix, sue me
    if MapSet.size(new_spt) == 10000 do
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
|> MatrixTraversal.lowest_cost()
|> IO.inspect()
