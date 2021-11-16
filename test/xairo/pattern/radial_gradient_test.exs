defmodule Xairo.Pattern.RadialGradientTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Arc, Pattern.RadialGradient, Point, RGBA}

  doctest RadialGradient

  test "drawing with radial gradients" do
    background =
      RadialGradient.new(
        Point.new(50, 50),
        10,
        Point.new(50, 50),
        70,
        [
          {RGBA.new(1, 0, 0), 0.0},
          {RGBA.new(0, 0, 1), 1.0}
        ]
      )

    moon =
      RadialGradient.new(
        Point.new(20, 20),
        10,
        Point.new(20, 20),
        30,
        [
          {RGBA.new(1, 1, 1), 0.0},
          {RGBA.new(0.6, 0.6, 0.6), 1.0}
        ]
      )

    moon_arc = Arc.new({30, 30}, 20, 0, :math.pi() * 2)

    Xairo.new_image(100, 100, 2)
    |> Xairo.set_source(background)
    |> Xairo.paint()
    |> Xairo.set_source(moon)
    |> Xairo.arc(moon_arc)
    |> Xairo.fill()
    |> assert_image("radial_gradients.png")
  end
end
