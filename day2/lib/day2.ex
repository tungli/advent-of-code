defmodule Day2 do
  def solve(input, in1 \\ 12, in2 \\ 2) do
    seq = input |> String.split(",") |> Enum.map(&String.to_integer(&1))
          |> List.update_at(1, fn _ -> in1 end) 
          |> List.update_at(2, fn _ -> in2 end)
    run(seq) |> Enum.at(0)
  end

  def solve2(input) do
    product = List.flatten(
      for a <- 0..99 do
        for b <- 0..99 do
          {a, b}
        end
      end
    )
    l = length(Enum.take_while(product, fn {x,y} -> solve(input, x, y) != 19690720 end))
    {noun, verb} = Enum.at(product, l) |> IO.inspect()
    noun*100 + verb
  end
      


  @doc """
  iex> Day2.run([1,0,0,0,99])
  [2,0,0,0,99]

  iex> Day2.run([2,3,0,3,99])
  [2,3,0,6,99]

  iex> Day2.run([2,4,4,5,99,0])
  [2,4,4,5,99,9801]

  iex> Day2.run([1,1,1,4,99,5,6,0,99])
  [30,1,1,4,2,5,6,0,99]
  """
  def run(seq) do run(seq, 0) end

  def run(seq, pos) do
    case Enum.at(seq, pos) do
      1 -> run(
          List.update_at(
            seq,
            Enum.at(seq, pos + 3),
            fn _ -> sum(inputs(seq, pos)) end), pos + 4)
      2 -> run(
          List.update_at(
            seq,
            Enum.at(seq, pos + 3),
            fn _ -> mul(inputs(seq, pos)) end), pos + 4)
      99 -> seq 
      x -> {:err, seq, x}
    end
  end

  defp inputs(seq, pos) do
    i1 = Enum.at(seq, pos + 1)
    i2 = Enum.at(seq, pos + 2)
    {Enum.at(seq, i1), Enum.at(seq, i2)}
  end

  defp sum({a, b}) do
    a + b
  end

  defp mul({a, b}) do
    a * b
  end
    
end
