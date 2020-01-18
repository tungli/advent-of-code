defmodule Day7 do
  @moduledoc """
  Implemented using the Elixir's processes.
  """

  @doc """
  iex> Day7.find_max_feedback([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5])
  139629729
  """
  def find_max_feedback(seq) do
    Combination.permutate(5..9)
    |> Enum.map(fn phases -> run_feedback(seq, phases) end)
    |> Enum.reduce(&max(&1, &2))
  end

  @doc """
  iex> Day7.run_feedback([3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5], [9,8,7,6,5])
  139629729
  """
  def run_feedback(seq, phases) do
    pids = spawn_amplifiers(seq, phases) 
    feedback(pids, {:input, 0})
  end

  def feedback(pids, message) do
    send(hd(pids), message)
    out = receive do {:input, x} -> x end

    # ugly but gets the job done
    Process.sleep(1)
    if Process.alive?(Enum.at(pids, -1)) do
      feedback(pids, {:input, out})
    else
      out
    end
  end


  @doc """
  iex> Day7.find_max([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0])
  65210
  """
  def find_max(seq) do
    Combination.permutate(0..4) 
    |> Enum.map(fn phases -> hd(Day7.spawn_amplifiers(seq, phases)) end) 
    |> Enum.map(fn pid -> send(pid, {:input, 0}) end) 
    |> Enum.map(fn _x -> receive do {:input, x} -> x end end) 
    |> Enum.reduce(0, &max(&1, &2))
  end

  def spawn_amplifiers(seq, phases) do
    pids = spawn_IntComputers(seq, length(phases), 0)
    Enum.zip(pids, phases) |> Enum.map(fn {pid, ph} -> send(pid, {:input, ph}) end)
    pids
  end

  def spawn_IntComputers(seq, n, at \\ 0) do
    1..n
    |> Enum.reduce([self()], fn _x, pids -> [spawn fn -> calc(seq, at, hd(pids)) end] ++  pids end)
    |> Enum.slice(0..-2)
  end

  def calc(seq, at, output_target) do
    {info, seq} = step(at, seq)

    case info do
      {:move, f} -> calc(seq, f.(at), output_target)
      :stop -> nil
      {:output, move_f, val} -> 
        send(output_target, {:input, val})
        calc(seq, move_f.(at), output_target)
    end
  end

  @doc """
  iex> {{:move, f}, seq} = Day7.step(0, [1002,4,3,4,33])
  iex> seq
  [1002,4,3,4,99]
  iex> f.(0)
  4
  """
  def step(at, seq) do
    {opcode, params} = parse_number(Enum.at(seq, at))
    arg_access = fn () -> params 
                 |> Enum.with_index(1)
                 |> Enum.map(fn {p, i} -> mode(p).(at + i, seq) end) end
    {info, seq} = case opcode do
      1 -> sum(seq, arg_access.())
      2 -> mul(seq, arg_access.())
      99 -> {:stop, seq}
      3 -> put(seq, arg_access.())
      4 -> output(seq, arg_access.())
      5 -> jump_if_true(seq, arg_access.())
      6 -> jump_if_false(seq, arg_access.())
      7 -> less_than(seq, arg_access.())
      8 -> equals(seq, arg_access.())
    end

    {info, seq}
  end

  def jump_if_true(seq, [i1, move_to]) do
    if get_in(seq, i1) != 0 do
      {{:move, fn _pointer -> get_in(seq, move_to) end}, seq}
    else
      {{:move, &(&1 + 3)}, seq}
    end
  end

  def jump_if_false(seq, [i1, move_to]) do
    if get_in(seq, i1) == 0 do
      {{:move, fn _pointer -> get_in(seq, move_to) end}, seq}
    else
      {{:move, &(&1 + 3)}, seq}
    end
  end

  def less_than(seq, [i1, i2, o]) do
    if get_in(seq, i1) < get_in(seq, i2) do
      {{:move, &(&1 + 4)}, put_in(seq, o, 1)}
    else
      {{:move, &(&1 + 4)}, put_in(seq, o, 0)}
    end
  end

  def equals(seq, [i1, i2, o]) do
    if get_in(seq, i1) == get_in(seq, i2) do
      {{:move, &(&1 + 4)}, put_in(seq, o, 1)}
    else
      {{:move, &(&1 + 4)}, put_in(seq, o, 0)}
    end
  end

  def sum(seq, [i1, i2, o]) do
    {{:move, &(&1 + 4)}, put_in(seq, o, get_in(seq, i1) + get_in(seq, i2))}
  end

  def mul(seq, [i1, i2, o]) do
    {{:move, &(&1 + 4)}, put_in(seq, o, get_in(seq, i1) * get_in(seq, i2))}
  end

  def put(seq, [a]) do
    {{:move, &(&1 + 2)}, put_in(seq, a, 
      receive do
        {:input, input} -> input
      end)}
  end

  def output(seq, [a]) do
    {{:output, &(&1 + 2), get_in(seq, a)}, seq}
  end

  def mode(n) do
    case n do
      0 -> fn (x, seq) -> [Access.at(Enum.at(seq, x))] end
      1 -> fn (x, _seq) -> [Access.at(x)] end
    end
  end

  @doc """
  iex> Day7.parse("1101,100,-1,4,0")
  [1101, 100, -1, 4, 0]
  """
  def parse(input) do
    input |> String.split(",") |> Enum.map(&String.to_integer(&1))
  end

  @doc """
  iex> Day7.parse_number(1002)
  {2, [0, 1, 0]}

  iex> Day7.parse_number(1101)
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
