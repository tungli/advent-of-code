defmodule Rational do
  defstruct [:num, :den]

  @doc """
  iex> Rational.simplify(%Rational{num: 12, den: 2})
  %Rational{num: 6, den: 1}

  iex> Rational.simplify(%Rational{num: 27, den: 6})
  %Rational{num: 9, den: 2}

  iex> Rational.simplify(%Rational{num: 13, den: 2})
  %Rational{num: 13, den: 2}

  iex> Rational.simplify(%Rational{num: 8, den: 12})
  %Rational{num: 2, den: 3}
  """
  def simplify(%Rational{num: 0, den: 0}) do
    raise ArithmeticError, message: "0//0 is undefined"
  end

  def simplify(%Rational{num: 0, den: _den}) do
    %Rational{num: 0, den: 1}
  end

  def simplify(%Rational{num: num, den: 0}) do
    if num > 0 do %Rational{num: 1 , den: 0} else %Rational{num: -1 , den: 0} end
  end

  def simplify(%Rational{num: num, den: den}) do
    sign = if num * den > 0 do 1 else -1 end
    factor_den = factor(abs(den))
    factor_num = factor(abs(num))
    new_num = factor_num -- factor_den
    new_den = factor_den -- factor_num
    %Rational{
      num: Enum.reduce(new_num, sign, &*/2),
      den: Enum.reduce(new_den, 1, &*/2)
    }
  end


  @doc """
  iex> Rational.factor(11241)
  [3, 3, 1249]
  """
  def factor(0) do [0] end

  def factor(n) do
    Enum.reverse(factor(n, 2, []))
  end


  defp factor(1, _trial, acc) do
    acc
  end

  defp factor(n, trial, acc) when rem(n, trial) == 0 do
    factor(div(n, trial), trial, [trial | acc])
  end

  defp factor(n, trial, acc) do
    factor(n, trial + 1, acc)
  end

end

