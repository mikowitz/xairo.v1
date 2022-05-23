defmodule Xairo.ExtentsTest do
  use ExUnit.Case, async: true

  alias Xairo.{Extents, Point}

  describe "path_extents" do
    test "accurately returns the origin and lower-right coordinates covering the points on the current path" do
      Xairo.new_image("test.png", 100, 100, scale: 3)
      |> assert_extents(:path, {0, 0}, {0, 0})
      |> Xairo.move_to({10, 10})
      |> assert_extents(:path, {0, 0}, {0, 0})
      |> Xairo.line_to({80, 80})
      |> assert_extents(:path, {10, 10}, {80, 80})
      |> Xairo.line_to({5, 60})
      |> assert_extents(:path, {5, 10}, {80, 80})
      |> Xairo.stroke()
      |> assert_extents(:path, {0, 0}, {0, 0})
    end
  end

  describe "stroke_extents" do
    test "accurately returns the origin and lower-right coordinates covering the area that would be inked by a `stroke` command" do
      Xairo.new_image("test.png", 100, 100, scale: 3)
      |> assert_extents(:stroke, {0, 0}, {0, 0})
      |> Xairo.move_to({10, 10})
      |> assert_extents(:stroke, {0, 0}, {0, 0})
      |> Xairo.line_to({80, 80})
      |> assert_extents(:stroke, {9.29296875, 9.29296875}, {80.70703125, 80.70703125})
      |> Xairo.line_to({5, 60})
      |> assert_extents(:stroke, {4.7421875, 9.29296875}, {83.33984375, 81.92578125})
      |> Xairo.stroke()
      |> assert_extents(:stroke, {0, 0}, {0, 0})
    end
  end

  describe "fill_extents" do
    test "accurately returns the origin and lower-right coordinates covering the area that would be inked by a `fill` command" do
      Xairo.new_image("test.png", 100, 100, scale: 3)
      |> assert_extents(:fill, {0, 0}, {0, 0})
      |> Xairo.move_to({10, 10})
      |> assert_extents(:fill, {0, 0}, {0, 0})
      |> Xairo.line_to({80, 80})
      |> assert_extents(:fill, {0, 0}, {0, 0})
      |> Xairo.line_to({5, 60})
      |> assert_extents(:fill, {5, 10}, {80, 80})
      |> Xairo.stroke()
      |> assert_extents(:fill, {0, 0}, {0, 0})
    end
  end

  defp assert_extents(image, type, {x1, y1}, {x2, y2}) do
    extents = Extents.new(image)

    assert Extents.get(extents, type) == {Point.new(x1, y1), Point.new(x2, y2)}
    image
  end
end
