defmodule Xairo.ContextTest do
  use ExUnit.Case, async: true
  import Xairo.Helpers.ImageHelpers

  alias Xairo.{Context, ImageSurface}

  setup do
    surface = ImageSurface.new(:argb32, 100, 100)
    context = Context.new(surface)

    {:ok, context: context, surface: surface}
  end

  describe "new/1" do
    test "returns a new Context", %{context: context} do
      assert is_struct(context, Context)
    end
  end

  describe "status/1" do
    test "returns the context's status", %{context: context} do
      assert Context.status(context) == :ok
    end
  end

  describe "basic drawing" do
    test "move_to, line_to, set_source_rgb, paint, stroke, fill", %{
      context: context,
      surface: surface
    } do
      context
      |> Context.set_source_rgb(1, 1, 1)
      |> Context.paint()
      |> Context.set_source_rgb(1, 0, 0)
      |> Context.move_to(20, 50)
      |> Context.line_to(50, 60)
      |> Context.stroke()
      |> Context.set_source_rgb(0, 1, 1)
      |> Context.move_to(50, 60)
      |> Context.line_to(80, 80)
      |> Context.line_to(30, 75)
      |> Context.close_path()
      |> Context.fill()

      ImageSurface.write_to_png(surface, "basic_lines.png")

      assert File.exists?("basic_lines.png")

      assert hash("basic_lines.png") == hash("test/images/basic_lines.png")

      :ok = File.rm("basic_lines.png")
    end

    test "set_source_rgba, fill_preserve, stroke_preserve, paint_with_alpha, rectangle", %{
      context: context,
      surface: surface
    } do
      context
      |> Context.set_source_rgb(1, 0, 0)
      |> Context.paint_with_alpha(0.5)
      |> Context.set_source_rgba(0, 1, 0, 0.2)
      |> Context.rectangle(20, 20, 30, 60)
      |> Context.fill_preserve()
      |> Context.set_source_rgba(0, 0, 1, 0.5)
      |> Context.stroke_preserve()
      |> Context.set_source_rgba(0, 1, 0, 0.2)
      |> Context.fill()

      ImageSurface.write_to_png(surface, "basic_drawing2.png")

      assert File.exists?("basic_drawing2.png")

      assert hash("basic_drawing2.png") == hash("test/images/basic_drawing2.png")

      :ok = File.rm("basic_drawing2.png")
    end
  end
end
