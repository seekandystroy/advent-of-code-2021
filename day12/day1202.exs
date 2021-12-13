defmodule CavePaths do
  def calc_paths_single_repeat(edges) when is_map(edges) do
    downcases =
      Map.keys(edges)
      |> Enum.filter(&(String.downcase(&1) == &1))
      |> Enum.reject(&(&1 == "end"))

    Enum.flat_map(downcases, fn to_repeat ->
      calc_paths_single_repeat(edges, ["start"], MapSet.new(), to_repeat, 0)
    end)
  end

  defp calc_paths_single_repeat(_, ["end" | _] = path, _, _to_repeat, 2), do: [path]
  defp calc_paths_single_repeat(_, ["end" | _], _, _to_repeat, reps) when reps < 2, do: []

  defp calc_paths_single_repeat(edges, [cur | _] = pre_path, cant_repeat, to_repeat, reps) do
    Map.get(edges, cur)
    |> Enum.reject(&MapSet.member?(cant_repeat, &1))
    |> Enum.reject(&(&1 == to_repeat && reps == 2))
    |> Enum.flat_map(fn child ->
      cant_repeat =
        if child != to_repeat && String.downcase(child) == child do
          MapSet.put(cant_repeat, child)
        else
          cant_repeat
        end

      reps =
        if child == to_repeat do
          reps + 1
        else
          reps
        end

      calc_paths_single_repeat(edges, [child | pre_path], cant_repeat, to_repeat, reps)
    end)
  end

  def calc_paths_no_repeats(edges) when is_map(edges) do
    calc_paths_no_repeats(edges, ["start"], MapSet.new())
  end

  defp calc_paths_no_repeats(_, ["end" | _] = path, _), do: [path]

  defp calc_paths_no_repeats(edges, [cur | _] = pre_path, cant_repeat) do
    Map.get(edges, cur)
    |> Enum.reject(&MapSet.member?(cant_repeat, &1))
    |> Enum.flat_map(fn child ->
      cant_repeat =
        if String.downcase(child) == child do
          MapSet.put(cant_repeat, child)
        else
          cant_repeat
        end

      calc_paths_no_repeats(edges, [child | pre_path], cant_repeat)
    end)
  end
end

edges =
  File.stream!("input.txt")
  |> Enum.reduce(%{}, fn line, connections ->
    [fst, snd] =
      String.trim(line)
      |> String.split("-")

    {_, connections} =
      Map.get_and_update(connections, fst, fn cur ->
        tail = cur || []

        if snd != "start" do
          {cur, [snd | tail]}
        else
          {cur, tail}
        end
      end)

    {_, connections} =
      Map.get_and_update(connections, snd, fn cur ->
        tail = cur || []

        if fst != "start" do
          {cur, [fst | tail]}
        else
          {cur, tail}
        end
      end)

    connections
  end)

no_repeats = CavePaths.calc_paths_no_repeats(edges)

repeats = CavePaths.calc_paths_single_repeat(edges)

(length(no_repeats) + length(repeats))
|> IO.inspect()
