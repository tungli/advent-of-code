defmodule Day14 do
  @doc """
  iex> Day14.parse("3 A, 4 B => 1 AB\\n8 ORE => 3 B\\n")
  [{[{"A", 3}, {"B", 4}], {"AB", 1}}, {[{"ORE", 8}], {"B", 3}}]
  """
  def parse(input) do
    for line <- String.split(input, "\n", trim: true) do
      matches = tl(Regex.run(~r{([\w, ,\d, \,]+) => (\d) (\w+)}, line))
      reactants = String.split(hd(matches), ",")
                  |> Enum.map(fn s -> 
                    String.trim(s)
                    |> String.split(" ")
                    |> case do
                      [n, s] -> {s, String.to_integer(n)}
                    end
                  end)
      n_prod = hd(tl(matches)) |> String.to_integer()
      product = hd(tl(tl(matches)))
      {reactants, {product, n_prod}}
    end
  end
end
