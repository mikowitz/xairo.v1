defmodule Xairo.Pattern.RadialGradient do
  @moduledoc """
  Models a radial gradient that can be used as a path's color source.

  A radial gradient requires 3 pieces of data:

  - Two circles, each defined by a center coordinate and radius in imagespace,
    defining the radial along which the gradient is drawn
  - a list of pairs of {`t:Xairo.RGBA.t/0`, offset} tuples, where the offset is
    a numeric value in the range [0.0, 1.0] that defines where along the
    gradient radial this color is rendered.

  ## Example

  Defining a simple radial gradient that radiates from the center of a 100x100
  image to the outer edges, starting purple at the center and transitioning to
  blue at the outer edges.

  ```
  gradient = RadialGradient.new(
    Point.new(50, 50), 10, # starting circle, centered with a radius of 10
    Point.new(50, 50), 80  # ending circle, centered with a radius of 80
  )
  ```

  then we add the inner purple color stop

  ```
  gradient = RadialGradient.add_color_stop(
    RGBA.new(0.5, 0, 1), # color
    0                    # position along the gradient's radius (will be stored as 0.0, or 0%)
  )
  ```

  and the outer blue color stop

  ```
  gradient = RadialGradient.add_color_stop(
    RGBA.new(0, 0, 1), # color
    1                  # position along the gradient's radius (will be stored as 1.0, or 100%)
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

  defstruct [
    :first_circle,
    :second_circle,
    :color_stops
  ]

  @type radial :: {Point.t(), number()}
  @type t :: %__MODULE__{
          first_circle: radial(),
          second_circle: radial(),
          color_stops: [Xairo.Pattern.color_stop()]
        }

  @doc """
  Creates a new `t:Xairo.Pattern.RadialGradient.t/0`

  Takes four required arguments representing the

  - center of the first cirlce, a `t:Xairo.Point.t/0` or coordinate tuple pair
  - radius of the first circle, a number
  - center of the second cirlce, a `t:Xairo.Point.t/0` or coordinate tuple pair
  - radius of the second circle, a number

  A fifth, optional argument adds color stops along the gradient path. These
  can be added later on by calling `add_color_stop/3`.

  A gradient with no color stops results in a completely transparent color source.

  A gradient with a single color stop set, no matter where on the
  path, will result in a solid color source

  ## Examples

  A new gradient centered on a 100x100 image with no color stops

      iex> RadialGradient.new({50, 50}, 10, {50, 50}, 80)
      #RadialGradient<({50.0, 50.0}, 10.0), ({50.0, 50.0}, 80.0), 0>

  A gradient that starts at red in the upper left and ends at blue in the
  lower right.

      iex> red = RGBA.new(1, 0, 0)
      iex> blue = RGBA.new(0, 0, 1)
      iex> RadialGradient.new({0, 0}, 10, {0, 0}, 100, [{red, 0}, {blue, 1}])
      #RadialGradient<({0.0, 0.0}, 10.0), ({0.0, 0.0}, 100.0), 2>

  """
  @spec new(
          Xairo.point(),
          number(),
          Xairo.point(),
          number(),
          Xairo.maybe([Xairo.Pattern.color_stop()])
        ) :: __MODULE__.t()
  def new(first_center, first_radius, second_center, second_radius, color_stops \\ [])

  def new(
        %Point{} = first_center,
        first_radius,
        %Point{} = second_center,
        second_radius,
        color_stops
      ) do
    %__MODULE__{
      first_circle: {first_center, first_radius * 1.0},
      second_circle: {second_center, second_radius * 1.0},
      color_stops: color_stops
    }
  end

  def new({x1, y1}, r1, {x2, y2}, r2, color_stops) do
    with first_center <- Point.new(x1, y1),
         second_center <- Point.new(x2, y2) do
      new(first_center, r1, second_center, r2, color_stops)
    end
  end

  @doc """
  Pushes a new color stop onto the gradient's list of existing color stops.

  Takes as arguments a `t:Xairo.Pattern.RadialGradient.t/0`, an `RGBA.t/0`, and
  a number in the range [0.0, 1.0] representing the location of the color stop
  along the gradient as a decimal percentage.

  ## Example

  A new centered radial gradient with no color stops has two color stops
  set, blue at the beginning, and red at 75% of the way along the path

      iex> red = RGBA.new(1, 0, 0)
      iex> blue = RGBA.new(0, 0, 1)
      iex> RadialGradient.new({50, 50}, 10, {50, 50}, 80)
      ...> |> RadialGradient.add_color_stop(blue, 0)
      ...> |> RadialGradient.add_color_stop(red, 0.75)
      #RadialGradient<({50.0, 50.0}, 10.0), ({50.0, 50.0}, 80.0), 2>

  """
  @spec add_color_stop(__MODULE__.t(), RGBA.t(), number()) :: __MODULE__.t()
  def add_color_stop(
        %__MODULE__{} = gradient,
        %RGBA{} = color,
        position
      ) do
    %__MODULE__{
      gradient
      | color_stops: [{color, position} | gradient.color_stops]
    }
  end

  defimpl Inspect do
    def inspect(gradient, _opts) do
      [
        "#RadialGradient<",
        [
          inspect_circle(gradient.first_circle),
          inspect_circle(gradient.second_circle),
          length(gradient.color_stops)
        ]
        |> Enum.join(", "),
        ">"
      ]
      |> Enum.join("")
    end

    defp inspect_circle({point, radius}) do
      "(#{inspect_point(point)}, #{radius})"
    end

    defp inspect_point(%Point{x: x, y: y}) do
      "{#{x}, #{y}}"
    end
  end
end
