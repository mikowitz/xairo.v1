defmodule Xairo.Point do
  @moduledoc """
  Models a point in image space.

  Ensures that `x` and `y` are stored as floats to match Rust's type expectations

      iex> Point.new(1, 2)
      #Point<(1.0, 2.0)>

  """
  defstruct [:x, :y]

  def new(x, y) when is_number(x) and is_number(y) do
    %__MODULE__{
      x: x * 1.0,
      y: y * 1.0
    }
  end

  defimpl Inspect do
    def inspect(%Xairo.Point{x: x, y: y}, _opts) do
      [
        "#Point<(",
        [x, y] |> Enum.join(", "),
        ")>"
      ]
      |> Enum.join("")
    end
  end
end
