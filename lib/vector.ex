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
  @type t :: %__MODULE__{array: :array.array()}
  @type index :: integer
  @type value :: term

  @behaviour Access

  defstruct array: :array.new()

  @doc """
  Constructs a array-backed vector

  ## Examples

      iex> Vector.new()
      #Vector<[]>

      iex> Vector.new(Vector.new())
      #Vector<[]>
  """
  def new(), do: %__MODULE__{}
  def new(%__MODULE__{} = vector), do: vector
  @doc """
  Constructs an array-backed vector from an enumerable

  ## Examples

      iex> Vector.new([1,2,3])
      #Vector<[1, 2, 3]>

      iex> Vector.new(%{a: 1, b: 2})
      #Vector<[a: 1, b: 2]>
  """
  def new(enumerable) do
    array =
      enumerable
      |> Enum.to_list
      |> do_new

    %Vector{array: array}
  end

  defp do_new(list) when is_list(list) do
    :array.from_list(list)
  end

  @doc """
  Converts a `vector` to a list

  ## Examples

      iex> Vector.to_list(Vector.new([1,2,3]))
      [1,2,3]
  """
  def to_list(%Vector{array: array}) do
    :array.sparse_to_list(array)
  end

  @doc """
  Returns the size of a vector

  ## Examples

      iex> Vector.size(Vector.new())
      0

      iex> Vector.size(Vector.new([1,2,3,4,5]))
      5
  """
  def size(%Vector{array: array}) do
    :array.sparse_size(array)
  end

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
  """
  def fetch(%Vector{} = vector, index) when index < 0 do
    fetch(vector, Vector.size(vector) + index)
  end
  @spec fetch(t, index) :: {:ok, value} | :error
  def fetch(%Vector{array: array}, index) do
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
  """
  @spec put(t, index, value) :: t
  def put(%Vector{} = vector, index, value) when index < 0 do
    put(vector, Vector.size(vector) + index, value)
  end
  def put(%Vector{array: array}, index, value) do
    %Vector{array: :array.set(index, value, array)}
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

  If index is present in map with value value, fun is invoked with argument value
  and its result is used as the new value of index. If index is not present in map,
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
  def delete(%Vector{array: array} = _vector, index) do
    %Vector{array: :array.reset(index, array)}
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

  defimpl Enumerable do
    def count(vector), do: {:ok, Vector.size(vector)}
    def member?(vector, val), do: {:ok, Vector.member?(vector, val)}
    def reduce(vector, acc, fun), do: Enumerable.List.reduce(Vector.to_list(vector), acc, fun)
  end

  defimpl Collectable do
    def into(original) do
      {original, fn
        vector, {:cont, value} -> Vector.put(vector, Vector.size(vector) + 1, value)
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