defmodule Xairo.Arc do
  @moduledoc """
  Models an arc that can be drawn onto an image.

  The `t:Xairo.Arc.t/0` struct stores a center coordinate and radius in absolute imagespace,
  and the start and stop angles of the arc, both defined in radians.

  When the `t:Xairo.Arc.t/0` is passed to `Xairo.arc/2` the arc is drawn clockwise from the
  start angle to the stop angle. When it is passed to `Xairo.arc_negative/2`, it
  is drawn counter-clockwise.

  ## Example

  A single arc

  ```elixir
  Arc.new(Point.new(50, 50), 10, 0, :math.pi)
  ```

  passed to both `Xairo.arc/2` and `Xairo.arc_negative/2` will result in
  drawing a complete circle

  ```elixir
  Xairo.arc(image, arc)
  |> Xairo.arc_negative(arc)
  ```
  """

  alias Xairo.Point

  defstruct [:center, :radius, :start_angle, :stop_angle]

  @type t :: %__MODULE__{
          center: Point.t(),
          radius: number(),
          start_angle: number(),
          stop_angle: number()
        }

  @doc """
  Creates a new `t:Xairo.Arc.t/0`.

  `new/4` takes as its arguments a center coordinate, as a `t:Xairo.Point.t/0`
  struct or a coordinate tuple pair, a radius, and start and stop angles, both
  given in radians.

  ## Example

  This would produce the right half of a circle with radius 10, centered around
  {20, 20} when passed to `Xairo.arc/2`

  ```elixir
  Arc.new(
    {20, 20},    # center
    10,          # radius
    -:math.pi/2, # start angle
    :math.pi/2   # stop angle
  )
  ```

  and when passed to `Xairo.arc_negative/2`, the same arc would produce the left
  half of a circle.
  """
  @spec new(Xairo.coordinate(), number(), number(), number()) :: __MODULE__.t()
  @spec new(Point.t(), number(), number(), number()) :: __MODULE__.t()
  def new(%Point{} = center, radius, start_angle, stop_angle) do
    %__MODULE__{
      center: center,
      radius: radius * 1.0,
      start_angle: start_angle * 1.0,
      stop_angle: stop_angle * 1.0
    }
  end

  def new({x, y}, radius, start_angle, stop_angle) do
    %__MODULE__{
      center: Point.new(x, y),
      radius: radius * 1.0,
      start_angle: start_angle * 1.0,
      stop_angle: stop_angle * 1.0
    }
  end
end
