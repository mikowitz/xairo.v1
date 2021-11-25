defmodule Xairo.MatrixTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.Matrix
  doctest Matrix

  test "set matrix" do
    matrix = Matrix.new(xx: 2, yy: 3, xy: 0.8, yx: 1.8, xt: 20, yt: -20)

    Xairo.new_image(100, 100)
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.paint()
    |> Xairo.set_color(0, 0, 0)
    |> Xairo.rectangle({10, 10}, 10, 10)
    |> Xairo.stroke()
    |> Xairo.set_matrix(matrix)
    |> Xairo.rectangle({10, 10}, 10, 10)
    |> Xairo.stroke()
    |> assert_image("set_matrix.png")
  end

  test "get matrix" do
    image =
      Xairo.new_image(100, 100)
      |> Xairo.translate(40, 40)
      |> Xairo.rotate(:math.pi() / 6)
      |> Xairo.transform(Matrix.new(xx: 3, yy: 3, yt: -40))

    matrix = Xairo.get_matrix(image)

    epsilon = 1.0e-8

    assert_in_delta(matrix.xx, 2.59807621, epsilon)
    assert_in_delta(matrix.yy, 2.59807621, epsilon)
    assert_in_delta(matrix.xy, -1.5, epsilon)
    assert_in_delta(matrix.yx, 1.5, epsilon)
    assert_in_delta(matrix.xt, 60, epsilon)
    assert_in_delta(matrix.yt, 5.35898384, epsilon)
  end
end
