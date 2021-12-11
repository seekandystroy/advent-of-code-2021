defmodule Chunk do
  def score_line(line) do
    String.trim(line)
    |> String.graphemes()
    |> Enum.reduce_while([], fn char, stack ->
      if opener?(char) do
        {:cont, [closer_for(char) | stack]}
      else
        [expected | rest] = stack

        if char == expected do
          {:cont, rest}
        else
          {:halt, char}
        end
      end
    end)
    |> score()
  end

  defp opener?(char) when char in ["(", "[", "{", "<"], do: true
  defp opener?(_), do: false

  defp closer_for("("), do: ")"
  defp closer_for("["), do: "]"
  defp closer_for("{"), do: "}"
  defp closer_for("<"), do: ">"

  defp score(")"), do: 3
  defp score("]"), do: 57
  defp score("}"), do: 1197
  defp score(">"), do: 25137
  defp score(_), do: 0
end

File.stream!("input.txt")
|> Enum.map_reduce(0, fn line, score ->
  line_score = Chunk.score_line(line)

  {line_score, score + line_score}
end)
|> IO.inspect()
