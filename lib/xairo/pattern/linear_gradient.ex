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

  defstruct [:start_point, :stop_point, :color_stops]

  @type t :: %__MODULE__{
          start_point: Point.t(),
          stop_point: Point.t(),
          color_stops: [Xairo.Pattern.color_stop()]
        }

  @doc """
  Creates a new `t:Xairo.Pattern.LinearGradient.t/0`

  Takes two required arguments representing the start and stop ends of the gradient,
  either `t:Xairo.Point.t/0` structs or coordinate tuple pairs. A third, optional
  argument adds color stops along the gradient path. These can be added later on
  by calling `add_color_stop/3`.

  A gradient with no color stops results in a completely transparent color source.

  A gradient with a single color stop set, no matter where on the
  path, will result in a solid color source

  ## Examples

  A new vertical gradient with no color stops

      iex> LinearGradient.new({0, 0}, {0, 100})
      #LinearGradient<(0.0, 0.0), (0.0, 100.0), 0>

  A diagonal gradient that starts at red and ends at blue

      iex> red = RGBA.new(1, 0, 0)
      iex> blue = RGBA.new(0, 0, 1)
      iex> LinearGradient.new({0, 0}, {100, 100}, [{red, 0}, {blue, 1}])
      #LinearGradient<(0.0, 0.0), (100.0, 100.0), 2>

  """
  @spec new(Xairo.point(), Xairo.point(), Xairo.or_nil([Xairo.Pattern.color_stop()])) ::
          __MODULE__.t()
  def new(start_point, stop_point, color_stops \\ []) do
    %__MODULE__{
      start_point: Point.from(start_point),
      stop_point: Point.from(stop_point),
      color_stops: color_stops
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
      ...> |> LinearGradient.add_color_stop(blue, 0)
      ...> |> LinearGradient.add_color_stop(red, 0.75)
      #LinearGradient<(0.0, 0.0), (100.0, 0.0), 2>

  """
  @spec add_color_stop(__MODULE__.t(), RGBA.t(), number()) :: __MODULE__.t()
  def add_color_stop(
        %__MODULE__{} = gradient,
        %RGBA{} = color,
        position
      )
      when is_number(position) do
    %__MODULE__{
      gradient
      | color_stops: [{color, position} | gradient.color_stops]
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(gradient, _opts) do
      concat([
        "#LinearGradient<",
        [
          inspect_point(gradient.start_point),
          inspect_point(gradient.stop_point),
          length(gradient.color_stops)
        ]
        |> Enum.join(", "),
        ">"
      ])
    end

    defp inspect_point(%Point{x: x, y: y}) do
      "(#{x}, #{y})"
    end
  end
end
