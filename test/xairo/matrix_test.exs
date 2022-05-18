defmodule Xairo.MatrixTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.Matrix
  doctest Matrix

  @epsilon 1.0e-8

  test "set matrix" do
    matrix = Matrix.new(xx: 2, yy: 3, xy: 0.8, yx: 1.8, xt: 20, yt: -20)

    Xairo.new_image("set_matrix.png", 100, 100)
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.paint()
    |> Xairo.set_color(0, 0, 0)
    |> Xairo.rectangle({10, 10}, 10, 10)
    |> Xairo.stroke()
    |> Xairo.set_matrix(matrix)
    |> Xairo.rectangle({10, 10}, 10, 10)
    |> Xairo.stroke()
    |> assert_image()
  end

  test "get matrix" do
    image =
      Xairo.new_image("get_matrix.png", 100, 100)
      |> Xairo.translate(40, 40)
      |> Xairo.rotate(:math.pi() / 6)
      |> Xairo.transform(Matrix.new(xx: 3, yy: 3, yt: -40))

    matrix = Xairo.get_matrix(image)

    assert_in_delta(matrix.xx, 2.59807621, @epsilon)
    assert_in_delta(matrix.yy, 2.59807621, @epsilon)
    assert_in_delta(matrix.xy, -1.5, @epsilon)
    assert_in_delta(matrix.yx, 1.5, @epsilon)
    assert_in_delta(matrix.xt, 60, @epsilon)
    assert_in_delta(matrix.yt, 5.35898384, @epsilon)
  end

  test "identity/0" do
    assert Matrix.identity() == Matrix.new()
  end

  describe "transformations" do
    setup do
      matrix = Matrix.new(xt: 10, yt: 10)
      {:ok, matrix: matrix}
    end

    test "translate/3", %{matrix: matrix} do
      assert Matrix.translate(matrix, 14, 17) == Matrix.new(xt: 24, yt: 27)
    end

    test "scale/3", %{matrix: matrix} do
      assert Matrix.scale(matrix, 5, 3) == Matrix.new(xx: 5.0, yy: 3.0, xt: 10, yt: 10)
    end

    test "rotate/2", %{matrix: matrix} do
      matrix = Matrix.rotate(matrix, :math.pi() / 4)

      assert_in_delta(matrix.xx, 0.70710678, @epsilon)
      assert_in_delta(matrix.yy, 0.70710678, @epsilon)
      assert_in_delta(matrix.yx, 0.70710678, @epsilon)
      assert_in_delta(matrix.xy, -0.70710678, @epsilon)
    end

    test "invert/1", %{matrix: matrix} do
      assert Matrix.invert(matrix) == Matrix.new(xt: -10, yt: -10)
    end

    test "multiply/2", %{matrix: matrix} do
      m1 = Matrix.rotate(matrix, :math.pi() / 4)

      m2 = Matrix.identity() |> Matrix.scale(5, 3)

      m3 = Matrix.multiply(m1, m2)
      m4 = Matrix.multiply(m2, m1)

      assert_in_delta(m3.xx, 3.5355339, @epsilon)
      assert_in_delta(m3.yy, 2.12132034, @epsilon)
      assert_in_delta(m3.xy, -3.5355339, @epsilon)
      assert_in_delta(m3.yx, 2.12132034, @epsilon)
      assert_in_delta(m3.xt, 50, @epsilon)
      assert_in_delta(m3.yt, 30, @epsilon)

      assert_in_delta(m4.xx, 3.5355339, @epsilon)
      assert_in_delta(m4.yy, 2.12132034, @epsilon)
      assert_in_delta(m4.xy, -2.12132034, @epsilon)
      assert_in_delta(m4.yx, 3.5355339, @epsilon)
      assert_in_delta(m4.xt, 10, @epsilon)
      assert_in_delta(m4.yt, 10, @epsilon)
    end
  end

  test "transform_point/2" do
    matrix =
      Matrix.identity()
      |> Matrix.translate(10, 15)
      |> Matrix.scale(5, 3)
      |> Matrix.rotate(:math.pi() / 5)

    p = Matrix.transform_point(matrix, Xairo.Point.new(10, 10))

    assert_in_delta(p.x, 21.0615871, @epsilon)
    assert_in_delta(p.y, 56.9040674, @epsilon)
  end

  test "transform_distance/2" do
    matrix =
      Matrix.identity()
      |> Matrix.translate(10, 15)
      |> Matrix.scale(5, 3)
      |> Matrix.rotate(:math.pi() / 5)

    v = Matrix.transform_distance(matrix, Xairo.Vector.new(10, 10))

    assert_in_delta(v.x, 11.0615871, @epsilon)
    assert_in_delta(v.y, 41.9040674, @epsilon)
  end
end
