defmodule Day5 do


  @doc """
  iex> Day5.run(0, [1002,4,3,4,33])
  [1002,4,3,4,99]
  """
  def run(at, seq) do
    IO.inspect(seq)
    {opcode, params} = parse_number(Enum.at(seq, at))
    arg_access = fn () -> params 
                 |> Enum.with_index(1)
                 |> Enum.map(fn {p, i} -> mode(p).(at + i, seq) end) end
    {move, seq} = case opcode do
      1 -> sum(seq, arg_access.())
      2 -> mul(seq, arg_access.())
      99 -> {:stop, seq}
      3 -> put(IO.gets("input\n"), seq, arg_access.())
      4 -> output(seq, arg_access.())
      5 -> jump_if_true(seq, arg_access.())
      6 -> jump_if_false(seq, arg_access.())
      7 -> less_than(seq, arg_access.())
      8 -> equals(seq, arg_access.())
    end

    if move == :stop do
      seq
    else
      run(move.(at), seq)
    end
  end

  def jump_if_true(seq, [i1, move_to]) do
    if get_in(seq, i1) != 0 do
      {fn _pointer -> get_in(seq, move_to) end, seq}
    else
      {&(&1 + 3), seq}
    end
  end

  def jump_if_false(seq, [i1, move_to]) do
    if get_in(seq, i1) == 0 do
      {fn _pointer -> get_in(seq, move_to) end, seq}
    else
      {&(&1 + 3), seq}
    end
  end

  def less_than(seq, [i1, i2, o]) do
    if get_in(seq, i1) < get_in(seq, i2) do
      {&(&1 + 4), put_in(seq, o, 1)}
    else
      {&(&1 + 4), put_in(seq, o, 0)}
    end
  end

  def equals(seq, [i1, i2, o]) do
    if get_in(seq, i1) == get_in(seq, i2) do
      {&(&1 + 4), put_in(seq, o, 1)}
    else
      {&(&1 + 4), put_in(seq, o, 0)}
    end
  end

  def sum(seq, [i1, i2, o]) do
    {&(&1 + 4), put_in(seq, o, get_in(seq, i1) + get_in(seq, i2))}
  end

  def mul(seq, [i1, i2, o]) do
    {&(&1 + 4), put_in(seq, o, get_in(seq, i1) * get_in(seq, i2))}
  end

  def put(input, seq, [a]) do
    {&(&1 + 2), put_in(seq, a, String.to_integer(String.trim(input, "\n")))}
  end

  def output(seq, [a]) do
    IO.puts(get_in(seq, a))
    {&(&1 + 2), seq}
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

    parameters = Enum.map(list, &String.to_integer/1)

    parameters = case opcode do
      1 -> Enum.slice(parameters, -5..-3)
      2 -> Enum.slice(parameters, -5..-3)
      3 -> Enum.slice(parameters, -3..-3)
      4 -> Enum.slice(parameters, -3..-3)
      5 -> Enum.slice(parameters, -4..-3)
      6 -> Enum.slice(parameters, -4..-3)
      7 -> Enum.slice(parameters, -5..-3)
      8 -> Enum.slice(parameters, -5..-3)
      99 -> []
    end
    {opcode, Enum.reverse(parameters)}
  end
end
