defmodule Xairo.Image.PsTest do
  import Xairo.Helpers.ImageHelpers

  use ExUnit.Case, async: true

  alias Xairo.Image.Ps

  test "creating a basic ps document" do
    Ps.new("basic.ps", 100, 100)
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.paint()
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.move_to({90, 10})
    |> Xairo.line_to({10, 90})
    |> Xairo.stroke()
    |> assert_image()
  end
end
