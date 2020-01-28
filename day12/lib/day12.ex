defmodule Day12 do
  @pairs Combination.combine(0..3, 2)

  def init_vs() do
    Tuple.duplicate([0,0,0], 4)
  end

  @doc """
  iex> Day12.parse(
  ...> \"""
  ...> <x=-1, y=0, z=2>
  ...> <x=2, y=-10, z=-7>
  ...> \""")
  {[-1, 0, 2], [2, -10, -7]}
  """
  def parse(input) do
    for line <- String.split(input, "\n", trim: true) do
      tl(Regex.run(~r{<x=(-?\d+), y=(-?\d+), z=(-?\d+)>}, line))
      |> Enum.map(&String.to_integer/1)
    end |> List.to_tuple()
  end

  @doc """
  iex> import Day12
  iex> 3 <~> 4
  {1, -1}
  """
  def a <~> b do
    if a == b do
      {0, 0}
    else
      if a > b do
        {-1, 1}
      else
        {1, -1}
      end
    end
  end

  @doc """
  iex> rs0 = Day12.parse(
  ...> \"""
  ...> <x=-1, y=0, z=2>
  ...> <x=2, y=-10, z=-7>
  ...> <x=4, y=-8, z=8>
  ...> <x=3, y=5, z=-1>
  ...> \""")
  iex> {rs, vs} = Day12.step(rs0, Day12.init_vs())
  iex> Day12.output_state(rs, vs)
  "pos=<x=2, y=-1, z=1>, vel=<x=3, y=-1, z=-1>\npos=<x=3, y=-7, z=-4>, vel=<x=1, y=3, z=3>\npos=<x=1, y=-7, z=5>, vel=<x=-3, y=1, z=-3>\npos=<x=2, y=2, z=0>, vel=<x=-1, y=-3, z=1>"
  """
  def step(rs, vs) do
    dvs = gen_dv(rs)
    vs = update_vs(vs, dvs)
    rs = apply_vs(rs, vs)
    {rs, vs}
  end

  @doc """
  iex> Day12.energy([1,-2,1])
  1 + 2 + 1
  """
  def energy(vec) do
    Enum.reduce(vec, 0, fn x, acc -> acc + abs(x) end)
  end

  @doc """
  iex> Day12.total_energy({[1,0,0], [0,-2,1]}, {[1,0,0], [0,-1,1]})
  1 + 6
  """
  def total_energy(rs, vs) do
    Enum.zip(Tuple.to_list(rs), Tuple.to_list(vs))
    |> Enum.map(fn {x, v} -> energy(x) * energy(v) end)
    |> Enum.reduce(0, fn x, acc -> acc + x end)
  end

  @doc """
  iex> Day12.apply_vs({[0,0,0]}, {[1, -1, 3]})
  {[1, -1, 3]}
  """
  def apply_vs(rs, vs) do
    Enum.zip(Tuple.to_list(rs), Tuple.to_list(vs))
    |> Enum.map(fn {r, v} ->
      Enum.zip(r, v) |> Enum.map(fn {a, b} -> a + b end)
    end) |> List.to_tuple()
  end

  @doc """
  iex> Day12.output_state({[-1, 0, 2]}, {[0, 0, 0]})
  "pos=<x=-1, y=0, z=2>, vel=<x=0, y=0, z=0>"

  iex> Day12.output_state({[-1, 0, 2], [-1, 0, 2]}, {[0, 0, 0], [0, 0, 0]})
  "pos=<x=-1, y=0, z=2>, vel=<x=0, y=0, z=0>\npos=<x=-1, y=0, z=2>, vel=<x=0, y=0, z=0>"
  """
  def output_state(rs, vs) do
    Enum.zip(Tuple.to_list(rs), Tuple.to_list(vs))
    |> Enum.map(fn {r, v} -> 
      [x,y,z,vx,vy,vz] = Enum.map(List.flatten([r, v]), &Integer.to_string/1)
      "pos=<x=#{x}, y=#{y}, z=#{z}>, vel=<x=#{vx}, y=#{vy}, z=#{vz}>"
    end) |> Enum.join("\n")
  end

  def update_vs(vs, dvs) do 
    Enum.zip(@pairs, dvs)
    |> Enum.reduce(vs, fn {ij, dv}, vs -> 
        Enum.reduce(Enum.zip(ij, Tuple.to_list(dv)), vs, 
          fn {i, d}, vs -> update_in(vs, [Access.elem(i)],
            fn v -> Enum.zip(v, d) |> Enum.map(fn {a, b} -> a + b end)
            end) end) end)
  end

  def gen_dv(rs) do
    pair_up(rs)
    |> Enum.map(fn [r1, r2] ->
      Enum.zip(r1, r2) |> Enum.map(fn {x1, x2} -> x1 <~> x2 end) |> Enum.unzip()
    end)
  end


  def pair_up(vecs) do
    @pairs
    |> Enum.map(fn [i, j] -> [elem(vecs, i), elem(vecs,j)] end)
  end



end
