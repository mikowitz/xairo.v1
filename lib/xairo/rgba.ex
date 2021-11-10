defmodule Xairo.RGBA do
  @moduledoc """
  Models a color in RGBA colorspace, all values floats in [0, 1]
  """

  defstruct [:red, :green, :blue, :alpha]

  def new(red, green, blue, alpha \\ 1.0) do
    %__MODULE__{
      red: normalize(red),
      green: normalize(green),
      blue: normalize(blue),
      alpha: normalize(alpha)
    }
  end

  defp normalize(n) when n <= 1, do: n * 1.0

  defp normalize(n) when n > 1 do
    Float.round(n / 255, 2)
  end
end
