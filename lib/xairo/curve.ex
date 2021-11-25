defmodule Xairo.Curve do
  @moduledoc """
  Models a cubic Bézier curve.

  The curve struct is defined by providing the two control points and the end
  coordinate of the curve. When rendered, the starting point of the curve will
  be the surface's current point, or else the first control point if no
  current point exists for the path the curve is being added to.

  These control points can be represented by `Xairo.Point` structs or
  `Xairo.Vector` structs, to model, respectively, a curve built from absolute
  points in user space, or a curve built from points relative to the curve's beginning.
  """
  alias Xairo.{Point, Vector}

  defstruct [:first_control_point, :second_control_point, :curve_end]

  @type control_point :: Point.t() | Vector.t()

  @type t :: %__MODULE__{
          first_control_point: Point.t() | Vector.t(),
          second_control_point: Point.t() | Vector.t(),
          curve_end: Point.t() | Vector.t()
        }

  @doc """
  Creates a struct representing a cubic Bézier curve in absolute userspace.

  `new/3` takes as its arguments three `t:Xairo.Point.t/0` structs, `t:Xairo.Vector.t/0` structs, or
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
  @spec new(
          control_point() | Xairo.coordinate(),
          control_point() | Xairo.coordinate(),
          control_point() | Xairo.coordinate(),
          Keyword.t() | nil
        ) :: __MODULE__.t()
  def new(first_control_point, second_control_point, curve_end, opts \\ []) do
    is_relative = Keyword.get(opts, :relative, false)

    %__MODULE__{
      first_control_point: point_or_vector_from(first_control_point, is_relative),
      second_control_point: point_or_vector_from(second_control_point, is_relative),
      curve_end: point_or_vector_from(curve_end, is_relative)
    }
  end

  defp point_or_vector_from(%Point{} = point, _), do: point
  defp point_or_vector_from(%Vector{} = vector, _), do: vector
  defp point_or_vector_from({x, y}, true), do: Vector.new(x, y)
  defp point_or_vector_from({x, y}, false), do: Point.new(x, y)
end
