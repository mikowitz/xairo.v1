defmodule Xairo.ImageSurface do
  @moduledoc false

  defstruct [:surface]

  def new(format, width, height) do
    with {:ok, image_surface} <- Xairo.Native.image_surface_create(format, width, height) do
      %__MODULE__{
        surface: image_surface
      }
    end
  end

  def format(%__MODULE__{surface: surface}) do
    Xairo.Native.image_surface_format(surface)
  end

  def width(%__MODULE__{surface: surface}) do
    Xairo.Native.image_surface_width(surface)
  end

  def height(%__MODULE__{surface: surface}) do
    Xairo.Native.image_surface_height(surface)
  end

  def stride(%__MODULE__{surface: surface}) do
    Xairo.Native.image_surface_stride(surface)
  end

  def write_to_png(%__MODULE__{surface: surface}, filename) do
    Xairo.Native.image_surface_write_to_png(surface, filename)
  end
end
