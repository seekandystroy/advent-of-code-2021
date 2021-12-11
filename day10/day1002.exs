defmodule Chunk do
  def complete_line(line) do
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
          {:halt, []}
        end
      end
    end)
  end

  def score_completions(completions) do
    Enum.reduce(completions, 0, fn char, score ->
      score * 5 + score(char)
    end)
  end

  defp opener?(char) when char in ["(", "[", "{", "<"], do: true
  defp opener?(_), do: false

  defp closer_for("("), do: ")"
  defp closer_for("["), do: "]"
  defp closer_for("{"), do: "}"
  defp closer_for("<"), do: ">"

  defp score(")"), do: 1
  defp score("]"), do: 2
  defp score("}"), do: 3
  defp score(">"), do: 4
end

scores =
  File.stream!("input.txt")
  |> Stream.map(&Chunk.complete_line/1)
  |> Stream.reject(&(&1 == []))
  |> Stream.map(&Chunk.score_completions/1)
  |> Enum.sort()

middle_index = length(scores) |> div(2)

List.pop_at(scores, middle_index)
|> IO.inspect()
