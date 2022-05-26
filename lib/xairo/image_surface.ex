defmodule Xairo.ImageSurface do
  @moduledoc false

  defstruct [:resource]

  def new(format, width, height) do
    with {:ok, image_surface} <- Xairo.Native.image_surface_create(format, width, height) do
      %__MODULE__{
        resource: image_surface
      }
    end
  end

  def format(%__MODULE__{resource: resource}) do
    Xairo.Native.image_surface_format(resource)
  end

  def width(%__MODULE__{resource: resource}) do
    Xairo.Native.image_surface_width(resource)
  end

  def height(%__MODULE__{resource: resource}) do
    Xairo.Native.image_surface_height(resource)
  end

  def stride(%__MODULE__{resource: resource}) do
    Xairo.Native.image_surface_stride(resource)
  end

  def write_to_png(%__MODULE__{resource: resource}, filename) do
    Xairo.Native.image_surface_write_to_png(resource, filename)
  end
end
