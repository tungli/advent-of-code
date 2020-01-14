defmodule Day4 do

  @doc """
  iex> Day4.is_valid?(111111)
  true

  iex> Day4.is_valid?(223450)
  false

  iex> Day4.is_valid?(123789)
  false
  """
  def is_valid?(n, range \\ 100000..999999) do
    if n < range.first || n > range.last do
      false
    else
      digits = String.codepoints(Integer.to_string(n)) |> Enum.map(&String.to_integer/1)
      Enum.all?([
        fn l -> length(Enum.dedup(l)) != length(l) end,
        fn l -> Enum.sort(l) == l end
      ], fn f -> f.(digits) end)
    end
  end

  @doc """
  iex> Day4.is_valid2?(112233)
  true

  iex> Day4.is_valid2?(123444)
  false

  iex> Day4.is_valid2?(111122)
  true
  """
  def is_valid2?(n, range \\ 100000..999999) do
    if n < range.first || n > range.last do
      false
    else
      digits = String.codepoints(Integer.to_string(n)) |> Enum.map(&String.to_integer/1)
      Enum.all?([
        fn l -> Map.values(countmap(l)) |> Enum.any?(&(&1 == 2)) end,
        fn l -> Enum.sort(l) == l end
      ], fn f -> f.(digits) end)
    end
  end

  def count_valid(range) do
    length(Enum.filter(range, fn x -> is_valid?(x) end))
  end

  def count_valid2(range) do
    length(Enum.filter(range, fn x -> is_valid2?(x) end))
  end

  @doc """
  iex> Day4.countmap([1, 2, 2, 3, 3, 2])
  %{1 => 1, 2 => 3, 3 => 2}

  """
  def countmap(enumerable) do
    Enum.reduce(enumerable, %{}, fn x, acc -> 
      Map.update(acc, x, 1, fn count -> count + 1 end) end)
  end
end
