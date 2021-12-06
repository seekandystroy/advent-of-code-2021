starting_timers =
  File.open!("input.txt")
  |> IO.read(:line)
  |> String.trim()
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

starting_fish = Enum.count(starting_timers)

# each entry means how many fish will be born on a certain day
# assuming we start on day 0, the starting map is == to the frequencies
# this means starting fish with timer = 0 give birth on day 0, then day 7, etc...
births_per_day = Enum.frequencies(starting_timers)

{total_fish, _} =
  Enum.reduce(0..255, {starting_fish, births_per_day}, fn day, {current_fish, bpd} ->
    births_today = Map.get(bpd, day, 0)
    births_in_9 = Map.get(bpd, day + 9, 0)
    births_in_7 = Map.get(bpd, day + 7, 0)

    # newborns give birth after 9 days
    # non-newborns give birth again after 7 days
    updates = %{
      (day + 9) => births_in_9 + births_today,
      (day + 7) => births_in_7 + births_today
    }

    updated_bpd = Map.merge(bpd, updates)
    total_fish_today = current_fish + births_today

    {total_fish_today, updated_bpd}
  end)

IO.inspect(total_fish)
