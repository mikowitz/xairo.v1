defmodule Xairo.Pattern.RadialGradientTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Arc, Pattern.RadialGradient, Point, RGBA}

  test "drawing with radial gradients" do
    background =
      RadialGradient.new(
        Point.new(50, 50),
        10,
        Point.new(50, 50),
        70
      )
      |> RadialGradient.add_color_stop(0.0, RGBA.new(1, 0, 0))
      |> RadialGradient.add_color_stop(1.0, RGBA.new(0, 0, 1))

    moon =
      RadialGradient.new(
        Point.new(20, 20),
        10,
        Point.new(20, 20),
        30
      )
      |> RadialGradient.add_color_stop(0.0, RGBA.new(1, 1, 1))
      |> RadialGradient.add_color_stop(1.0, RGBA.new(0.6, 0.6, 0.6))

    moon_arc = Arc.new({30, 30}, 20, 0, :math.pi() * 2)

    Xairo.new_image("radial_gradients.png", 100, 100, scale: 2)
    |> Xairo.set_source(background)
    |> Xairo.paint()
    |> Xairo.set_source(moon)
    |> Xairo.arc(moon_arc)
    |> Xairo.fill()
    |> assert_image("radial_gradients.png")
  end

  describe "color_stop_count/1" do
    test "returns the correct number of color stops for the gradient" do
      gradient = RadialGradient.new({20, 20}, 10, {20, 20}, 30)

      assert RadialGradient.color_stop_count(gradient) == 0

      gradient =
        gradient
        |> RadialGradient.add_color_stop(0.0, RGBA.new(1, 1, 1))
        |> RadialGradient.add_color_stop(1.0, RGBA.new(0.6, 0.6, 0.6))

      assert RadialGradient.color_stop_count(gradient) == 2
    end
  end

  describe "color_stop/2" do
    test "returns the color stop at the given index, or an error" do
      gradient =
        RadialGradient.new({20, 20}, 10, {20, 20}, 30)
        |> RadialGradient.add_color_stop(0.0, RGBA.new(1, 1, 1))
        |> RadialGradient.add_color_stop(1.0, RGBA.new(0.6, 0.6, 0.6))

      assert RadialGradient.color_stop(gradient, 0) == RGBA.new(1, 1, 1)

      assert RadialGradient.color_stop(gradient, 5) == {:error, "No color stop found at index 5"}
    end
  end

  describe "radial_circles/1" do
    test "returns the radial circles for the gradient" do
      gradient =
        RadialGradient.new({20, 20}, 10, {20, 20}, 30)
        |> RadialGradient.add_color_stop(0.0, RGBA.new(1, 1, 1))
        |> RadialGradient.add_color_stop(1.0, RGBA.new(0.6, 0.6, 0.6))

      assert RadialGradient.radial_circles(gradient) ==
               {
                 {Point.new(20, 20), 10.0},
                 {Point.new(20, 20), 30.0}
               }
    end
  end
end
