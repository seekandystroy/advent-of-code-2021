crabs =
  File.open!("input.txt")
  |> IO.read(:line)
  |> String.trim()
  |> String.split(",")
  |> Stream.map(&String.to_integer/1)

min_pos = Enum.min(crabs)
max_pos = Enum.max(crabs)
crabs_per_position = Enum.frequencies(crabs)

distances = Enum.map(min_pos..max_pos, fn pos -> {pos, 0} end)

Enum.reduce(crabs_per_position, distances, fn {from, number_of_crabs}, distances ->
  updated_distances =
    Enum.map(distances, fn {to, fuel} ->
      steps = abs(from - to)
      {to, fuel + Enum.sum(0..steps) * number_of_crabs}
    end)

  updated_distances
end)
|> Enum.min(fn {_, x}, {_, y} -> x < y end)
|> IO.inspect()
