defmodule Xairo.Image.PdfTest do
  import Xairo.Helpers.ImageHelpers

  use ExUnit.Case, async: true

  alias Xairo.Image.Pdf

  @tag :pdf
  test "creating a basic pdf document" do
    Pdf.new("basic.pdf", 100, 100)
    |> Xairo.set_color(0.5, 0, 1)
    |> Xairo.paint()
    |> Xairo.set_color(1, 1, 1)
    |> Xairo.move_to({10, 10})
    |> Xairo.line_to({90, 90})
    |> Xairo.stroke()
    |> assert_image()
  end
end
