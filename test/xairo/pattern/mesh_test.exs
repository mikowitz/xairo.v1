defmodule Xairo.Pattern.MeshTest do
  use ExUnit.Case, async: true

  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Pattern.Mesh, Point, RGBA}

  doctest Mesh

  test "drawing with meshes" do
    mesh1 =
      Mesh.new()
      |> Mesh.begin_patch()
      |> Mesh.move_to({0, 0})
      |> Mesh.curve_to({30, -30}, {60, 30}, {100, 0})
      |> Mesh.curve_to({60, 30}, {130, 60}, {100, 100})
      |> Mesh.curve_to({60, 70}, {30, 130}, {0, 100})
      |> Mesh.curve_to({30, 70}, {-30, 30}, {0, 0})
      |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0))
      |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0))
      |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1))
      |> Mesh.set_corner_color(3, RGBA.new(1, 1, 0))
      |> Mesh.end_patch()

    mesh2 =
      Mesh.new()
      |> Mesh.begin_patch()
      |> Mesh.move_to({0, 0})
      |> Mesh.line_to({100, 100})
      |> Mesh.line_to({20, 100})
      |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0))
      |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0))
      |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1))
      |> Mesh.end_patch()

    Xairo.new_image("mesh.png", 100, 100, scale: 2)
    |> Xairo.set_source(mesh1)
    |> Xairo.paint()
    |> Xairo.set_source(mesh2)
    |> Xairo.paint()
    |> assert_image("mesh.png")
  end

  describe "control points" do
    setup do
      mesh =
        Mesh.new()
        |> Mesh.begin_patch()
        |> Mesh.move_to({0, 0})
        |> Mesh.line_to({100, 0})
        |> Mesh.line_to({100, 100})
        |> Mesh.line_to({0, 100})
        |> Mesh.line_to({0, 0})
        |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0))
        |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0))
        |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1))
        |> Mesh.set_corner_color(3, RGBA.new(0.5, 0, 1))

      {:ok, mesh: mesh}
    end

    test "with no control points", %{mesh: mesh} do
      mesh = Mesh.end_patch(mesh)

      Xairo.new_image("mesh_no_control_points.png", 100, 100, scale: 2)
      |> Xairo.set_source(mesh)
      |> Xairo.paint()
      |> assert_image("mesh_no_control_points.png")
    end

    test "with control points", %{mesh: mesh} do
      mesh =
        mesh
        |> Mesh.set_control_point(1, {0, 100})
        |> Mesh.set_control_point(2, {150, -50})
        |> Mesh.end_patch()

      Xairo.new_image("mesh_with_control_points.png", 100, 100, scale: 2)
      |> Xairo.set_source(mesh)
      |> Xairo.paint()
      |> assert_image("mesh_with_control_points.png")
    end
  end

  describe "multiple patches" do
    test "can be rendered via a single pattern" do
      mesh =
        Mesh.new()
        |> Mesh.begin_patch()
        |> Mesh.move_to({0, 0})
        |> Mesh.curve_to({30, -30}, {60, 30}, {100, 0})
        |> Mesh.curve_to({60, 30}, {160, 60}, {100, 100})
        |> Mesh.curve_to({60, 70}, {60, 130}, {0, 100})
        |> Mesh.curve_to({30, 70}, {-30, 30}, {0, 0})
        |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0, 1))
        |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0, 0.5))
        |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1, 0.75))
        |> Mesh.set_corner_color(3, RGBA.new(0.5, 0, 1, 0.3))
        |> Mesh.end_patch()
        |> Mesh.begin_patch()
        |> Mesh.move_to({20, 20})
        |> Mesh.line_to({80, 75})
        |> Mesh.line_to({30, 80})
        |> Mesh.line_to({20, 20})
        |> Mesh.set_corner_color(0, RGBA.new(1, 1, 0, 0.5))
        |> Mesh.set_corner_color(1, RGBA.new(1, 0, 1, 0.75))
        |> Mesh.set_corner_color(2, RGBA.new(0, 1, 1, 0.3))
        |> Mesh.end_patch()

      Xairo.new_image("mesh_multiple_patches.png", 100, 100)
      |> Xairo.set_source(mesh)
      |> Xairo.paint()
      |> assert_image()
    end
  end

  describe "control_point/3" do
    mesh =
      Mesh.new()
      |> Mesh.begin_patch()
      |> Mesh.move_to({0, 0})
      |> Mesh.curve_to({30, -30}, {60, 30}, {100, 0})
      |> Mesh.curve_to({60, 30}, {160, 60}, {100, 100})
      |> Mesh.curve_to({60, 70}, {60, 130}, {0, 100})
      |> Mesh.curve_to({30, 70}, {-30, 30}, {0, 0})
      |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0, 1))
      |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0, 0.5))
      |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1, 0.75))
      |> Mesh.set_corner_color(3, RGBA.new(0.5, 0, 1, 0.3))
      |> Mesh.end_patch()
      |> Mesh.begin_patch()
      |> Mesh.move_to({20, 20})
      |> Mesh.line_to({80, 75})
      |> Mesh.line_to({30, 80})
      |> Mesh.line_to({20, 20})
      |> Mesh.set_corner_color(0, RGBA.new(1, 1, 0, 0.5))
      |> Mesh.set_corner_color(1, RGBA.new(1, 0, 1, 0.75))
      |> Mesh.set_corner_color(2, RGBA.new(0, 1, 1, 0.3))
      |> Mesh.set_control_point(1, {0, 100})
      |> Mesh.set_control_point(2, {150, -50})
      |> Mesh.end_patch()

    assert Mesh.control_point(mesh, 0, 0) == Point.new(6.666666666666666, 20)

    assert Mesh.control_point(mesh, 1, 1) == Point.new(0, 100)
    assert Mesh.control_point(mesh, 1, 2) == Point.new(150, -50)

    assert Mesh.control_point(mesh, 2, 0) ==
             {:error, "No control point set for corner 0 of patch 2"}
  end
end
