defmodule Day5 do
  

  @doc """
  iex> Day5.run(0, [1002,4,3,4,33])
  [1002,4,3,4,99]
  """
  def run(at, seq) do
    {opcode, params} = parse_number(Enum.at(seq, at))
    arg_access = fn () -> params 
                 |> Enum.with_index(1)
                 |> Enum.map(fn {p, i} -> mode(p).(at + i, seq) end) end
    {move, seq} = case opcode do
      1 -> {4, sum(seq, arg_access.())}
      2 -> {4, mul(seq, arg_access.())}
      99 -> {:stop, seq}
      3 -> {2, put(IO.gets("input\n"), seq, arg_access.())}
      4 -> {2, output(seq, arg_access.())}
    end

    if move == :stop do
      seq
    else
      run(at + move, seq)
    end
  end

  def sum(seq, [i1, i2, o]) do
    put_in(seq, o, get_in(seq, i1) + get_in(seq, i2))
  end

  def mul(seq, [i1, i2, o]) do
    put_in(seq, o, get_in(seq, i1) * get_in(seq, i2))
  end

  def put(input, seq, [a]) do
    put_in(seq, a, String.to_integer(String.trim(input, "\n")))
  end

  def output(seq, [a]) do
    IO.puts(get_in(seq, a))
    seq
  end

  def mode(n) do
    case n do
      0 -> fn (x, seq) -> [Access.at(Enum.at(seq, x))] end
      1 -> fn (x, _seq) -> [Access.at(x)] end
    end
  end

  @doc """
  iex> Day5.parse("1101,100,-1,4,0")
  [1101, 100, -1, 4, 0]
  """
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer(&1))
  end

  @doc """
  iex> Day5.parse_number(1002)
  {2, [0, 1, 0]}

  iex> Day5.parse_number(1101)
  {1, [1, 1, 0]}
  """
  def parse_number(n) do
    list = Integer.to_string(n)
           |> String.pad_leading(5, "0")
           |> String.codepoints()

    opcode = Enum.slice(list, -2..-1)  
             |> Enum.reduce("", fn x, acc -> acc <> x end)
             |> String.to_integer()

    parameters = Enum.slice(list, 0..-3)
                 |> Enum.map(&String.to_integer/1)

    parameters = if opcode == 3 || opcode == 4 do
      parameters
      |> Enum.slice(-3..-3)
    else
      parameters
    end
    {opcode, Enum.reverse(parameters)}
  end
end
