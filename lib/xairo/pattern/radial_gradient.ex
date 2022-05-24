defmodule Xairo.Pattern.RadialGradient do
  @moduledoc """
  Models a radial gradient that can be used as a path's color source.

  A radial gradient requires 3 pieces of data:

  - Two circles, each defined by a center coordinate and radius in userspace,
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
    0,                   # position along the gradient's radius (will be stored as 0.0, or 0%)
    RGBA.new(0.5, 0, 1), # color
  )
  ```

  and the outer blue color stop

  ```
  gradient = RadialGradient.add_color_stop(
    1,                # position along the gradient's radius (will be stored as 1.0, or 100%)
    RGBA.new(0, 0, 1) # color
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

  @type radial_circle :: {Point.t(), number()}
  @type t :: %__MODULE__{
          pattern: reference()
        }

  @doc """
  Creates a new `t:Xairo.Pattern.RadialGradient.t/0`

  Takes four required arguments representing the

  - center of the first cirlce, a `t:Xairo.Point.t/0` or coordinate tuple pair
  - radius of the first circle, a number
  - center of the second cirlce, a `t:Xairo.Point.t/0` or coordinate tuple pair
  - radius of the second circle, a number

  A gradient with no color stops results in a completely transparent color source.

  A gradient with a single color stop set, no matter where on the
  path, will result in a solid color source

  ## Examples

  A new gradient centered on a 100x100 image with no color stops

      iex> RadialGradient.new({50, 50}, 10, {50, 50}, 80)

  A gradient that starts at red in the upper left and ends at blue in the
  lower right.

      iex> red = RGBA.new(1, 0, 0)
      iex> blue = RGBA.new(0, 0, 1)
      iex> RadialGradient.new({0, 0}, 10, {0, 0}, 100)
      ...> |> RadialGradient.add_color_stop(0, red)
      ...> |> RadialGradient.add_color_stop(1, blue)

  """
  @spec new(
          Xairo.point(),
          number(),
          Xairo.point(),
          number()
        ) :: __MODULE__.t()

  def new(first_center, first_radius, second_center, second_radius)
      when is_number(first_radius) and is_number(second_radius) do
    %__MODULE__{
      pattern:
        Xairo.Native.radial_gradient_new(
          Point.from(first_center),
          first_radius / 1,
          Point.from(second_center),
          second_radius / 1
        )
    }
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
      ...> |> RadialGradient.add_color_stop(0, blue)
      ...> |> RadialGradient.add_color_stop(0.75, red)

  """
  @spec add_color_stop(__MODULE__.t(), number(), RGBA.t()) :: __MODULE__.t()
  def add_color_stop(
        %__MODULE__{pattern: pattern} = gradient,
        position,
        %RGBA{} = color
      ) do
    Xairo.Native.radial_gradient_add_color_stop(pattern, position / 1, color)
    gradient
  end

  @doc """
    Returns the number of color stops set for the gradient.
  """
  @spec color_stop_count(__MODULE__.t()) :: integer | Xairo.error()
  def color_stop_count(%__MODULE__{pattern: pattern}) do
    with {:ok, count} <- Xairo.Native.radial_gradient_color_stop_count(pattern),
         do: count
  end

  @doc """
    Returns the color stop for the gradient at the given index.

    If no color stop exists at the given index, returns an error.
  """
  @spec color_stop(__MODULE__.t(), integer()) :: RGBA.t() | Xairo.error()
  def color_stop(%__MODULE__{pattern: pattern}, index) do
    with {:ok, color} <- Xairo.Native.radial_gradient_color_stop(pattern, index),
         do: color
  end

  @doc """
    Returns the two radial circles that define the gradient.

    These are represented by tuples of a `Xairo.Point` struct and a radius.
  """
  @spec radial_circles(__MODULE__.t()) :: {radial_circle(), radial_circle()} | Xairo.error()
  def radial_circles(%__MODULE__{pattern: pattern}) do
    with {:ok, circles} <- Xairo.Native.radial_gradient_radial_circles(pattern),
         do: circles
  end
end
