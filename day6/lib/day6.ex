defmodule Day6 do
  @doc """
  iex> Day6.parse(
  ...>\"""
  ...>COM)B
  ...>B)C
  ...>C)D
  ...>\"""
  ...>)
  [{"COM", "B"}, {"B", "C"}, {"C", "D"}]
  """
  def parse(input) do
    String.split(input, "\n", trim: true)
    |> Enum.map(fn line -> List.to_tuple(String.split(line, ")")) end)
  end

  @doc """
  iex> Day6.gen_tree([{"COM", "B"}, {"B", "C"}, {"C", "D"}])
  %{"COM" => MapSet.new(["B"]), "B" => MapSet.new(["C"]), "C" => MapSet.new(["D"])}

  iex> Day6.gen_tree([{"B", "C"}, {"COM", "B"}, {"C", "D"}])
  %{"COM" => MapSet.new(["B"]), "B" => MapSet.new(["C"]), "C" => MapSet.new(["D"])}

  iex> Day6.gen_tree([{"COM", "B"}, {"B", "C"}, {"B", "D"}])
  %{"COM" => MapSet.new(["B"]), "B" => MapSet.new(["C", "D"])}
  """
  def gen_tree(orbits) do
    tree = %{}
    Enum.reduce(orbits, tree,
      fn ({parent, child}, acc) -> Map.update(acc, parent, MapSet.new([child]),
        fn children -> MapSet.put(children, child) end) end)
  end

  @doc """
  iex> Day6.count_orbits(%{"COM" => MapSet.new(["B"]), "B" => MapSet.new(["C", "D"])})
  5

  iex> input =
  ...>\"""
  ...>COM)B
  ...>B)C
  ...>C)D
  ...>D)E
  ...>E)F
  ...>B)G
  ...>G)H
  ...>D)I
  ...>E)J
  ...>J)K
  ...>K)L
  ...>\"""
  iex> Day6.parse(input) |> Day6.gen_tree() |> Day6.count_orbits()
  42
  """
  def count_orbits(tree) do
    count_orbits(tree, "COM", 0, 1)
  end

  defp count_orbits(tree, from, count, level) do
    Map.get(tree, from, [])
    |> case do
      [] -> count
      x -> Enum.reduce(x, count, fn x, acc -> count_orbits(tree, x, acc + level, level + 1) end) 
    end
  end

  @doc """
  iex> "J)K\\nK)YOU\\nK)L" |> Day6.parse() |> Day6.gen_tree() |> Day6.reroot("YOU")
  %{"YOU" => MapSet.new(["K"]), "K" => MapSet.new(["J", "L"])}
  """
  def reroot(tree, where) do
    parents = parent_map(tree)
    reroot(tree, parents, Map.get(parents, where, nil), where)
  end

  defp reroot(tree, _parents, nil, _child) do
    clean_empty(tree)
  end

  defp reroot(tree, parents, parent, child) do
    tree 
    |> Map.update!(parent, fn x -> MapSet.delete(x, child) end) 
    |> Map.put(child, Map.get(tree, child, MapSet.new()) |> MapSet.put(parent))
    |> reroot(parents, Map.get(parents, parent, nil), parent)
  end

  def clean_empty(tree) do
    Map.new(for {k, v} <- tree, v != MapSet.new() do
        {k, v}
      end)
  end


  @doc """
  iex> input =
  ...>\"""
  ...>J)K
  ...>K)L
  ...>K)YOU
  ...>\"""
  iex> Day6.parse(input) |>  Day6.gen_tree() |> Day6.parent_map()
  %{"K" => "J", "L" => "K", "YOU" => "K"}
  """
  def parent_map(tree) do
    Map.new(Enum.flat_map(tree, fn {k, v} -> Enum.map(v, fn x -> {x, k} end) end))
  end

  @doc """
  iex> input =
  ...>\"""
  ...>COM)B
  ...>B)C
  ...>C)D
  ...>D)E
  ...>E)F
  ...>B)G
  ...>G)H
  ...>D)I
  ...>E)J
  ...>J)K
  ...>K)L
  ...>K)YOU
  ...>I)SAN
  ...>\"""
  iex> Day6.parse(input) |>  Day6.gen_tree() |> Day6.reroot("YOU") |> Day6.find_santa()
  4
  """
  def find_santa(tree) do
    find_santa(tree, "YOU", -2)
  end

  defp find_santa(_tree, "SAN", level), do: level
  defp find_santa(_tree, [], _level), do: 0

  defp find_santa(tree, from, level) do
    Map.get(tree, from, [])
    |> Enum.reduce(0, fn x, acc -> acc + find_santa(tree, x, level + 1) end)
  end

end



