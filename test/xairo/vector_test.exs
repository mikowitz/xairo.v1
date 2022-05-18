defmodule Xairo.VectorTest do
  use ExUnit.Case, async: true

  alias Xairo.{Matrix, Vector}
  doctest Vector

  @epsilon 1.0e-8

  describe "converting between user and image spaces" do
    setup do
      image =
        Xairo.new_image("test.png", 100, 100)
        |> Xairo.translate(40, 40)
        |> Xairo.rotate(:math.pi() / 6)
        |> Xairo.transform(Matrix.new(xx: 3, yy: 3, yt: -40))

      {:ok, image: image}
    end

    test "from userspace to imagespace", %{image: image} do
      vec = Vector.new(10, 10)

      %Vector{x: x, y: y} = Vector.user_to_device(vec, image)

      assert_in_delta(x, 10.98076211, @epsilon)
      assert_in_delta(y, 40.98076211, @epsilon)
    end

    test "from imagespace to userspace", %{image: image} do
      vec = Vector.new(10, 10)

      %Vector{x: x, y: y} = Vector.device_to_user(vec, image)

      assert_in_delta(x, 4.55341801, @epsilon)
      assert_in_delta(y, 1.22008467, @epsilon)
    end
  end
end
