winning_board? = fn board, x, y ->
  values = Map.values(board)

  if Enum.filter(values, fn {tx, _} -> tx == x end) |> Enum.empty?() do
    true
  else
    Enum.filter(values, fn {_, ty} -> ty == y end) |> Enum.empty?()
  end
end

count_points = fn board, draw ->
  board_points =
    Map.keys(board)
    |> Stream.map(&String.to_integer/1)
    |> Enum.sum()

  board_points * String.to_integer(draw)
end

file_pid = File.open!("input.txt")

draws = IO.read(file_pid, :line) |> String.trim() |> String.split(",")

boards =
  IO.stream(file_pid, :line)
  |> Stream.chunk_every(6)
  |> Enum.reduce([], fn ["\n" | row_strings_list], boards ->
    {board, _} =
      Stream.flat_map(row_strings_list, &String.split/1)
      |> Enum.reduce({[], 0}, fn number, {acc, i} ->
        {[{number, {div(i, 5), rem(i, 5)}} | acc], i + 1}
      end)

    [board | boards]
  end)
  |> Enum.map(&Map.new/1)

Enum.reduce_while(draws, boards, fn draw, boards ->
  new_boards =
    Enum.map(boards, fn board ->
      case Map.pop(board, draw) do
        {nil, _} ->
          board

        {{x, y}, new_board} ->
          if winning_board?.(new_board, x, y) do
            count_points.(new_board, draw)
          else
            new_board
          end
      end
    end)

  case new_boards do
    [last] when is_integer(last) -> {:halt, IO.inspect(new_boards)}
    [_last] -> {:cont, new_boards}
    _ -> {:cont, Enum.reject(new_boards, &Kernel.is_integer/1)}
  end
end)
