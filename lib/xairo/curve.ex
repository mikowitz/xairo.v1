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
  @spec new(Point.t(), Point.t(), Point.t()) :: __MODULE__.t()
  @spec new(Xairo.coordinate(), Xairo.coordinate(), Xairo.coordinate()) :: __MODULE__.t()
  def new(%Point{} = first_control_point, %Point{} = second_control_point, %Point{} = curve_end) do
    %__MODULE__{
      first_control_point: first_control_point,
      second_control_point: second_control_point,
      curve_end: curve_end
    }
  end

  def new({x1, y1}, {x2, y2}, {x3, y3}) do
    %__MODULE__{
      first_control_point: Point.new(x1, y1),
      second_control_point: Point.new(x2, y2),
      curve_end: Point.new(x3, y3)
    }
  end
end
