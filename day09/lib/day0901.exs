up = fn matrix, row, col -> matrix[row - 1][col] end
down = fn matrix, row, col -> matrix[row + 1][col] end
left = fn matrix, row, col -> matrix[row][col - 1] end
right = fn matrix, row, col -> matrix[row][col + 1] end

heightmap =
  File.stream!("input.txt")
  |> Enum.map(fn line ->
    String.trim(line) |> String.graphemes() |> Enum.map(&String.to_integer/1)
  end)
  |> Matrex.new()

{rows, cols} = Matrex.size(heightmap)

{mins, _} =
  Enum.reduce(heightmap, {[], 0}, fn cur, {acc, pos} ->
    # matrex matrices are one-based
    cur_row = div(pos, cols) + 1
    cur_col = rem(pos, cols) + 1

    adjacents = []

    adjacents =
      unless cur_row == 1, do: [up.(heightmap, cur_row, cur_col) | adjacents], else: adjacents

    adjacents =
      unless cur_row == rows,
        do: [down.(heightmap, cur_row, cur_col) | adjacents],
        else: adjacents

    adjacents =
      unless cur_col == 1, do: [left.(heightmap, cur_row, cur_col) | adjacents], else: adjacents

    adjacents =
      unless cur_col == cols,
        do: [right.(heightmap, cur_row, cur_col) | adjacents],
        else: adjacents

    if not Enum.member?(adjacents, cur) and Enum.min([cur | adjacents]) == cur do
      {[cur + 1 | acc], pos + 1}
    else
      {acc, pos + 1}
    end
  end)

Enum.sum(mins)
|> IO.inspect()
