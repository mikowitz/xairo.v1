defmodule Xairo.Point do
  @moduledoc """
  Models a two-dimensional point in imagespace.

  Ensures that `x` and `y` are stored as floats to match Rust's type expectations

      iex> Point.new(1, 2)
      #Point<(1.0, 2.0)>

  """
  defstruct [:x, :y]

  @type t :: %__MODULE__{
          x: number(),
          y: number()
        }

  @doc """
  Creates a two-dimensional point positioned absolutely in imagespace.

  ## Examples

      iex> Point.new(10, 20)
      #Point<(10.0, 20.0)>
  """
  @spec new(number(), number()) :: __MODULE__.t()
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
