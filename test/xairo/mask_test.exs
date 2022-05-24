defmodule Xairo.MaskTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Pattern.LinearGradient, Pattern.Mesh, Pattern.RadialGradient, RGBA}

  alias Xairo.Mask

  setup do
    linear =
      LinearGradient.new({10, 10}, {90, 90})
      |> LinearGradient.add_color_stop(0.25, RGBA.new(1, 0, 0))
      |> LinearGradient.add_color_stop(0.95, RGBA.new(0.5, 0.5, 1))

    image =
      Xairo.new_image("mask_testing.png", 100, 100)
      |> Xairo.set_source(linear)

    {:ok, %{image: image}}
  end

  test "masking with a radial gradient", %{image: image} do
    mask =
      RadialGradient.new({50, 50}, 0, {50, 50}, 50)
      |> RadialGradient.add_color_stop(0, RGBA.new(0, 0, 0, 1))
      |> RadialGradient.add_color_stop(1, RGBA.new(0, 0, 0, 0))

    image
    |> Xairo.mask(mask)
    |> assert_image("masked.png")
  end

  test "masking with a linear gradient", %{image: image} do
    mask =
      LinearGradient.new({90, 10}, {0, 95})
      |> LinearGradient.add_color_stop(0.0, RGBA.new(0, 0, 0, 1))
      |> LinearGradient.add_color_stop(0.8, RGBA.new(0, 0, 0, 0))

    image
    |> Xairo.mask(mask)
    |> assert_image("masked_linear.png")
  end

  test "masking with a mesh", %{image: image} do
    mask =
      Mesh.new()
      |> Mesh.begin_patch()
      |> Mesh.move_to({0, 0})
      |> Mesh.curve_to({30, -30}, {60, 30}, {100, 0})
      |> Mesh.curve_to({60, 30}, {130, 60}, {100, 100})
      |> Mesh.curve_to({60, 70}, {130, 130}, {0, 100})
      |> Mesh.curve_to({30, 70}, {-30, 30}, {0, 0})
      |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0, 1))
      |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0, 0.1))
      |> Mesh.set_corner_color(2, RGBA.new(0, 0, 1, 0.8))
      |> Mesh.set_corner_color(3, RGBA.new(1, 1, 0, 0.2))
      |> Mesh.end_patch()

    image
    |> Xairo.mask(mask)
    |> assert_image("masked_mesh.png")
  end

  test "masking with a surface", %{image: image} do
    mask =
      Mask.new(100, 100)
      |> Xairo.set_color(RGBA.new(1, 0, 0, 1))
      |> Xairo.rectangle({10, 20}, 50, 40)
      |> Xairo.fill()

    image
    |> Xairo.mask_surface(mask, {0, 0})
    |> Xairo.mask_surface(mask, {30, 50})
    |> assert_image("masked_surface.png")
  end
end
