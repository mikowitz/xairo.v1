defmodule XairoTest do
  use ExUnit.Case
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Dashes, Point}

  setup do
    on_exit(fn ->
      :ok = File.rm("test.png")
    end)
  end

  test "can create and save an empty image" do
    Xairo.new_image(100, 100)
    |> assert_image("empty.png")
  end

  test "creates a scaled image" do
    Xairo.new_image(100, 100, 2)
    |> Xairo.move_to(10, 10)
    |> Xairo.line_to(90, 90)
    |> Xairo.stroke()
    |> assert_image("scaled.png")
  end

  test "can draw on an image" do
    Xairo.new_image(100, 100)
    |> Xairo.move_to(10, 10)
    |> Xairo.line_to(90, 90)
    |> Xairo.stroke()
    |> assert_image("diagonal.png")
  end

  test "can draw on an image using points" do
    Xairo.new_image(100, 100)
    |> Xairo.move_to(Point.new(10, 10))
    |> Xairo.line_to(Point.new(90, 90))
    |> Xairo.stroke()
    |> assert_image("diagonal.png")
  end

  test "colors" do
    Xairo.new_image(100, 100)
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.paint()
    |> Xairo.move_to(10, 10)
    |> Xairo.line_to(90, 90)
    |> Xairo.set_color(0, 1, 1)
    |> Xairo.stroke()
    |> Xairo.move_to(60, 10)
    |> Xairo.line_to(60, 40)
    |> Xairo.line_to(90, 40)
    |> Xairo.line_to(90, 10)
    |> Xairo.close_path()
    |> Xairo.set_color(0, 1, 0, 0.4)
    |> Xairo.fill()
    |> assert_image("colors.png")
  end

  test "line_caps" do
    image =
      Xairo.new_image(100, 100, 2.0)
      |> Xairo.set_color(1, 1, 1)
      |> Xairo.paint()
      |> Xairo.set_color(0.5, 0, 1)
      |> Xairo.set_line_width(5)

    image =
      image
      |> Xairo.move_to(10, 10)
      |> Xairo.line_to(90, 10)
      |> Xairo.stroke()

    line_caps = [{:butt, 35}, {:square, 60}, {:round, 85}]
    image =
      Enum.reduce(line_caps, image, fn {type, y}, image ->
        image
        |> Xairo.set_line_cap(type)
        |> Xairo.move_to(10, y)
        |> Xairo.line_to(90, y)
        |> Xairo.stroke()
      end)

    assert_image(image, "line_caps.png")
  end

  test "line_joins" do
    image =
      Xairo.new_image(100, 100, 4.0)
      |> Xairo.set_color(1, 1, 1)
      |> Xairo.paint()
      |> Xairo.set_color(0.5, 0, 1)
      |> Xairo.set_line_width(5)

    image =
      image
      |> Xairo.move_to(10, 10)
      |> Xairo.line_to(40, 10)
      |> Xairo.line_to(40, 40)
      |> Xairo.line_to(10, 40)
      |> Xairo.close_path()
      |> Xairo.stroke()

    line_joins = [{:round, {60, 10}}, {:bevel, {10, 60}}, {:miter, {60, 60}}]

    image =
      Enum.reduce(line_joins, image, fn {type, {x, y}}, image ->
        image
        |> Xairo.set_line_join(type)
        |> Xairo.move_to(x, y)
        |> Xairo.line_to(x + 30, y)
        |> Xairo.line_to(x + 30, y + 30)
        |> Xairo.line_to(x, y + 30)
        |> Xairo.close_path()
        |> Xairo.stroke()
      end)

    assert_image(image, "line_joins.png")
  end

  test "dashes" do
    image =
      Xairo.new_image(100, 100, 2.0)
      |> Xairo.set_color(1, 1, 1)
      |> Xairo.paint()
      |> Xairo.set_color(0.5, 0, 1)
      |> Xairo.set_line_width(1)

    dashes = [
      {[5, 1,2, 1], 0, 10},
      {[1,1,2,1,3], 0, 30},
      {[1,2,3,2], 1, 50},
      {[1,2,3,4], 0, 70},
      {[1,2,1,5], 0, 90}
    ]


    image = Enum.reduce(dashes, image, fn {dashes, offset, y}, image ->
      dashes = Dashes.new(dashes, offset)
      image
      |> Xairo.set_dash(dashes)
      |> Xairo.move_to(10, y)
      |> Xairo.line_to(90, y)
      |> Xairo.stroke()
    end)


    assert_image(image, "dashes.png")
  end
end
