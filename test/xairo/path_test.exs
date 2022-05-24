defmodule Xairo.PathTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  test "copy_path" do
    image =
      Xairo.new_image("copy_path.png", 200, 200)
      |> Xairo.set_color(1, 1, 1)
      |> Xairo.paint()
      |> Xairo.set_color(0, 0, 0)
      |> Xairo.set_line_width(3)
      |> Xairo.move_to({20, 20})
      |> Xairo.line_to({150, 80})
      |> Xairo.line_to({100, 180})
      |> Xairo.close_path()

    path = Xairo.copy_path(image)

    image
    |> Xairo.fill()
    |> Xairo.set_color(0, 0.5, 1)
    |> Xairo.append_path(path)
    |> Xairo.stroke()
    |> assert_image()
  end

  test "copy_path_flat" do
    image = image_for_flat_tests()

    tolerance = Xairo.get_tolerance(image)

    path =
      image
      |> Xairo.set_tolerance(10)
      |> Xairo.copy_path_flat()

    image
    |> Xairo.set_tolerance(tolerance)
    |> Xairo.fill()
    |> Xairo.set_color(0, 0.5, 1)
    |> Xairo.append_path(path)
    |> Xairo.stroke()
    |> assert_image("copy_path_flat.png")
  end

  test "flat_from_image_with_tolerance" do
    image = image_for_flat_tests()

    {path, image} = Xairo.Path.flat(image, 10)

    image
    |> Xairo.fill()
    |> Xairo.set_color(0, 0.5, 1)
    |> Xairo.append_path(path)
    |> Xairo.stroke()
    |> assert_image("copy_path_flat.png")
  end

  test "new_path ignores anything that was not rendered before" do
    Xairo.new_image("new_path.png", 100, 100)
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.move_to({10, 10})
    |> Xairo.line_to({90, 90})
    |> Xairo.new_path()
    |> Xairo.arc({50, 50}, 20, 0, 3.1)
    |> Xairo.stroke()
    |> assert_image()
  end

  test "new_sub_path keeps existing path but breaks connector for an arc" do
    Xairo.new_image("new_sub_path.png", 100, 100)
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.move_to({10, 10})
    |> Xairo.line_to({90, 90})
    |> Xairo.new_sub_path()
    |> Xairo.arc({50, 50}, 20, 0, 3.1)
    |> Xairo.stroke()
    |> assert_image()
  end

  test "current_point returns the path's current point, or nil if there is none" do
    image = Xairo.new_image("current_point.png", 100, 100)

    refute Xairo.current_point(image)

    image =
      image
      |> Xairo.move_to({25, 75})
      |> Xairo.line_to({50, 50})

    assert Xairo.current_point(image) == Xairo.Point.new(50, 50)
  end

  @tag macos: false
  test "text_path adds closed paths for the outline of the provided string" do
    Xairo.new_image("text_path.png", 100, 100)
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.set_font_size(30)
    |> Xairo.set_line_width(0.5)
    |> Xairo.move_to({20, 50})
    |> Xairo.text_path("Hello")
    |> Xairo.stroke()
    |> assert_image()
  end

  defp image_for_flat_tests do
    Xairo.new_image("flat_test.png", 200, 200)
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.paint()
    |> Xairo.set_color(0, 0, 0)
    |> Xairo.set_line_width(3)
    |> Xairo.move_to({20, 20})
    |> Xairo.line_to({60, 80})
    |> Xairo.arc({100, 100}, 50, 0, 2)
    |> Xairo.close_path()
  end
end
