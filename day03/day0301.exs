File.stream!("input.txt", [:charlist])
|> Stream.reject(&(&1 == '\n'))
|> Enum.zip_reduce([], fn charlist, acc ->
  [Enum.frequencies(charlist) | acc]
end)
|> Stream.drop(1)
|> Enum.reduce([[], []], fn %{49 => ones, 48 => zeros}, [gamma, epsilon] ->
  if ones > zeros do
    [['1' | gamma], ['0' | epsilon]]
  else
    [['0' | gamma], ['1' | epsilon]]
  end
end)
|> Stream.map(&(Kernel.to_string(&1) |> String.to_integer(2)))
|> Enum.product()
|> IO.inspect()
