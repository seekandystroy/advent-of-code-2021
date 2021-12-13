defmodule Origami do
  def apply_folds(points, folds) do
    Enum.reduce(folds, points, fn fold, points ->
      fold(points, fold)
    end)
  end

  def draw_points(points) do
    {cols, _} = Enum.max(points, fn {x1, _y1}, {x2, _y2} -> x1 > x2 end)
    {_, rows} = Enum.max(points, fn {_x1, y1}, {_x2, y2} -> y1 > y2 end)

    base = Matrex.zeros(rows + 1, cols + 1)

    Enum.reduce(points, base, fn {c, r}, grid ->
      Matrex.set(grid, r + 1, c + 1, 1)
    end)
    |> Matrex.to_list_of_lists()
    |> Enum.map(fn list ->
      Enum.map(list, fn number ->
        if number == 1 do
          "#"
        else
          "."
        end
      end)
    end)
    |> IO.inspect(limit: :infinity, printable_limit: :infinity)
  end

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

Origami.apply_folds(points, Enum.reverse(folds))
|> Origami.draw_points()
