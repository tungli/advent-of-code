defmodule Day3 do
  @doc """
  iex> Day3.parse_wires(\"""
  ...>R8,U5
  ...>D7,L4
  ...>\""")
  [[{:r, 8}, {:u, 5}], [{:d, 7}, {:l, 4}]]
  """
  def parse_wires(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(&parse/1)
  end


  @doc """
  iex> Day3.parse("U7,R6,D4,L4")
  [{:u, 7},{:r, 6},{:d, 4},{:l, 4}]
  """
  def parse(wire) do
    String.split(wire, ",")
    |> Enum.map(
      &(case &1 do
        <<?R, n::binary>> -> {:r, String.to_integer(n)}
        <<?L, n::binary>> -> {:l, String.to_integer(n)}
        <<?U, n::binary>> -> {:u, String.to_integer(n)}
        <<?D, n::binary>> -> {:d, String.to_integer(n)}
      end))
  end

  @doc """
  iex> Day3.path_to_vectors([{:u, 7},{:r, 6},{:d, 4},{:l, 4}])
  [{0, 7}, {6, 0}, {0, -4}, {-4, 0}]
  """
  def path_to_vectors(path) do
    Enum.map(path,
      fn {dir, n} -> 
        case dir do
          :r -> {n, 0}
          :l -> {-n, 0}
          :u -> {0, n}
          :d -> {0, -n}
        end
      end)
  end

  @doc """
  iex> Day3.expand_path([{:u, 2}, {:l, 1}])
  [{:u, 1}, {:u, 1}, {:l, 1}]
  """
  def expand_path(path) do
    Enum.flat_map(path,
      fn {dir, n} -> 
        Enum.take(Stream.repeatedly(fn () -> 1 end), n)
        |> Enum.map(fn x -> {dir, x} end) end)
  end

  @doc """
  iex> Day3.trajectory([{:u, 3}, {:r, 2}])
  [{0, 3}, {2, 3}]
  """
  def trajectory(path) do
    path_to_vectors(path)
    |> Enum.map_reduce({0, 0}, fn({dx, dy},{x, y}) ->
      {{x + dx, y + dy}, {x + dx, y + dy}} end)
    |> elem(0)
  end

  @doc """
  iex> Day3.every_point_of_path([{:u, 2}, {:l, 1}])
  [{0, 1}, {0, 2}, {-1, 2}]
  """
  def every_point_of_path(path) do
    path
    |> expand_path()
    |> trajectory()
  end

  @doc """
  iex> Day3.intersections("R8,U5,L5,D3\\nU7,R6,D4,L4") |> Enum.sort()
  [{3, 3}, {6, 5}]
  """
  def intersections(wires) do
    [s1, s2] = parse_wires(wires)
    |> Enum.map(&every_point_of_path/1)
    |> Enum.map(&MapSet.new/1)
    MapSet.intersection(s1, s2)
  end

  def distance({x, y}), do: abs(x) + abs(y)

  @doc """
  iex> Day3.closest_intersection("R8,U5,L5,D3\\nU7,R6,D4,L4")
  {3, 3}

  iex> Day3.distance(Day3.closest_intersection("R75,D30,R83,U83,L12,D49,R71,U7,L72\\nU62,R66,U55,R34,D71,R55,D58,R83"))
  159

  iex> Day3.distance(Day3.closest_intersection("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51\\nU98,R91,D20,R16,D67,R40,U7,R15,U6,R7"))
  135
  """
  def closest_intersection(wires) do
    intersections(wires) |> Enum.sort(&(distance(&1) <= distance(&2))) |> hd
  end

  def steps_to(traj, point), do: Enum.find_index(traj, fn x -> x == point end) + 1

  def fewest_steps(wires) do
    [t1, t2] = wires |> parse_wires() |> Enum.map(&every_point_of_path/1)
    tot_steps = for i <- intersections(wires) do
      steps_to(t1, i) + steps_to(t2, i)
    end
    hd(Enum.sort(tot_steps))
  end
end
