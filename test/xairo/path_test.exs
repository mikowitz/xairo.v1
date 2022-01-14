defmodule Xairo.PathTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  test "copy_path" do
    image =
      Xairo.new_image(200, 200)
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
    |> assert_image("copy_path.png")
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

  def image_for_flat_tests do
    Xairo.new_image(200, 200)
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
