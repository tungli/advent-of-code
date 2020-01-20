defmodule Day10 do
  @moduledoc """
  y = m x - n
  m = (y1 - y2)/(x1 - x2)
  n = (y2 x1 - y1 x2)/(x1 - x2)
  """

  alias :math, as: Math


  def part_two(input) do
    chart = parse(input)
    {best_position = {x_best, y_best}, _c} = part_one_where(input)
    visible = seen(chart, best_position)

    Enum.sort_by(visible, fn {x, y} -> Math.atan2(x, y) end)
    |> Enum.reverse()
    |> Enum.map(fn {x,y} -> {x + x_best, y + y_best} end)
    |> Enum.at(199)
  end


  @doc """
  iex> chart = Day10.parse(
  ...>\"""
  ...>.#..#
  ...>.....
  ...>#####
  ...>....#
  ...>...##
  ...>\""")
  iex> MapSet.new(Day10.seen(chart, {0, 0}))
  MapSet.new([{1, 0}, {0, 2}, {1, 2}, {2, 2}, {3, 2}, {4, 2}, {4, 3}, {3, 4}])
  """
  def seen(chart, _from = {x0, y0}) do
    shifted = asteroid_positions(chart)
    |> Enum.map(fn {i, j} -> {i - x0, j - y0} end)

    (shifted -- [{0,0}])
    |> Enum.sort_by(fn {i, j} -> i*i + j*j end)
    |> Enum.uniq_by(fn {i, j} -> Math.atan2(j, i) end)
  end

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

