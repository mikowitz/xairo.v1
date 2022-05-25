defmodule Xairo.Pattern.SurfaceTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Pattern.LinearGradient, Pattern.Surface, RGBA}

  describe "new/1" do
    test "returns a pattern from a surface" do
      lg =
        LinearGradient.new({10, 10}, {90, 90})
        |> LinearGradient.add_color_stop(0, RGBA.new(0, 1, 0))
        |> LinearGradient.add_color_stop(0.5, RGBA.new(0.5, 0.5, 1))

      pattern =
        Surface.new(100, 100)
        |> Xairo.set_source(lg)
        |> Xairo.paint()

      Xairo.new_image("surface_pattern.png", 100, 100)
      |> Xairo.set_color(RGBA.new(1, 1, 1))
      |> Xairo.paint()
      |> Xairo.set_source(pattern)
      |> Xairo.move_to({10, 10})
      |> Xairo.line_to({50, 80})
      |> Xairo.line_to({5, 60})
      |> Xairo.fill()
      |> Xairo.set_color(RGBA.new(0.5, 0.5, 0.5))
      |> Xairo.rectangle({20, 20}, 50, 50)
      |> Xairo.stroke()
      |> assert_image()
    end
  end
end
