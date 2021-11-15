defmodule Xairo.Rectangle do
  @moduledoc """
  Models a rectangle that can be rendered on an image surface.

  The struct stores the origin (top left) corner of the rectangle
  as a `t:Xairo.Point.t/0`, and a width and height, all defined in
  absolute imagespace.

  Given a rectangle

  ```
  rect = Rectangle.new({x, y}, w, h)
  ```

  calling

  ```
  Xairo.rectangle(image, rect)
  ```

  is equivalent to calling

  ```
  Xairo.move_to(image, {x, y})
  |> Xairo.line_to({x + w, y})
  |> Xairo.line_to({x + w, y + h})
  |> Xairo.line_to({x, y + h})
  |> Xairo.line_to({x, y})
  ```
  """
  alias Xairo.Point

  defstruct [:corner, :width, :height]

  @type t :: %__MODULE__{
          corner: Point.t(),
          width: number(),
          height: number()
        }

  @doc """
  Creates a new `Rectangle` from a (top left) corner, a width and a height.

  ## Example

      iex> Rectangle.new({10, 10}, 20, 20)

  creates a rectangle with a top left corner at {10, 10}, and a bottom right
  corner at {30, 30}, in absolute imagespace.
  """
  @spec new(Point.t(), number(), number()) :: __MODULE__.t()
  @spec new(Xairo.coordinate(), number(), number()) :: __MODULE__.t()
  def new(%Point{} = corner, width, height) do
    %__MODULE__{
      corner: corner,
      width: width * 1.0,
      height: height * 1.0
    }
  end

  def new({x, y}, width, height) do
    with corner <- Point.new(x, y), do: new(corner, width, height)
  end
end
