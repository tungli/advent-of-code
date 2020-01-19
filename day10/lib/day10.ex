defmodule Day10 do
  @moduledoc """
  y = m x - n
  m = (y1 - y2)/(x1 - x2)
  n = (y2 x1 - y1 x2)/(x1 - x2)
  """

  alias Rational
  alias :math, as: Math

  def part_one(input) do
    chart = parse(input)

    asteroid_positions(chart)
    |> Enum.map(fn ij -> n_seen(chart, ij) end)
    |> Enum.reduce(0, fn x, acc -> max(x, acc) end)
  end

  def part_one_where(input) do
    chart = parse(input)

    asteroid_positions(chart)
    |> Enum.map(fn ij -> {ij, n_seen(chart, ij)} end)
    |> Enum.reduce({nil, 0}, fn {ij, x}, {old_ij, acc} -> if acc < x do {ij, x} else {old_ij, acc} end end)
  end
  
  @doc """
  iex> Day10.parse(
  ...>\"""
  ...>.#..#
  ...>.....
  ...>#####
  ...>....#
  ...>...##
  ...>\""") |> Day10.n_seen({3, 4})
  8

  iex> Day10.parse(
  ...>\"""
  ...>.#..#
  ...>.....
  ...>#####
  ...>....#
  ...>...##
  ...>\""") |> Day10.n_seen({4, 2})
  5
  """
  def n_seen(chart, from) do
    length(seen(chart, from))
  end

  def seen(chart, _from = {x0, y0}) do
    positions = asteroid_positions(chart) 
                |> Enum.map(fn {x, y} -> {x - x0, y - y0} end)

    seen(Enum.filter(positions, fn {_x, y} -> y > 0 end)) ++ # count lower plane
    seen(Enum.filter(positions, fn {_x, y} -> y < 0 end)) ++ # count upper plane
    seen(Enum.filter(positions, fn {x, y} -> y == 0 && x > 0 end)) ++ # count zero-right
    seen(Enum.filter(positions, fn {x, y} -> y == 0 && x < 0 end))   # count zero-left
  end

  defp seen(positions) do
    positions 
    |> Enum.map(fn {x, y} -> Rational.simplify(%Rational{num: y, den: x}) end)
    |> Enum.uniq()
  end


  @doc """
  iex> Day10.parse(
  ...>\"""
  ...>.##
  ...>#..
  ...>\""") |> Day10.asteroid_positions()
  [{1, 0}, {2, 0}, {0, 1}]
  """
  def asteroid_positions(chart) do
    for {row, i} <- Enum.with_index(chart) do
      for {val, j} <- Enum.with_index(row), val == :asteroid  do
        {j, i}
      end
    end |> List.flatten()
  end

  @doc """
  iex> Day10.parse(
  ...>\"""
  ...>.#.
  ...>#..
  ...>\""")
  [[:void, :asteroid, :void], [:asteroid, :void, :void]]
  """
  def parse(input) do
    map = %{"." => :void, "#" => :asteroid}

    for line <- String.split(input, "\n", trim: true) do
      Enum.map(String.codepoints(line), fn x -> map[x] end)
    end
  end
end

