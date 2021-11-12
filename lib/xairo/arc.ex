defmodule Xairo.Arc do
  alias Xairo.Point

  defstruct [:center, :radius, :start_angle, :stop_angle]

  def new(%Point{} = center, radius, start_angle, stop_angle) do
    %__MODULE__{
      center: center,
      radius: radius * 1.0,
      start_angle: start_angle * 1.0,
      stop_angle: stop_angle * 1.0
    }
  end

  def new(x, y, radius, start_angle, stop_angle) do
    %__MODULE__{
      center: Point.new(x, y),
      radius: radius * 1.0,
      start_angle: start_angle * 1.0,
      stop_angle: stop_angle * 1.0
    }
  end
end
