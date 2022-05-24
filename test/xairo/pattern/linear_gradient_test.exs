# test/xairo/pattern/linear_gradient_test.exs
defmodule Xairo.Pattern.LinearGradientTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Pattern.LinearGradient, Point, RGBA}

  test "drawing with linear gradients" do
    vertical_gradient =
      LinearGradient.new(
        Point.new(0, 0),
        Point.new(0, 100)
      )
      |> LinearGradient.add_color_stop(0, RGBA.new(1, 0, 0))
      |> LinearGradient.add_color_stop(1, RGBA.new(0, 0, 1))

    diagonal_gradient =
      LinearGradient.new(
        Point.new(0, 0),
        Point.new(100, 100)
      )
      |> LinearGradient.add_color_stop(0, RGBA.new(0, 0, 1))
      |> LinearGradient.add_color_stop(1, RGBA.new(1, 0, 0))

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

  describe "color_stop_count" do
    test "returns the correct number of color stops for a gradient" do
      gradient = LinearGradient.new(Point.new(0, 0), Point.new(0, 100))

      assert LinearGradient.color_stop_count(gradient) == 0

      gradient =
        gradient
        |> LinearGradient.add_color_stop(0, RGBA.new(1, 0, 0))
        |> LinearGradient.add_color_stop(1, RGBA.new(0, 0, 1))

      assert LinearGradient.color_stop_count(gradient) == 2
    end
  end

  describe "color_stop/2" do
    gradient =
      LinearGradient.new(Point.new(0, 0), Point.new(0, 100))
      |> LinearGradient.add_color_stop(0, RGBA.new(1, 0, 0))
      |> LinearGradient.add_color_stop(1, RGBA.new(0, 0, 1))

    assert LinearGradient.color_stop(gradient, 0) == RGBA.new(1, 0, 0)

    assert LinearGradient.color_stop(gradient, 2) ==
             {:error, "No color stop found at index 2"}
  end

  describe "linear_points" do
    gradient =
      LinearGradient.new(Point.new(0, 0), Point.new(0, 100))
      |> LinearGradient.add_color_stop(0, RGBA.new(1, 0, 0))
      |> LinearGradient.add_color_stop(1, RGBA.new(0, 0, 1))

    assert LinearGradient.linear_points(gradient) == {
             Point.new(0, 0),
             Point.new(0, 100)
           }
  end
end
