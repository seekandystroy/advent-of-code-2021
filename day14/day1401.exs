{:ok, file} = File.open("input.txt")

template =
  IO.read(file, :line)
  |> String.trim()
  |> String.graphemes()

# empty line
IO.read(file, :line)

# to make this a naïve chunk_every |> flat_map, there must be no duplicates
# this map removes the head to achieve that, when mapping in sequence
rules =
  IO.stream(file, :line)
  |> Enum.map(fn line ->
    [adj, mid] =
      String.trim(line)
      |> String.split(" -> ")

    [a, b] = String.graphemes(adj)
    {[a, b], [mid, b]}
  end)
  |> Map.new()

# naïve works for few steps
element_frequencies =
  Enum.reduce(1..10, template, fn _, [h | _] = polymer ->
    # add the first head to compensate for the removal in the first element
    [
      h
      | Enum.chunk_every(polymer, 2, 1, :discard)
        |> Enum.flat_map(&Map.get(rules, &1))
    ]
  end)
  |> Enum.frequencies()

{_, most_common} =
  Enum.max(element_frequencies, fn {_ele1, freq1}, {_ele2, freq2} -> freq1 > freq2 end)

{_, least_common} =
  Enum.max(element_frequencies, fn {_ele1, freq1}, {_ele2, freq2} -> freq1 < freq2 end)

IO.inspect(most_common - least_common)
