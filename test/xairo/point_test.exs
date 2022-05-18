defmodule Xairo.PointTest do
  use ExUnit.Case, async: true

  alias Xairo.{Matrix, Point}
  doctest Point

  @epsilon 1.0e-8

  describe "converting between user and image spaces" do
    setup do
      image =
        Xairo.new_image("point.png", 100, 100)
        |> Xairo.translate(40, 40)
        |> Xairo.rotate(:math.pi() / 6)
        |> Xairo.transform(Matrix.new(xx: 3, yy: 3, yt: -40))

      {:ok, image: image}
    end

    test "from userspace to imagespace", %{image: image} do
      point = Point.new(10, 10)

      %Point{x: x, y: y} = Point.user_to_device(point, image)

      assert_in_delta(x, 70.98076211, @epsilon)
      assert_in_delta(y, 46.33974596, @epsilon)
    end

    test "from imagespace to userspace", %{image: image} do
      point = Point.new(10, 10)

      %Point{x: x, y: y} = Point.device_to_user(point, image)

      assert_in_delta(x, -13.66025403, @epsilon)
      assert_in_delta(y, 9.67307929, @epsilon)
    end
  end
end
