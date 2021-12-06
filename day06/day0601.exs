defmodule Fish do
  def fish_after_days(fish, 0), do: Enum.count(fish)

  def fish_after_days(fish, days) do
    populate_fish(fish)
    |> fish_after_days(days - 1)
  end

  defp populate_fish(fish) do
    Stream.map(fish, &(&1 - 1))
    |> Enum.flat_map(
      &if &1 == -1 do
        [6, 8]
      else
        [&1]
      end
    )
  end
end

starting_fish =
  File.open!("input.txt")
  |> IO.read(:line)
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

Fish.fish_after_days(starting_fish, 80)
|> IO.inspect()
