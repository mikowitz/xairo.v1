# test/xairo/svg_image_test.exs
defmodule Xairo.Image.SvgTest do
  import Xairo.Helpers.ImageHelpers
  use ExUnit.Case, async: true

  alias Xairo.Image.Svg
  doctest Svg

  setup do
    on_exit(fn ->
      File.rm("test.svg")
    end)
  end

  test "creating a basic image" do
    Xairo.new_image("basic.svg", 100, 100, unit: :pc)
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.paint()
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.move_to({10, 10})
    |> Xairo.line_to({90, 90})
    |> Xairo.stroke()
    |> assert_image()
  end
end
