defmodule Decoder do
  # uses signal patterns to decode outputs
  def decode(signal_patterns, output) do
    deduce_key(signal_patterns)
    |> apply_key(output)
  end

  defp deduce_key(signal_patterns) do
    # input letter => actual segment
    %{
      "a" => "a",
      "b" => "b",
      "c" => "c",
      "d" => "d",
      "e" => "e",
      "f" => "f",
      "g" => "g"
    }
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
  defp number("acdeg"), do: 2
  defp number("acdfg"), do: 3
  defp number("bcdf"), do: 4
  defp number("abdfg"), do: 5
  defp number("abdefg"), do: 6
  defp number("acf"), do: 7
  defp number("abcdefg"), do: 8
  defp number("abcdfg"), do: 9
end

stream = File.stream!("ex_input.txt")

Enum.reduce(stream, 0, fn line, output_sum ->
  [string_sigs, string_out] = String.split(line, " | ")
  sigs = String.split(string_sigs)
  out = String.split(string_out)

  output_sum + Decoder.decode(sigs, out)
end)
|> IO.inspect()
