defmodule Xairo.Pattern.MeshTest do
  use ExUnit.Case, async: true

  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Pattern.Mesh, RGBA}

  doctest Mesh

  test "drawing with meshes" do
    mesh1 =
      Mesh.new({0, 0})
      |> Mesh.curve_to({30, -30}, {60, 30}, {100, 0})
      |> Mesh.curve_to({60, 30}, {130, 60}, {100, 100})
      |> Mesh.curve_to({60, 70}, {30, 130}, {0, 100})
      |> Mesh.curve_to({30, 70}, {-30, 30}, {0, 0})
      |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0))
      |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0))
      |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1))
      |> Mesh.set_corner_color(3, RGBA.new(1, 1, 0))

    mesh2 =
      Mesh.new({0, 0})
      |> Mesh.line_to({100, 100})
      |> Mesh.line_to({20, 100})
      |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0))
      |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0))
      |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1))

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
        Mesh.new({0, 0})
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

      Xairo.new_image("mesh_with_control_points.png", 100, 100, scale: 2)
      |> Xairo.set_source(mesh)
      |> Xairo.paint()
      |> assert_image("mesh_with_control_points.png")
    end
  end
end
