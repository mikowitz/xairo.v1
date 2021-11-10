defmodule Xairo do
  @moduledoc """
  API functions for using the cairo graphics library in Elixir.
  """

  alias Xairo.{Native, Point}

  def new_image(width, height) do
    with {:ok, image} <- Native.new_image(width, height), do: image
  end

  def save_image(image, filename) do
    with {:ok, image} <- Native.save_image(image, filename), do: image
  end

  def move_to(image, %Point{} = point) do
    with {:ok, image} <- Native.move_to(image, point), do: image
  end

  def move_to(image, x, y) do
    with point <- Point.new(x, y), do: move_to(image, point)
  end

  def line_to(image, %Point{} = point) do
    with {:ok, image} <- Native.line_to(image, point), do: image
  end

  def line_to(image, x, y) do
    with point <- Point.new(x, y), do: line_to(image, point)
  end

  def stroke(image) do
    with {:ok, image} <- Native.stroke(image), do: image
  end
end
