defmodule XairoTest do
  use ExUnit.Case

  alias Xairo.Point

  test "can create and save an empty image" do
    image = Xairo.new_image(100, 100)
    assert is_reference(image)

    Xairo.save_image(image, "test.png")

    assert_images_equal("test.png", "test/images/empty.png")

    :ok = File.rm("test.png")
  end

  test "can draw on an image" do
    Xairo.new_image(100, 100)
    |> Xairo.move_to(10, 10)
    |> Xairo.line_to(90, 90)
    |> Xairo.stroke()
    |> Xairo.save_image("test.png")

    assert_images_equal("test.png", "test/images/diagonal.png")

    :ok = File.rm("test.png")
  end

  test "can draw on an image using points" do
    Xairo.new_image(100, 100)
    |> Xairo.move_to(Point.new(10, 10))
    |> Xairo.line_to(Point.new(90, 90))
    |> Xairo.stroke()
    |> Xairo.save_image("test.png")

    assert_images_equal("test.png", "test/images/diagonal.png")

    :ok = File.rm("test.png")
  end

  def assert_images_equal(actual_path, expected_path) do
    {:ok, actual} = ExPng.Image.from_file(actual_path)
    {:ok, expected} = ExPng.Image.from_file(expected_path)

    assert actual == expected
  end
end
