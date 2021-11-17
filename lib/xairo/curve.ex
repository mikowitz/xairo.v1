defmodule Xairo.Curve do
  @moduledoc """
  Models a cubic Bézier curve.

  The curve struct is defined by providing the two control points and the end
  coordinate of the curve. When rendered, the starting point of the curve will
  be the surface's current point, or else the first control point if no
  current point exists for the path the curve is being added to.
  """
  alias Xairo.Point

  defstruct [:first_control_point, :second_control_point, :curve_end]

  @type t :: %__MODULE__{
          first_control_point: Point.t(),
          second_control_point: Point.t(),
          curve_end: Point.t()
        }

  @doc """
  Creates a struct representing a cubic Bézier curve in absolute imagespace.

  `new/3` takes as its arguments three `t:Xairo.Point.t/0` structs, or
  coordinate tuple pairs, which represent, respectively, the two control points
  of the curve, and its ending point.

  ## Example

  ```elixir
  Curve.new(
    Point.new(10, 10),  # first control point
    Point.new(50, 30),  # second control point
    Point.new(20, 80)   # curve end
  )
  ```
  """
  @spec new(Xairo.point(), Xairo.point(), Xairo.point()) :: __MODULE__.t()
  def new(first_control_point, second_control_point, curve_end) do
    %__MODULE__{
      first_control_point: Point.from(first_control_point),
      second_control_point: Point.from(second_control_point),
      curve_end: Point.from(curve_end)
    }
  end
end
