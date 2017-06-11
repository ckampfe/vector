require Vector

sizes = [1_000, 10_000, 100_000, 1_000_000, 10_000_000]
bench = Enum.reduce(sizes, %{}, fn(size, acc) ->
  rand = :rand.uniform(size)
  list = Enum.to_list(1..size)
  vector = Vector.new(list)

  acc
  |> Map.put(
    "list lookup #{size}",
    fn -> Enum.at(list, rand) end
  )
  |> Map.put(
    "list update #{size}",
    fn -> List.update_at(list, rand, &(&1 + 1)) end
  )
  |> Map.put(
    "vector lookup #{size}",
    fn -> Vector.get(vector, rand) end
  )
  |> Map.put(
    "vector update #{size}",
    fn -> Vector.update!(vector, rand, &(&1 + 1)) end
  )
end)

Benchee.run(
  bench,
  warmup: 5,
  time: 10,
  print: [fast_warning: false])
