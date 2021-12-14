defmodule Polymer do
  def elements_after_steps([h | _] = polymer, rules, steps) do
    {complete_polymer, _} =
      Enum.chunk_every(polymer, 2, 1, :discard)
      |> Enum.flat_map_reduce(%{}, fn pair, memo ->
        {[_h | part], new_memo} = memoized_elements_after_steps(pair, rules, steps, memo)

        {part, new_memo}
      end)

    # add the first head to compensate for the removal in the first element
    [h | complete_polymer]
  end

  defp memoized_elements_after_steps([a, _b] = polymer, rules, 1, memo) do
    [mid, b] = Map.get(rules, polymer)
    {[a, mid, b], memo}
  end

  defp memoized_elements_after_steps([a, _b] = polymer, rules, steps, memo) do
    case Map.get(memo, {polymer, steps}) do
      nil ->
        [mid, b] = Map.get(rules, polymer)

        {apart, new_memo} = memoized_elements_after_steps([a, mid], rules, steps - 1, memo)

        {[_mid | bpart], new_memo} =
          memoized_elements_after_steps([mid, b], rules, steps - 1, new_memo)

        new_polymer = apart ++ bpart

        new_memo =
          Map.delete(new_memo, {polymer, steps - 1})
          |> Map.put({polymer, steps}, new_polymer)

        {new_polymer, new_memo}

      new_polymer ->
        {new_polymer, memo}
    end
  end
end

{:ok, file} = File.open("input.txt")

template =
  IO.read(file, :line)
  |> String.trim()
  |> String.graphemes()

# empty line
IO.read(file, :line)

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

element_frequencies =
  Polymer.elements_after_steps(template, rules, 10)
  |> Enum.frequencies()

{_, most_common} =
  Enum.max(element_frequencies, fn {_ele1, freq1}, {_ele2, freq2} -> freq1 > freq2 end)

{_, least_common} =
  Enum.max(element_frequencies, fn {_ele1, freq1}, {_ele2, freq2} -> freq1 < freq2 end)

IO.inspect(most_common - least_common)
