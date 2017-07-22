defmodule Vector do
  @moduledoc """
  Functions that work on vectors.

  This datastructure wraps Erlang's `array` type for fast random
  lookup and update to large collections.

  The point of this module is not meant to be a 1:1 wrapper, but to be
  a useful set of higher-level API operations.

  Note that this module is implemented as a struct with an `array` field,
  pointing to the underlying Erlang `array` implementation. This field
  is private, so you should use the functions in this module
  to perform operations.
  """

  # this is not great, but `array()` is not available in Elixir
  @opaque t :: %__MODULE__{array: :array.array()}
  @type index :: integer
  @type value :: any
  @type acc :: any
  @type array_reducing_fn :: ((non_neg_integer, value, acc) -> acc)

  @behaviour Access

  defstruct array: :array.new()

  @doc """
  Constructs a array-backed vector

  ## Examples

      iex> Vector.new()
      #Vector<[]>

      iex> Vector.new(Vector.new())
      #Vector<[]>

      iex> Vector.new([1,2,3])
      #Vector<[1, 2, 3]>

      iex> Vector.new(%{a: 1, b: 2})
      #Vector<[a: 1, b: 2]>

      iex> Vector.new(0)
      #Vector<[]>

      # this is exposing a bit of implementation, but I am
      # unsure how else to test it
      iex> Vector.new(5).array
      {:array, 5, 10, :undefined, 10}
  """
  def new(), do: %__MODULE__{}
  def new(%__MODULE__{} = vector), do: vector
  def new(size) when is_integer(size) and size >= 0 do
    %__MODULE__{
      array: :array.new([
        {:size, size},
        {:fixed, false},
        {:default, :undefined}
      ])
    }
  end
  def new(list) when is_list(list) do
    %Vector{array: :array.from_list(list)}
  end
  def new(enumerable) do
    enumerable
    |> Enum.to_list
    |> new
  end

  @doc """
  Converts a `vector` to a list

  ## Examples

      iex> Vector.new() |> Vector.to_list
      []

      iex> Vector.to_list(Vector.new([1,2,3]))
      [1,2,3]

      iex> Vector.new(100) |> Vector.put(39, 1) |> Vector.to_list
      [1]
  """
  def to_list(%Vector{array: array}) do
    :array.sparse_to_list(array)
  end

  @doc """
  Returns the count of initialized elements in the vector. Does not count uninitialized elements.
  This function takes time linear to the number of uninitialized elements.

  ## Examples

      iex> Vector.count(Vector.new())
      0

      iex> Vector.count(Vector.new([1,2,3,4,5]))
      5

      iex> Vector.new(100) |> Vector.count
      0

      iex> Vector.new(100)
      ...> |> Vector.put(43, 1)
      ...> |> Vector.count
      1
  """
  @spec count(t) :: non_neg_integer
  def count(%__MODULE__{} = vector) do
    reduce(vector, 0, fn(_index, _val, acc) -> acc + 1 end)
  end

  @doc """
  Returns the total size of a vector, including all uninitialized/default values.

  This function is a reflection of the total memory size of the underlying Erlang array. It does
  not say anything about the elements of the array. For a count of non-default elements in the vector,
  see `count/1`.

  ## Examples

      iex> Vector.size(Vector.new())
      0

      iex> Vector.size(Vector.new([1,2,3,4,5]))
      5

      iex> Vector.new(100) |> Vector.size
      100

      iex> Vector.new(100) |> Vector.put(43, 1) |> Vector.size
      100
  """
  def size(%Vector{array: array}), do: array.size

  @doc """
  Checks if `vector` contains `value`

  ## Examples

      iex> Vector.member?(Vector.new([1,2,3]), 99)
      false

      iex> Vector.member?(Vector.new([1,2,3]), 2)
      true
  """
  def member?(%Vector{array: array}, value) do
    array
    |> :array.sparse_to_list
    |> MapSet.new()
    |> MapSet.member?(value)
  end

  @doc """
  Finds the element at the given `index` (zero-based) in logarithmic time.
  Returns `{:ok, element}` if found, otherwise `:error`.

  A negative index can be passed, in which case the index is counted from the end (e.g. -1 finds the last element).

## Examples

      iex> Vector.fetch(Vector.new([1,2,3]), 9)
      :error

      iex> Vector.fetch(Vector.new([1,2,3]), 2)
      {:ok, 3}

      iex> Vector.fetch(Vector.new([1,2,3,4,5]), -2)
      {:ok, 4}

      iex> Vector.fetch(Vector.new([1,2,3,4,5]), -6)
      :error
  """
  @spec fetch(t, index) :: {:ok, any} | :error
  def fetch(%__MODULE__{} = vector, index) when is_integer(index) and index < 0 do
    size = Vector.size(vector)
    if (index * -1) > size do
      :error
    else
      fetch(vector, size + index)
    end
  end
  def fetch(%Vector{array: array}, index) when is_integer(index) and index >= 0 do
    case :array.get(index, array) do
      :undefined -> :error
      value -> {:ok, value}
    end
  end

  @doc """
  Finds the element at the given `index` (zero-based) in logarithmic time.

  Raises `OutOfBoundsError` if the given `index` is outside the range of
  the enumerable.

  A negative index can be passed, in which case the index is counted from the end (e.g. -1 finds the last element).

  ## Examples

      iex> Vector.fetch!(Vector.new([1,2,3]), 1)
      2

      iex> Vector.fetch!(Vector.new([1,2,3]), -1)
      3

      iex> Vector.fetch!(Vector.new([1,2,3]), 99)
      ** (Enum.OutOfBoundsError) out of bounds error
  """
  @spec fetch!(t, index) :: value | no_return
  def fetch!(%Vector{} = vector, index) do
    case fetch(vector, index) do
      {:ok, value} -> value
      :error -> raise Enum.OutOfBoundsError
    end
  end

  @doc """
  Puts the given value under index in vector in logarithmic time

  A negative index can be passed, in which case the index is counted from the end (e.g. -1 finds the last element).

  ## Examples

      iex> Vector.put(Vector.new([1,2,3]), 3, 99)
      #Vector<[1, 2, 3, 99]>

      iex> Vector.put(Vector.new([1,2,3]), 0, 3)
      #Vector<[3, 2, 3]>

      iex> Vector.put(Vector.new([1,2,3]), -1, 101)
      #Vector<[1, 2, 101]>

      iex> Vector.put(Vector.new(3), -99, "hi")
      ** (ArgumentError) negative index out of bounds
  """
  @spec put(t, index, value) :: t
  def put(%__MODULE__{} = vector, index, value) when is_integer(index) and index < 0 do
    new_size = Vector.size(vector) + index
    cond do
      new_size >= 0 ->
        put(vector, new_size, value)
      true ->
        raise ArgumentError, "negative index out of bounds"
    end
  end
  def put(%__MODULE__{array: array} = vector, index, value) when is_integer(index) and index >= 0 do
    %{vector | array: :array.set(index, value, array)}
  end

  @doc """
  Updates the value in vector with the given function in logarithmic time.

  If index is present in vector with value, fun is invoked with
  argument value and its result is used as the new value of index. If index is
  not present in vector, initial is inserted as the value of index.

  A negative index can be passed, in which case the index is counted from the end (e.g. -1 finds the last element).

  ## Examples

      iex> Vector.update(Vector.new([1,2,3]), 0, 13, &(&1 * 2))
      #Vector<[2, 2, 3]>

      iex> Vector.update(Vector.new([1,2,3]), 5, 11, &(&1 * 2))
      #Vector<[1, 2, 3, 11]>

      iex> Vector.update(Vector.new([1,2,3]), -2, 11, &(&1 * 2))
      #Vector<[1, 4, 3]>
  """
  @spec update(t, index, value, (value -> value)) :: t
  def update(vector, index, initial, fun) when is_function(fun, 1) do
    case fetch(vector, index) do
      {:ok, value} ->
        put(vector, index, fun.(value))
      :error ->
        put(vector, index, initial)
    end
  end

  @doc """
  Updates index with the given function in logarithmic time.

  If index is present in vector with value, fun is invoked with argument value
  and its result is used as the new value of index. If index is not present in vector,
  a Enum.OutOfBoundsError exception is raised.

  ## Examples

      iex> Vector.update!(Vector.new([1,2,3]), 0, &(&1 * 2))
      #Vector<[2, 2, 3]>

      iex> Vector.update!(Vector.new([1,2,3]), 5, &(&1 * 2))
      ** (Enum.OutOfBoundsError) out of bounds error

      iex> Vector.update!(Vector.new([1,2,3]), -2, &(&1 * 2))
      #Vector<[1, 4, 3]>
  """
  @spec update!(t, index, (value -> value)) :: t | no_return
  def update!(vector, index, fun) when is_function(fun, 1) do
    case fetch(vector, index) do
      {:ok, value} ->
        put(vector, index, fun.(value))
      :error ->
        raise Enum.OutOfBoundsError
    end
  end

  @doc """
  Gets the value at an index in logarithmic time, returning a default if it does not exist.

  ## Examples

      iex> Vector.get(Vector.new([1,2,3]), 0)
      1

      iex> Vector.get(Vector.new([1,2,3]), 9)
      nil

      iex> Vector.get(Vector.new([1,2,3]), 9, 1000)
      1000
  """
  @spec get(t, index, default :: value) :: value
  def get(vector, index, default \\ nil) do
    case fetch(vector, index) do
      {:ok, value} -> value
      :error -> default
    end
  end

  @doc """
  Returns either the vector without the value at index, or the original vector
  if no value is present at index.

  ## Examples

      iex> Vector.delete(Vector.new([1,2,3,4,5]), 2)
      #Vector<[1, 2, 4, 5]>

      iex> Vector.delete(Vector.new([1,2,3]), 9)
      #Vector<[1, 2, 3]>
  """
  @spec delete(t, index) :: t
  def delete(%Vector{array: array} = vector, index) do
    %{vector | array: :array.reset(index, array)}
  end

  @doc """
  Gets and updates a value at the same time.

  ## Examples

      iex> {val, new_vector} = Vector.get_and_update(Vector.new([1,2,3]), 0, fn(value) -> {value, value + 100} end)
      iex> {val, Vector.to_list(new_vector)}
      {1, [101, 2, 3]}

      iex> {val, new_vector} = Vector.get_and_update(Vector.new([1,2,3]), 0, fn(_) -> :pop end)
      iex> {val, Vector.to_list(new_vector)}
      {1, [2, 3]}
  """
  @spec get_and_update(t, index, (value -> {value, value} | :pop)) :: {value, t}
  def get_and_update(vector, index, fun) do
    case fun.(get(vector, index)) do
      {value_to_return, new_value} -> {value_to_return, put(vector, index, new_value)}
      :pop -> pop(vector, index)
    end
  end

  @doc """
  Deletes a value at index, returning the new vector and the value that was deleted

  ## Examples

      iex> {value, new} = Vector.pop(Vector.new([1,2,3]), 2)
      iex> {value, Vector.to_list(new)} # arrays cannot be checked for value equality
      {3, [1, 2]}

      iex> {value, new} = Vector.pop(Vector.new([1,2,3]), 99)
      iex> {value, Vector.to_list(new)}
      {nil, [1, 2, 3]}
  """
  def pop(vector, index, default \\ nil) do
    value = get(vector, index, default)
    {value, delete(vector, index)}
  end

  @doc """
  Append an item to to a vector

  ## Examples

      iex> Vector.new([1, 2, 3]) |> Vector.append(9)
      Vector.new([1, 2, 3, 9])

      iex> Vector.new() |> Vector.append("hi")
      Vector.new(["hi"])

      iex> Vector.new([1, 2, 3]) |> Vector.append(9) |> Vector.size
      4
  """
  @spec append(t, value) :: t
  def append(%__MODULE__{} = vector, value) do
    Vector.put(vector, Vector.size(vector), value)
  end

  @doc """
  Reverse every element in a vector, not including the uninitialized elements.
  Preserves `count`, does not preserve `size`.

  ## Examples

      iex> vector = Vector.new([1,2,3])
      iex> vector |> Vector.reverse |> Vector.reverse
      #Vector<[1, 2, 3]>

      iex> Vector.reverse(Vector.new())
      #Vector<[]>

      iex> Vector.reverse(Vector.new([1, 2, 3]))
      #Vector<[3, 2, 1]>

      iex> vector = Vector.new(50) |> Vector.put(39, "hi")
      iex> reversed = Vector.reverse(vector)
      iex> Vector.count(vector) == Vector.count(reversed)
      true
  """
  @spec reverse(t) :: t
  def reverse(%__MODULE__{} = vector) do
    %{vector | array: :array.from_list(Enum.reverse(vector))}
  end

  @doc """
  Run a function (`fun`) over a vector which takes two arguments: the accumulated results so far (`acc`) and the current vector value (`val`).
  Hits only the initialized elements of the vector. Note that `fun` is arity-3, taking the `index`, `value`, and `acc` in that order.

  Think of this function as the equivalent of the following pseudocode:

  ```
  vector |> filter(initialized?) |> reduce
  ```

  without the intermediate filter, due to sparse folding being an array primitive.

  ## Examples

      iex> Vector.new([1, 2, 3]) |> Vector.reduce(0, fn(_index, val, acc) -> val + acc end)
      6

      iex> Vector.new([1, 2, 3]) |> Vector.reduce(Vector.new(), fn(_index, val, acc) -> Vector.append(acc, val + 1) end)
      #Vector<[2, 3, 4]>

      iex> Vector.new(100)
      ...> |> Vector.put(25, 1)
      ...> |> Vector.put(50, 1)
      ...> |> Vector.put(75, 1)
      ...> |> Vector.put(90, 1)
      ...> |> Vector.reduce(0, fn(_index, val, acc) -> acc + val end)
      4
  """
  @spec reduce(t, acc, array_reducing_fn) :: acc
  def reduce(%__MODULE__{array: array}, initial, fun) when is_function(fun, 3) do
    :array.sparse_foldl(fun, initial, array)
  end

  @doc """
  Run a function over the elements of the vector, not including the uninitialized ones,
  and return the result in a new vector.
  Good for large vectors where only a few elements are set.

  ## Examples

      iex> Vector.new() |> Vector.map(fn(_i, val) -> val + 1 end)
      #Vector<[]>

      iex> Vector.new([1, 2, 3]) |> Vector.map(fn(_i, val) -> val + 1 end)
      #Vector<[2, 3, 4]>

      iex> Vector.new(100) |> Vector.map(fn(_i, _val) -> 1 end) |> Enum.sum
      0
  """
  def map(%__MODULE__{array: array} = vector, fun) when is_function(fun, 2) do
    %{vector | array: :array.sparse_map(fun, array)}
  end

  defimpl Enumerable do
    def count(vector), do: {:ok, Vector.count(vector)}
    def member?(vector, val), do: {:ok, Vector.member?(vector, val)}
    def reduce(vector, acc, fun), do: Enumerable.List.reduce(Vector.to_list(vector), acc, fun)
  end

  defimpl Collectable do
    def into(original) do
      {original, fn
        vector, {:cont, value} -> Vector.put(vector, Vector.count(vector) + 1, value)
        vector, :done -> vector
        _, :halt -> :ok
      end}
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(set, opts) do
      concat(["#Vector<", Inspect.List.inspect(Vector.to_list(set), opts), ">"])
    end
  end
end