File.stream!("input.txt", [:charlist])
|> Stream.reject(&(&1 == '\n'))
|> Enum.zip_reduce([], fn charlist, acc ->
  [Enum.frequencies(charlist) | acc]
end)
|> Stream.drop(1)
|> Enum.reduce([[], []], fn %{49 => ones, 48 => zeros}, [gamma, epsilon] ->
  if ones > zeros do
    [[49 | gamma], [48 | epsilon]]
  else
    [[48 | gamma], [49 | epsilon]]
  end
end)
|> Stream.map(&(Kernel.to_string(&1) |> String.to_integer(2)))
|> Enum.product()
|> IO.inspect()
