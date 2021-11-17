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

  @doc """
  Returns a Point, if possible, from the arguments.

  Argument can be any of

  - a `t:Xairo.Point.t/0` struct
  - a 2-element numeric tuple
  - two numeric arguments

  ## Examples

    iex> Point.from(Point.new(1, 2))
    #Point<(1.0, 2.0)>

    iex> Point.from({3, 4})
    #Point<(3.0, 4.0)>

    iex> Point.from(5, 6)
    #Point<(5.0, 6.0)>

  """
  @spec from(__MODULE__.t()) :: __MODULE__.t()
  @spec from({number(), number()}) :: __MODULE__.t()
  @spec from(number(), number()) :: __MODULE__.t()
  def from(%__MODULE__{} = point), do: point

  def from({x, y}) when is_number(x) and is_number(y) do
    __MODULE__.new(x, y)
  end

  def from(x, y) when is_number(x) and is_number(y) do
    __MODULE__.new(x, y)
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Xairo.Point{x: x, y: y}, _opts) do
      concat([
        "#Point<(",
        [x, y] |> Enum.join(", "),
        ")>"
      ])
    end
  end
end
