defmodule Origami do
  def fold(points, {"x", fold_line}) do
    Enum.map(points, fn {x, y} ->
      if x < fold_line do
        {x, y}
      else
        {fold_line - (x - fold_line), y}
      end
    end)
    |> Enum.uniq()
  end

  def fold(points, {"y", fold_line}) do
    Enum.map(points, fn {x, y} ->
      if y < fold_line do
        {x, y}
      else
        {x, fold_line - (y - fold_line)}
      end
    end)
    |> Enum.uniq()
  end
end

stream = File.stream!("input.txt")

{points, folds} =
  Enum.reduce(stream, {[], []}, fn line, {points, folds} ->
    if line == "\n" do
      {points, folds}
    else
      if String.starts_with?(line, "f") do
        axis = String.at(line, 11)
        [_, num] = String.trim(line) |> String.split("=")

        {points, [{axis, String.to_integer(num)} | folds]}
      else
        [x, y] =
          String.trim(line)
          |> String.split(",")

        {[{String.to_integer(x), String.to_integer(y)} | points], folds}
      end
    end
  end)

Origami.fold(points, Enum.reverse(folds) |> List.first())
|> length()
|> IO.inspect()
