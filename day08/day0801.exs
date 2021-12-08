stream = File.stream!("input.txt")

{_signal_patterns, outputs} =
  Enum.reduce(stream, {[], []}, fn line, {sigs, outs} ->
    [string_sigs, string_outs] = String.split(line, " | ")
    new_sigs = String.split(string_sigs)
    new_outs = String.split(string_outs)

    {new_sigs ++ sigs, new_outs ++ outs}
  end)

Stream.map(outputs, &String.length/1)
|> Enum.frequencies()
|> Map.take([2, 3, 4, 7])
|> Map.values()
|> Enum.sum()
|> IO.inspect()
