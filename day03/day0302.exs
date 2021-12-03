defmodule Ratings do
  def get_oxy_rating(numbers) do
    get_rating(numbers, 0, &get_most_common_at/2)
  end

  def get_co2_rating(numbers) do
    get_rating(numbers, 0, &get_least_common_at/2)
  end

  defp get_rating(numbers, pos, criterion_function) do
    to_keep = criterion_function.(numbers, pos)

    new_remainder =
      Enum.filter(numbers, fn number ->
        {at_pos, _} = List.pop_at(Enum.to_list(number), pos)
        at_pos == to_keep
      end)

    case new_remainder do
      [rating] ->
        {base10_rating, _} = to_string(rating) |> Integer.parse(2)
        base10_rating

      [] ->
        :BURRO

      _ ->
        get_rating(new_remainder, pos + 1, criteria_function)
    end
  end

  defp get_most_common_at(numbers, pos) do
    {%{49 => ones, 48 => zeros}, _} =
      Enum.zip_reduce(numbers, [], fn charlist, acc ->
        [Enum.frequencies(charlist) | acc]
      end)
      |> Stream.drop(1)
      |> Enum.reverse()
      |> List.pop_at(pos)

    if ones >= zeros do
      49
    else
      48
    end
  end

  defp get_least_common_at(numbers, pos) do
    case get_most_common_at(numbers, pos) do
      49 -> 48
      48 -> 49
    end
  end
end

numbers =
  File.stream!("input.txt", [:charlist])
  |> Stream.reject(&(&1 == '\n'))

oxy_rating = Ratings.get_oxy_rating(numbers) |> IO.inspect()
co2_rating = Ratings.get_co2_rating(numbers) |> IO.inspect()

IO.inspect(oxy_rating * co2_rating)
