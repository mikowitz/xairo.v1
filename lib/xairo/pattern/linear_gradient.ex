defmodule Xairo.Pattern.LinearGradient do
  @moduledoc """
  Models a linear gradient that can be used as a path's color source.

  A linear gradient requires 3 pieces of data:

  - two `t:Xairo.Point.t/0` instances that define the line along which the
  gradient is drawn
  - a list of pairs of {`t:Xairo.RGBA.t/0`, offset} tuples, where the offset is
    a numeric value in the range [0.0, 1.0] that defines where along the gradient line this
    color is rendered.

  ## Example

  Let's define a simple gradient that runs from the top of an image to the bottom,
  and transitions from red at the top to blue at the bottom.

  First, we define the gradient with its start and stop points

  ```
  gradient = LinearGradient.new(
    Point.new(0, 0),  # starting point
    Point.new(0, 100) # stopping point
  )
  ```

  then we add a color stop at the beginning of the line with the color red

  ```
  gradient = LinearGradient.add_color_stop(
    RGBA.new(255, 0, 0), # color
    0                    # position along the gradient's line (will be stored as 0.0, or 0%)
  )
  ```

  and a color stop at the end of the line with the color blue

  ```
  gradient = LinearGradient.add_color_stop(
    RGBA.new(0, 0, 255), # color
    1                    # position along the gradient's line (will be stored as 1.0, or 100%)
  )
  ```

  Then we can use that gradient as the color source via

  ```
  Xairo.set_color_source(image, gradient)
  ```

  and any subsequent paths drawn will pull their color at every point
  from that gradient.

  A gradient with no color stops results in a completely transparent
  color source, and a gradient with a single color stop set, no matter
  where on the path, will result in a solid color source, similar
  to passing that color to `Xairo.set_color/2`.
  """

  alias Xairo.{Point, RGBA}

  defstruct [:pattern]

  @type t :: %__MODULE__{
          pattern: reference()
        }

  @doc """
  Creates a new `t:Xairo.Pattern.LinearGradient.t/0`

  Takes two required arguments representing the start and stop ends of the gradient,
  either `t:Xairo.Point.t/0` structs or coordinate tuple pairs.

  A gradient with no color stops results in a completely transparent color source.

  A gradient with a single color stop set, no matter where on the
  path, will result in a solid color source

  """
  @spec new(Xairo.point(), Xairo.point()) :: __MODULE__.t()
  def new(start_point, stop_point) do
    %__MODULE__{
      pattern:
        Xairo.Native.linear_gradient_new(
          Point.from(start_point),
          Point.from(stop_point)
        )
    }
  end

  @doc """
  Pushes a new color stop onto the gradient's list of existing color stops.

  Takes as arguments a `t:Xairo.Pattern.LinearGradient.t/0`, an `RGBA.t/0`, and
  a number in the range [0.0, 1.0] representing the location of the color stop
  along the gradient as a decimal percentage.

  ## Example

  A new horizontal gradient with no color stops has two color stops
  set, blue at the beginning, and red at 75% of the way along the path

      iex> red = RGBA.new(1, 0, 0)
      iex> blue = RGBA.new(0, 0, 1)
      iex> LinearGradient.new({0, 0}, {100, 0})
      ...> |> LinearGradient.add_color_stop(0, blue)
      ...> |> LinearGradient.add_color_stop(0.75, red)

  """
  @spec add_color_stop(__MODULE__.t(), number(), RGBA.t()) :: __MODULE__.t()
  def add_color_stop(%__MODULE__{} = gradient, offset, %RGBA{} = color) do
    Xairo.Native.linear_gradient_add_color_stop(gradient.pattern, offset / 1, color)
    gradient
  end

  @doc """
    Returns the number of color stops set for the gradient.
  """
  @spec color_stop_count(__MODULE__.t()) :: integer() | Xairo.error()
  def color_stop_count(%__MODULE__{} = gradient) do
    with {:ok, count} <- Xairo.Native.linear_gradient_color_stop_count(gradient.pattern),
         do: count
  end

  @doc """
    Returns the color stop for the gradient at the given index.

    If no color stop exists at the given index, returns an error.
  """
  @spec color_stop(__MODULE__.t(), integer) :: RGBA.t() | Xairo.error()
  def color_stop(%__MODULE__{} = gradient, index) do
    with {:ok, color} <- Xairo.Native.linear_gradient_color_stop(gradient.pattern, index),
         do: color
  end

  @doc """
    Returns the start and stop points for the gradient.
  """
  @spec linear_points(__MODULE__.t()) :: {Point.t(), Point.t()} | Xairo.error()
  def linear_points(%__MODULE__{} = gradient) do
    with {:ok, points} <- Xairo.Native.linear_gradient_linear_points(gradient.pattern),
         do: points
  end
end
