defmodule Day1 do

  @doc """
      iex> Day1.fuel(12)
      2

      iex> Day1.fuel(14)
      2

      iex> Day1.fuel(1969)
      654

      iex> Day1.fuel(100756)
      33583
  """

  def fuel(mass) do
    Kernel.trunc(mass / 3) - 2
  end

  @doc """
  iex> Day1.parse(\"""
  ...>12
  ...>21
  ...>\""")
  [12, 21]
  """

  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&String.to_integer(&1))
  end

  @doc """
  iex> Day1.total_fuel(14)
  2

  iex> Day1.total_fuel(1969)
  966

  iex> Day1.total_fuel(100756)
  50346
  """
  def total_fuel(mass) do
    a = fuel(mass) |> IO.inspect()
    if a > 0 do
      a + total_fuel(a)
    else
      0
    end
  end
end
