defmodule Xairo.TextTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Arc, Matrix, Text, Text.Font}

  doctest Text

  @tag macos: false
  test "basic text operations" do
    image =
      Xairo.new_image(100, 50, 3)
      |> Xairo.set_color(1, 1, 1)
      |> Xairo.paint()
      |> Xairo.set_color(0, 0, 0)
      |> Xairo.set_font_size(15)
      |> Xairo.move_to({10, 20})
      |> Xairo.show_text("Hello")
      |> Xairo.set_color(0.3, 0.3, 0.3)
      |> Xairo.move_to({10.5, 20.5})
      |> Xairo.show_text("Hello")
      |> Xairo.set_color(0, 0, 0)
      |> Xairo.set_font_size(20)
      |> Xairo.move_to({30, 40})
      |> Xairo.show_text("world")

    extents = Text.extents(image, "world")

    image
    |> Xairo.set_line_width(1)
    |> Xairo.set_color(1, 0.5, 0.5)
    |> Xairo.arc(Arc.new({30, 40}, 3, 0, 2 * :math.pi()))
    |> Xairo.fill()
    |> Xairo.move_to({30, 40})
    |> Xairo.rel_line_to({extents.x_bearing, extents.y_bearing})
    |> Xairo.rel_line_to({extents.width, 0})
    |> Xairo.rel_line_to({0, extents.height})
    |> Xairo.close_path()
    |> Xairo.stroke()
    |> assert_image("text.png")
  end

  @tag macos: false
  test "font manipulation" do
    bold =
      Font.new(
        family: :serif,
        weight: :bold
      )

    matrix = Matrix.new(xx: 10, yx: 2, xy: -5, yy: 15, xt: 3, yt: 10)

    Xairo.new_image(100, 100, 2)
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.paint()
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.move_to({20, 20})
    |> Xairo.show_text("hello")
    |> Xairo.set_font_size(25)
    |> Xairo.select_font_face(:serif, :italic, :bold)
    |> Xairo.move_to({20, 50})
    |> Xairo.show_text("hello")
    |> Xairo.set_font_face(bold)
    |> Xairo.set_font_matrix(matrix)
    |> Xairo.move_to({20, 60})
    |> Xairo.show_text("hello")
    |> assert_image("fonts.png")
  end
end
