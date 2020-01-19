defmodule Day8 do

  def part_two(seq) do
    image = parse(seq) |> shape(25, 6, nil)
    dict = %{1 => "█", 0 => " "}
    for row <- transpose(merge_layers(image)) do
      Enum.map(row, fn x -> dict[x] end)
      |> IO.puts()
    end
  end


  @doc """
  iex> Day8.transpose([[1, 2], [3, 4]])
  [[1, 3], [2, 4]]
  """
  def transpose(matrix) do
    for j <- 0..length(Enum.at(matrix, 0)) - 1 do
      for i <- 0..length(matrix) - 1 do
        Enum.at(Enum.at(matrix, i), j) 
      end
    end
  end

  @doc """
  iex> Day8.parse("0222112222120000") |> Day8.shape(2, 2, nil)
  ...> |> Day8.merge_layers()
  [[0, 1], [1, 0]]
  """
  def merge_layers(image) do
    for i <- 0..length(Enum.at(Enum.at(image, 0), 0)) - 1 do
      for j <- 0..length(Enum.at(image, 0)) - 1 do
        Enum.reduce_while(image, 0, fn x, _acc -> 
          pixel = get_in(x, [Access.at(j), Access.at(i)])
          if pixel < 2 do
            {:halt, pixel}
          else
            {:cont, 0}
          end
        end)
      end
    end
  end

  def part_one(seq) do
    image = Day8.shape(Day8.parse(seq), 25, 6, nil)
    i = find_layer_with_fewest_0(image)

    Enum.at(image, i)
    |> (fn layer -> count_digit(layer, 1) * count_digit(layer, 2) end).()
  end

  def count_digit(layer, digit) do
    List.flatten(layer)
    |> Enum.count(&(digit == &1))
  end


  @doc """
  iex> Day8.find_layer_with_fewest_0(Day8.shape(Day8.parse("001056709012"), 3, 2, nil))
  1
  """
  def find_layer_with_fewest_0(image) do
    image
    |> Enum.map(fn layer -> count_digit(layer, 0) end)
    |> Enum.with_index()
    |> Enum.sort_by(fn {count, _i} -> count end)
    |> hd()
    |> elem(1)
  end
  
  @doc """
  iex> Day8.shape(Day8.parse("123456789012"), 3, 2, nil)
  [[[1,2,3], [4,5,6]], [[7,8,9], [0,1,2]]]
  """
  def shape(seq, nil, x, y), do: shape(seq, div(div(length(seq), x), y), x, y)
  def shape(seq, x, nil, y), do: shape(seq, x, div(div(length(seq), x), y), y)
  def shape(seq, x, y, nil), do: shape(seq, x, y, div(div(length(seq), x), y))
  def shape(seq, width, height, _layers) do
    seq
    |> Enum.chunk_every(width)
    |> Enum.chunk_every(height)
  end 

  @doc """
  iex> Day8.parse("1231")
  [1, 2, 3, 1]
  """
  def parse(input) do
    String.codepoints(input)
    |> Enum.map(&String.to_integer(&1))
  end
end
