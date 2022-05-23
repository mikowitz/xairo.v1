defmodule Xairo.Extents do
  @moduledoc """
    Stores the extents values for an image at a given point in its creation.

    Stores values for the path extents, fill extents, and stroke extents
    of the image.

    Each set of extents is stored as two `Point` structs, which represent
    the upper left and lower right corners of the bounding rectangle
    that covers the points defined by the extent's definition.

    Path extents calculate the bounding box of the points drawn onto
    the image's path by functions like `Xairo.line_to/2`, `Xairo.arc/2`, etc.

    Fill extents calculate the bounding box of the area that would be
    affected by a call to `Xairo.fill/1`. That is, the area that would
    be rendered as filled in on the final image.

    Stroke extents calculate the bounding box of the area that would be
    affected by a call to `Xairo.stroke/1`. Note that the dimensions of
    this rectangle *do* take into account the line width and line cap
    style defined for the image at the time the extents are calculated.

    For all extents, if the current path is empty, the calculated value will
    return an empty rectangle.

  """
  defstruct [:path, :fill, :stroke]

  def new(%{resource: _} = image) do
    with {:ok, %__MODULE__{} = extents} <- Xairo.Native.extents(image.resource), do: extents
  end

  def get(%__MODULE__{} = extents, type) do
    Map.get(extents, type)
  end
end
