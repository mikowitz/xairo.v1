defmodule Xairo.Pattern.SolidTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Pattern.Solid, RGBA}

  describe "new/1" do
    test "returns a solid pattern" do
      pattern = Solid.new(RGBA.new(0, 0, 1, 0.5))

      Xairo.new_image("solid.png", 100, 100)
      |> Xairo.set_source(pattern)
      |> Xairo.paint()
      |> assert_image()
    end
  end

  describe "color/1" do
    test "returns the color of the solid pattern" do
      pattern = Solid.new(RGBA.new(0, 0, 1, 0.5))

      assert Solid.color(pattern) == RGBA.new(0, 0, 1, 0.5)
    end
  end
end
