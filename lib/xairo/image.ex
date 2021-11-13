defmodule Xairo.Image do
  @moduledoc """
  `Xairo.Image` provides a wrapper around the in-memory C representation of a
  cairo image.

  In addition to a reference to the C resource, it stores information about the
  `width`, `height`, and `scale` of the cairo image. The width and height are
  stored as unscaled so that they can be used in calculations of imagespace
  while drawing, while ensuring that they are correctly scaled on the generated
  image.

  This means that scaling an image up is as easy as increasing the scale value
  when creating the image, rather than having to recalculate the values for
  every subsequent operation.

  As an example, the following code

      iex> image = Image.new(100, 100, 1)
      iex> image |> Xairo.move_to(10, 10) |> Xairo.line_to(90, 90)

  will produce a 100x100 pixel image with a line from (10, 10) to (90, 90),
  and this code

      iex> image = Image.new(100, 100, 3)
      iex> image |> Xairo.move_to(10, 10) |> Xairo.line_to(90, 90)

  will produce a 300x300 pixel image with a line from (30, 30) to (270, 270).

  """

  defstruct [
    :resource,
    :width,
    :height,
    :scale,
    :reference
  ]

  @type t :: %__MODULE__{
          resource: reference(),
          width: integer(),
          height: integer(),
          scale: number(),
          reference: reference()
        }

  @doc """
  Creates a new Xairo.Image struct to wrap the native cairo resource

  The `width` and `height` stored in this struct are the unscaled values,
  while the cairo resource does have the correct scaling applied. This is to
  ensure that drawing operations can be performed relative to the `Xairo.Image`
  canvas space, but will be scaled appropriately on the drawn image.

  This means that scaling an image up is as easy as increasing the scale value
  when creating the image, rather than having to recalculate the values for
  every subsequent operation.

  As an example, the following code

      iex> image = Image.new(100, 100, 2)
      iex> image |> Xairo.move_to(10, 10) |> Xairo.line_to(90, 90)

  will produce a 200x200 pixel image with a line from (20, 20) to (180, 180).
  """
  @spec new(number(), number(), number() | nil) :: __MODULE__.t()
  def new(width, height, scale \\ 1.0)
      when is_integer(width) and is_integer(height) and is_number(scale) do
    with scale <- scale * 1.0,
         scaled_width <- round(scale * width),
         scaled_height <- round(scale * height),
         {:ok, resource} <- Xairo.Native.new_image(scaled_width, scaled_height) do
      Xairo.Native.scale(resource, scale, scale)

      %__MODULE__{
        width: width,
        height: height,
        scale: scale,
        resource: resource,
        reference: make_ref()
      }
    end
  end

  defimpl Inspect do
    def inspect(
          %Xairo.Image{width: width, height: height, scale: scale, reference: reference},
          opts
        ) do
      [
        "#Image<",
        "#{width}x#{height}@#{scale} ",
        Inspect.Algebra.to_doc(reference, opts),
        ">"
      ]
      |> Enum.join("")
    end
  end
end
