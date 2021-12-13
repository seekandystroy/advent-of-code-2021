defmodule CavePaths do
  def calc_paths(edges) when is_map(edges) do
    calc_paths(edges, ["start"], MapSet.new())
  end

  defp calc_paths(_, ["end" | _] = path, _), do: [path]

  defp calc_paths(edges, [cur | _] = pre_path, cant_repeat) do
    Map.get(edges, cur)
    |> Enum.reject(&MapSet.member?(cant_repeat, &1))
    |> Enum.flat_map(fn child ->
      cant_repeat =
        if String.downcase(child) == child do
          MapSet.put(cant_repeat, child)
        else
          cant_repeat
        end

      calc_paths(edges, [child | pre_path], cant_repeat)
    end)
  end
end

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
|> CavePaths.calc_paths()
|> length
|> IO.inspect()
