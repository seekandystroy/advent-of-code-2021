heightmap =
  File.stream!("ex_input.txt")
  |> Enum.map(fn line ->
    String.trim(line) |> String.graphemes() |> Enum.map(&String.to_integer/1)
  end)
  |> Matrex.new()
  |> IO.inspect()
