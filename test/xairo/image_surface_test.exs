defmodule Xairo.ImageSurfaceTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.ImageSurface

  setup do
    surface = ImageSurface.new(:argb32, 100, 100)

    {:ok, surface: surface}
  end

  describe "new/3" do
    test "returns a new ImageSurface", %{surface: surface} do
      assert is_struct(surface, ImageSurface)
    end

    test "returns an error if the dimensions are too large" do
      assert ImageSurface.new(:argb32, 100_000, 100_000) ==
               {:error, :invalid_size}
    end
  end

  describe "format/1" do
    test "returns the format of the surface", %{surface: surface} do
      assert ImageSurface.format(surface) == :argb32
    end
  end

  describe "retrieving dimensions" do
    test "width/1 returns the width", %{surface: surface} do
      assert ImageSurface.width(surface) == 100
    end

    test "height/1 returns height", %{surface: surface} do
      assert ImageSurface.height(surface) == 100
    end

    test "stride/1 returns stride", %{surface: surface} do
      assert ImageSurface.stride(surface) == 400
    end
  end

  describe "write_to_png/2" do
    test "successfully writes to disk", %{surface: surface} do
      ImageSurface.write_to_png(surface, "image_surface.png")

      assert File.exists?("image_surface.png")

      assert hash("image_surface.png") == hash("test/images/image_surface.png")

      :ok = File.rm("image_surface.png")
    end
  end
end
