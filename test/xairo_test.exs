defmodule XairoTest do
  use ExUnit.Case

  alias Xairo.{Image, Point}

  setup do
    on_exit(fn ->
      :ok = File.rm("test.png")
    end)
  end

  test "can create and save an empty image" do
    image = %Image{} = Xairo.new_image(100, 100)

    Xairo.save_image(image, "test.png")

    assert_images_equal("test.png", "test/images/empty.png")
  end

  test "creates a scaled image" do
    Xairo.new_image(100, 100, 2)
    |> Xairo.move_to(10, 10)
    |> Xairo.line_to(90, 90)
    |> Xairo.stroke()
    |> Xairo.save_image("test.png")

    assert_images_equal("test.png", "test/images/scaled.png")
  end

  test "can draw on an image" do
    Xairo.new_image(100, 100)
    |> Xairo.move_to(10, 10)
    |> Xairo.line_to(90, 90)
    |> Xairo.stroke()
    |> Xairo.save_image("test.png")

    assert_images_equal("test.png", "test/images/diagonal.png")
  end

  test "can draw on an image using points" do
    Xairo.new_image(100, 100)
    |> Xairo.move_to(Point.new(10, 10))
    |> Xairo.line_to(Point.new(90, 90))
    |> Xairo.stroke()
    |> Xairo.save_image("test.png")

    assert_images_equal("test.png", "test/images/diagonal.png")
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
    |> Xairo.save_image("test.png")

    assert_images_equal("test.png", "test/images/colors.png")
  end

  def assert_images_equal(actual_path, expected_path) do
    actual = hash(actual_path)
    expected = hash(expected_path)

    assert actual == expected
  end

  defp hash(file) do
    initial_state = :crypto.hash_init(:sha256)

    File.stream!(file, [], 2048)
    |> Enum.reduce(initial_state, &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
  end
end
