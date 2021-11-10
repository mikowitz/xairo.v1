defmodule Xairo do
  @moduledoc """
  API functions for using the cairo graphics library in Elixir.
  """

  alias Xairo.{Image, Native, Point}

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
end
