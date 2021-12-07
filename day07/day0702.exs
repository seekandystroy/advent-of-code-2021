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
      # Enum.sum(0..steps)
      # sum of an arithmetic sequence is
      # n / 2 * (2 * a + (n - 1) * d)
      # n = steps + 1 (to account for starting at 0), a = 0, d = 1
      {to, fuel + div(steps * (steps + 1), 2) * number_of_crabs}
    end)

  updated_distances
end)
|> Enum.min(fn {_, x}, {_, y} -> x < y end)
|> IO.inspect()
