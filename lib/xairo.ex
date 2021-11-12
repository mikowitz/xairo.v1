defmodule Xairo do
  @moduledoc """
  API functions for using the cairo graphics library in Elixir.
  """

  alias Xairo.{Dashes, Image, Native, Point, RGBA}

  def new_image(width, height, scale \\ 1.0) do
    with {:ok, image} <- Image.new(width, height, scale), do: image
  end

  def save_image(%Image{} = image, filename) do
    with {:ok, _} <- Native.save_image(image.resource, filename), do: image
  end

  def move_to(%Image{} = image, %Point{} = point) do
    with {:ok, _} <- Native.move_to(image.resource, point), do: image
  end

  def move_to(%Image{} = image, x, y) do
    with point <- Point.new(x, y), do: move_to(image, point)
  end

  def line_to(%Image{} = image, %Point{} = point) do
    with {:ok, _} <- Native.line_to(image.resource, point), do: image
  end

  def line_to(%Image{} = image, x, y) do
    with point <- Point.new(x, y), do: line_to(image, point)
  end

  def stroke(%Image{} = image) do
    with {:ok, _} <- Native.stroke(image.resource), do: image
  end

  def fill(%Image{} = image) do
    with {:ok, _} <- Native.fill(image.resource), do: image
  end

  def paint(%Image{} = image) do
    with {:ok, _} <- Native.paint(image.resource), do: image
  end

  def set_color(%Image{} = image, red, green, blue, alpha \\ 1.0) do
    with %RGBA{} = rgba <- RGBA.new(red, green, blue, alpha) do
      set_color(image, rgba)
    end
  end

  def set_color(%Image{} = image, %RGBA{} = rgba) do
    with {:ok, _} <- Native.set_color(image.resource, rgba), do: image
  end

  def set_line_width(%Image{} = image, line_width) do
    with {:ok, _} <- Native.set_line_width(image.resource, line_width * 1.0), do: image
  end

  def set_line_cap(%Image{} = image, line_cap) do
    with {:ok, _} <- Native.set_line_cap(image.resource, line_cap), do: image
  end

  def set_line_join(%Image{} = image, line_join) when is_atom(line_join) do
    with {:ok, _} <- Native.set_line_join(image.resource, line_join), do: image
  end

  def set_dash(%Image{} = image, dashes, offset) do
    with %Dashes{} = dashes <- Dashes.new(dashes, offset) do
      set_dash(image, dashes)
    end
  end

  def set_dash(%Image{} = image, %Dashes{} = dashes) do
    with {:ok, _} <- Native.set_dash(image.resource, dashes), do: image
  end

  def close_path(%Image{} = image) do
    with {:ok, _} <- Native.close_path(image.resource), do: image
  end
end
