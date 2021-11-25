defmodule XairoTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Dashes, Matrix, Point, Rectangle}

  setup do
    image =
      Xairo.new_image(100, 100, 2)
      |> Xairo.set_color(1, 1, 1)
      |> Xairo.paint()

    {:ok, %{image: image}}
  end

  test "error handling for bad filename" do
    assert {:error, "Error creating file at nope/nope/nope.png"} ==
             Xairo.new_image(100, 100)
             |> Xairo.save_image("nope/nope/nope.png")
  end

  test "proper return for valid filename" do
    %Xairo.Image{} =
      Xairo.new_image(100, 100)
      |> Xairo.save_image("yep.png")

    :ok = File.rm("yep.png")
  end

  test "can create and save an empty image" do
    Xairo.new_image(100, 100)
    |> assert_image("empty.png")
  end

  test "creates a scaled image" do
    Xairo.new_image(100, 100, 2)
    |> Xairo.move_to({10, 10})
    |> Xairo.line_to({90, 90})
    |> Xairo.stroke()
    |> assert_image("scaled.png")
  end

  test "can draw on an image" do
    Xairo.new_image(100, 100)
    |> Xairo.move_to({10, 10})
    |> Xairo.line_to({90, 90})
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
    |> Xairo.move_to({10, 10})
    |> Xairo.line_to({90, 90})
    |> Xairo.set_color(0, 1, 1)
    |> Xairo.stroke()
    |> Xairo.move_to({60, 10})
    |> Xairo.line_to({60, 40})
    |> Xairo.line_to({90, 40})
    |> Xairo.line_to({90, 10})
    |> Xairo.close_path()
    |> Xairo.set_color(0, 1, 0, 0.4)
    |> Xairo.fill()
    |> assert_image("colors.png")
  end

  test "line_caps", %{image: image} do
    image =
      image
      |> Xairo.set_color(0.5, 0, 1)
      |> Xairo.set_line_width(5)

    image =
      image
      |> Xairo.move_to({10, 10})
      |> Xairo.line_to({90, 10})
      |> Xairo.stroke()

    line_caps = [{:butt, 35}, {:square, 60}, {:round, 85}]

    image =
      Enum.reduce(line_caps, image, fn {type, y}, image ->
        image
        |> Xairo.set_line_cap(type)
        |> Xairo.move_to({10, y})
        |> Xairo.line_to({90, y})
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
      |> Xairo.move_to({10, 10})
      |> Xairo.line_to({40, 10})
      |> Xairo.line_to({40, 40})
      |> Xairo.line_to({10, 40})
      |> Xairo.close_path()
      |> Xairo.stroke()

    line_joins = [{:round, {60, 10}}, {:bevel, {10, 60}}, {:miter, {60, 60}}]

    image =
      Enum.reduce(line_joins, image, fn {type, {x, y}}, image ->
        image
        |> Xairo.set_line_join(type)
        |> Xairo.move_to({x, y})
        |> Xairo.line_to({x + 30, y})
        |> Xairo.line_to({x + 30, y + 30})
        |> Xairo.line_to({x, y + 30})
        |> Xairo.close_path()
        |> Xairo.stroke()
      end)

    assert_image(image, "line_joins.png")
  end

  test "dashes", %{image: image} do
    image =
      image
      |> Xairo.set_color(0.5, 0, 1)
      |> Xairo.set_line_width(1)

    dashes = [
      {[5, 1, 2, 1], 0, 10},
      {[1, 1, 2, 1, 3], 0, 30},
      {[1, 2, 3, 2], 1, 50},
      {[1, 2, 3, 4], 0, 70},
      {[1, 2, 1, 5], 0, 90}
    ]

    image =
      Enum.reduce(dashes, image, fn {dashes, offset, y}, image ->
        dashes = Dashes.new(dashes, offset)

        image
        |> Xairo.set_dash(dashes)
        |> Xairo.move_to({10, y})
        |> Xairo.line_to({90, y})
        |> Xairo.stroke()
      end)

    assert_image(image, "dashes.png")
  end

  test "relative move_to and line_to", %{image: image} do
    image
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.move_to({10, 10})
    |> Xairo.rel_line_to({40, 40})
    |> Xairo.rel_move_to({20, 0})
    |> Xairo.line_to({90, 90})
    |> Xairo.stroke()
    |> assert_image("relative.png")
  end

  test "arcs", %{image: image} do
    image
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.arc({50, 50}, 40, 0, :math.pi() / 2)
    |> Xairo.stroke()
    |> Xairo.arc(Point.new(50, 50), 30, -:math.pi() / 2, :math.pi() / 2)
    |> Xairo.stroke()
    |> Xairo.arc_negative({50, 50}, 20, -:math.pi() / 2, :math.pi() / 2)
    |> Xairo.stroke()
    |> assert_image("arcs.png")
  end

  test "curves", %{image: image} do
    image
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.move_to({10, 10})
    |> Xairo.curve_to({80, 20}, {90, 80}, {80, 90})
    |> Xairo.stroke()
    |> Xairo.move_to(Point.new(20, 20))
    |> Xairo.rel_curve_to({20, -20}, {50, 50}, {-10, 70})
    |> Xairo.stroke()
    |> assert_image("curves.png")
  end

  test "rectangles", %{image: image} do
    image
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.rectangle({10, 10}, 50, 50)
    |> Xairo.stroke()
    |> Xairo.set_color(1, 0.5, 0)
    |> Xairo.rectangle({30, 40}, 60, 40)
    |> Xairo.fill()
    |> assert_image("rectangles.png")
  end

  test "transformations", %{image: image} do
    image
    |> Xairo.set_color(0, 0, 0)
    |> draw_rectangle()
    |> Xairo.translate(40, 40)
    |> draw_rectangle()
    |> Xairo.rotate(:math.pi() / 6)
    |> draw_rectangle()
    |> Xairo.transform(Matrix.new(xx: 3, yy: 3, yt: -40))
    |> draw_rectangle()
    |> Xairo.identity_matrix()
    |> draw_rectangle()
    |> assert_image("transforms.png")
  end

  defp draw_rectangle(image) do
    image
    |> Xairo.rectangle(Rectangle.new({10, 10}, 20, 20))
    |> Xairo.stroke()
  end
end
