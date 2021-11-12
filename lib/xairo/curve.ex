defmodule Xairo.Curve do
  alias Xairo.Point

  defstruct [:first_control_point, :second_control_point, :curve_end]

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
