defmodule Xairo do
  @moduledoc """
  API functions for using the cairo graphics library in Elixir.
  """

  import Xairo.NativeFn

  alias Xairo.{Arc, Curve, Dashes, Image, Point, RGBA}

  def new_image(width, height, scale \\ 1.0) do
    with {:ok, image} <- Image.new(width, height, scale), do: image
  end

  native_fn(:save_image, [filename])

  def move_to(%Image{} = image, {x, y}) do
    with point <- Point.new(x, y), do: move_to(image, point)
  end

  native_fn(:move_to, [point])

  def line_to(%Image{} = image, {x, y}) do
    with point <- Point.new(x, y), do: line_to(image, point)
  end

  native_fn(:line_to, [point])

  native_fn(:stroke)
  native_fn(:fill)
  native_fn(:paint)

  native_fn(:set_color, [rgba])

  def set_color(%Image{} = image, red, green, blue, alpha \\ 1.0) do
    with %RGBA{} = rgba <- RGBA.new(red, green, blue, alpha) do
      set_color(image, rgba)
    end
  end

  native_fn(:set_line_width, [{width, Float}])

  native_fn(:set_line_cap, [cap])

  native_fn(:set_line_join, [join])

  def set_dash(%Image{} = image, dashes, offset) do
    with %Dashes{} = dashes <- Dashes.new(dashes, offset) do
      set_dash(image, dashes)
    end
  end

  native_fn(:set_dash, [dashes])

  native_fn(:close_path)

  native_fn(:rel_move_to, [{dx, Float}, {dy, Float}])
  native_fn(:rel_line_to, [{dx, Float}, {dy, Float}])

  native_fn(:arc, [arc])

  def arc(%Image{} = image, {x, y}, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(x, y, radius, start_angle, stop_angle) do
      arc(image, arc)
    end
  end

  def arc(%Image{} = image, %Point{} = point, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(point, radius, start_angle, stop_angle) do
      arc(image, arc)
    end
  end

  native_fn(:arc_negative, [arc])

  def arc_negative(%Image{} = image, {x, y}, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(x, y, radius, start_angle, stop_angle) do
      arc_negative(image, arc)
    end
  end

  def arc_negative(%Image{} = image, %Point{} = point, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(point, radius, start_angle, stop_angle) do
      arc_negative(image, arc)
    end
  end

  def curve_to(%Image{} = image, {_, _} = p1, {_, _} = p2, {_, _} = p3) do
    with curve <- Curve.new(p1, p2, p3) do
      curve_to(image, curve)
    end
  end

  def curve_to(%Image{} = image, %Point{} = p1, %Point{} = p2, %Point{} = p3) do
    with curve <- Curve.new(p1, p2, p3) do
      curve_to(image, curve)
    end
  end

  native_fn(:curve_to, [curve])

  native_fn(:rel_curve_to, [
    {cx1, Float},
    {cy1, Float},
    {cx2, Float},
    {cy2, Float},
    {cx3, Float},
    {cy3, Float}
  ])
end
