defmodule VectorTest do
  use ExUnit.Case
  doctest Vector

  setup do
    list = Enum.to_list(0..100)
    vec = Vector.new(list)

    %{list: list,
      vec: vec}
  end

  test "Access", context do
    assert context[:vec][999] == nil
    assert context[:vec][52] == 52
  end

  test "Collectible", context do
    assert context[:list] |> Enum.into(Vector.new)
                          |> Vector.to_list == context[:list]
  end

  test "Enumerable", context do
    assert Enum.map(context[:vec], fn(n) -> n + 1 end) == Enum.to_list(1..101)
  end
end
