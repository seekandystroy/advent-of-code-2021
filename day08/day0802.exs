defmodule Decoder do
  # uses signal patterns to decode outputs
  def decode(signal_patterns, output) do
    deduce_key(signal_patterns)
    |> apply_key(output)
  end

  defp deduce_key(signal_patterns) do
    # actual segment => possibilities
    possibilities = %{}

    sorted_patterns =
      Enum.sort(signal_patterns, fn x, y -> String.length(x) < String.length(y) end)

    Enum.reduce(sorted_patterns, possibilities, fn pattern, poss ->
      deduce_pattern(String.graphemes(pattern), poss)
    end)
    |> invert_key_and_remove_map_set()
  end

  # 2 segments is 1: "cf"
  defp deduce_pattern(list_pattern, _possibilities) when length(list_pattern) == 2 do
    options_for_c_and_f = MapSet.new(list_pattern)
    base_possibilities = MapSet.new(["a", "b", "c", "d", "e", "f", "g"])
    diff = MapSet.difference(base_possibilities, options_for_c_and_f)

    %{
      "a" => diff,
      "b" => diff,
      "c" => options_for_c_and_f,
      "d" => diff,
      "e" => diff,
      "f" => options_for_c_and_f,
      "g" => diff
    }
  end

  # 3 segments is 7 "acf"
  defp deduce_pattern(list_pattern, possibilities = %{"c" => options_for_c_and_f})
       when length(list_pattern) == 3 do
    option_for_a =
      Enum.reject(list_pattern, &MapSet.member?(options_for_c_and_f, &1))
      |> MapSet.new()

    Map.map(possibilities, fn {k, v} ->
      if k == "a" do
        option_for_a
      else
        MapSet.difference(v, option_for_a)
      end
    end)
  end

  # 4 segments is 4 "bcdf"
  defp deduce_pattern(list_pattern, possibilities = %{"c" => options_for_c_and_f})
       when length(list_pattern) == 4 do
    options_for_b_and_d =
      Enum.reject(list_pattern, &MapSet.member?(options_for_c_and_f, &1))
      |> MapSet.new()

    Map.map(possibilities, fn {k, v} ->
      if k == "b" || k == "d" do
        options_for_b_and_d
      else
        MapSet.difference(v, options_for_b_and_d)
      end
    end)
  end

  # at this point we know a, and each other segment has 2 possibilities
  # 5 segments is either:
  # 2 "acdeg" (e and g remain unknown)
  # 3 "acdfg" (c and f remain unknown)
  # 5 "abdfg" (b and d remain unknown)
  defp deduce_pattern(
         list_pattern,
         possibilities = %{
           "b" => options_for_b,
           "c" => options_for_c,
           "d" => options_for_d,
           "e" => options_for_e,
           "f" => options_for_f,
           "g" => options_for_g
         }
       )
       when length(list_pattern) == 5 do
    case which_5_segment?(list_pattern, possibilities) do
      {2, result} ->
        %{
          possibilities
          | "b" => MapSet.difference(options_for_b, result),
            "d" => MapSet.intersection(options_for_d, result),
            "c" => MapSet.intersection(options_for_c, result),
            "f" => MapSet.difference(options_for_f, result)
        }

      {3, result} ->
        %{
          possibilities
          | "b" => MapSet.difference(options_for_b, result),
            "d" => MapSet.intersection(options_for_d, result),
            "e" => MapSet.difference(options_for_e, result),
            "g" => MapSet.intersection(options_for_g, result)
        }

      {5, result} ->
        %{
          possibilities
          | "c" => MapSet.difference(options_for_c, result),
            "f" => MapSet.intersection(options_for_f, result),
            "e" => MapSet.difference(options_for_e, result),
            "g" => MapSet.intersection(options_for_g, result)
        }
    end
  end

  # with a sorted patterns array, we already have the (inverted) key after deducing the 5-segment patterns
  defp deduce_pattern(_, possibilities), do: possibilities

  defp which_5_segment?(
         list_pattern,
         _possibilities = %{
           "a" => a,
           "b" => b,
           "c" => c,
           "d" => d,
           "e" => e,
           "f" => f,
           "g" => g
         }
       ) do
    to_discover =
      MapSet.new(list_pattern)
      |> MapSet.difference(a)

    possible_2 = MapSet.difference(to_discover, MapSet.union(e, g))
    possible_3 = MapSet.difference(to_discover, MapSet.union(c, f))
    possible_5 = MapSet.difference(to_discover, MapSet.union(b, d))

    cond do
      possible_2 |> MapSet.size() == 2 -> {2, possible_2}
      possible_3 |> MapSet.size() == 2 -> {3, possible_3}
      possible_5 |> MapSet.size() == 2 -> {5, possible_5}
    end
  end

  # possibilities is a mapping from the actual segments to the possibilities
  # to decode, we need the opposite, to map a wire to the true segment
  defp invert_key_and_remove_map_set(possibilities) do
    Enum.map(possibilities, fn {k, v} ->
      [vv] = MapSet.to_list(v)
      {vv, k}
    end)
    |> Map.new()
  end

  defp apply_key(key, output) do
    Stream.map(output, &translate_segments(key, &1))
    |> Enum.join()
    |> String.to_integer()
  end

  defp translate_segments(key, value) do
    String.graphemes(value)
    |> Stream.map(&Map.get(key, &1))
    |> Enum.sort()
    |> Enum.join()
    |> number()
  end

  #  aaaa
  # b    c
  # b    c
  #  dddd
  # e    f
  # e    f
  #  gggg
  defp number("cf"), do: 1
  defp number("acf"), do: 7
  defp number("bcdf"), do: 4
  defp number("acdeg"), do: 2
  defp number("acdfg"), do: 3
  defp number("abdfg"), do: 5
  defp number("abdefg"), do: 6
  defp number("abcdfg"), do: 9
  defp number("abcefg"), do: 0
  defp number("abcdefg"), do: 8
end

stream = File.stream!("input.txt")

Enum.reduce(stream, 0, fn line, output_sum ->
  [string_sigs, string_out] = String.split(line, " | ")
  sigs = String.split(string_sigs)
  out = String.split(string_out)

  output_sum + Decoder.decode(sigs, out)
end)
|> IO.inspect()
