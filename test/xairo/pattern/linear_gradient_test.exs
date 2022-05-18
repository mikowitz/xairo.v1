# test/xairo/pattern/linear_gradient_test.exs
defmodule Xairo.Pattern.LinearGradientTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Pattern.LinearGradient, Point, RGBA}

  doctest LinearGradient

  test "drawing with linear gradients" do
    vertical_gradient =
      LinearGradient.new(
        Point.new(0, 0),
        Point.new(0, 100),
        [
          {RGBA.new(1, 0, 0), 0.0},
          {RGBA.new(0, 0, 1), 1.0}
        ]
      )

    diagonal_gradient =
      LinearGradient.new(
        Point.new(0, 0),
        Point.new(100, 100),
        [
          {RGBA.new(0, 0, 1), 0.0},
          {RGBA.new(1, 0, 0), 1.0}
        ]
      )

    Xairo.new_image("linear_gradients.png", 100, 100, scale: 2)
    |> Xairo.set_line_width(10)
    |> Xairo.set_source(vertical_gradient)
    |> Xairo.paint()
    |> Xairo.set_source(diagonal_gradient)
    |> Xairo.move_to(Point.new(10, 10))
    |> Xairo.line_to({90, 90})
    |> Xairo.stroke()
    |> assert_image("linear_gradients.png")
  end
end
