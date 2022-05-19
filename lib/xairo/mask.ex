defmodule Xairo.Mask do
  @moduledoc """

    Models a cairo surface that can be used as a mask between an image's
    contents and its rendered surface.

    Under the hood `Mask` uses the same native implementation as
    `Xairo.Image.Png`. This means that all drawing or transformation
    operations can be called against a mask just as against any image.
    This struct exists primarily as an explicit separation of concerns
    so that in Eilxir masks are easily contextualized by their struct.

    When a surface is set as a mask for an image, the masking takes
    into account only the alpha values of the mask surface, meaning that
    the main image will be rendered only where the mask is not fully
    transparent, with the alpha values from the mask applied to the
    final image.

    The surface mask is applied via `Xairo.mask_surface/3` which takes as
    its arguments the base image, the mask struct, and a coordinate pair
    defining where the origin of the mask should be set on the base image.
    This coordinate allows the mask to be placed anywhere on the image, or
    placed in more than one location, as in the example below.

    ## Example

    In this example a mask surface contains an opaque rectangle, with
    the rest of the mask being transparent. When it is applied to the
    PNG image, the final result saved to disk will be empty (transparent)
    except for two rectangular regions defined by the multiple placements
    of the mask on the base image.

      iex> mask = Mask.new(100, 100)
      ...> |> Xairo.set_color(RGBA.new(1, 0, 0, 1))
      ...> |> Xairo.rectangle({10, 20}, 50, 40)
      ...> |> Xairo.fill()
      iex> Xairo.new_image("masked.png", 100, 100)
      ...> |> Xairo.set_color(RGBA.new(0, 0, 1, 1))
      ...> |> Xairo.mask_surface(mask, {0, 0})
      ...> |> Xairo.mask_surface(mask, {50, 50})
      ...> |> Xairo.save_image()

  """
  defstruct [
    :resource,
    :width,
    :height,
    :scale
  ]

  @type t :: %__MODULE__{
          resource: reference(),
          width: integer(),
          height: integer(),
          scale: number()
        }

  def new(width, height, options \\ []) do
    scale = Keyword.get(options, :scale, 1.0) * 1.0
    scaled_width = round(scale * width)
    scaled_height = round(scale * height)
    {:ok, resource} = Xairo.Native.new_png_image(scaled_width, scaled_height)
    Xairo.Native.scale(resource, scale, scale)

    %__MODULE__{
      width: width,
      height: height,
      scale: scale,
      resource: resource
    }
  end
end
