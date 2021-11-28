defmodule Xairo.SvgImage do
  @moduledoc """
  `Xairo.SvgImage` provides a wrapper around the in-memory C representation of a
  cairo image that will be rendered to an SVG document.

  In addition to a reference to the C resource, it stores information about the
  `filename`, `width`, `height`, `scale` and `unit` of the cairo image.  The
  width and height are stored as unscaled so that they can be used in
  calculations of userspace while drawing, while ensuring that they are
  correctly scaled on the generated image.

  There are two ways to scale an `SvgImage` up or down. By changing the scale value, or by changing the document unit, though depending on when they are called,
  they differ in their final effect.

  Setting the scale when initializing the image will correctly scale the image's
  final dimensions to match the scale. Calling `Xairo.scale/3` in the middle of
  creating an image will change the scale for any subsequent paths drawn, but will not change the final image size

  Calling `Xairo.set_document_unit/2` at any point during an image's lifecycle
  will update the final unit at which the image is rendered. This can be called
  as many times as you like, but only the last set unit will be used, and it
  will apply to all paths and text rendered as part of the image, regardless
  of when it was called.

  This means that scaling an image up is as easy as either increasing the
  scale value when creating the image, or simply changing the final rendered
  unit to a larger unit.

  As an example, the following code

      iex> image = SvgImage.new("test.svg", 100, 100)
      iex> image |> Xairo.move_to({10, 10}) |> Xairo.line_to({90, 90})

  will produce a 100x100 point image with a line from (10, 10) to (90, 90),
  and this code

      iex> image = SvgImage.new("test.svg", 100, 100, scale: 3, unit: :mm)
      iex> image |> Xairo.move_to({10, 10}) |> Xairo.line_to({90, 90})

  will produce a 300x300 millimeter image with a line from (30, 30) to (270, 270).

  ### Document units

  The document unit for an `SvgImage` can be set in a call to `Xairo.new_svg_image/4`, or by calling `Xairo.set_document_unit/2` at any point during the image lifecycle. This is the unit that will determine the final width and height of the image, and the unit of the coordinate grid for positioning and rendering paths

  Unit types are represented by atoms, and can be any of the following:

  - `:px` - one pixel
  - `:pt` - one point: this is the default unit if none is specified, and is equal to 1.333 pixels
  - `:in` - one inch (96 pixels)
  - `:cm` - one centimeter (~ 37.8 pixels)
  - `:mm` - one millimeter (~ 3.78 pixels)
  - `:pc` - one pica (1/6 inch, 16 pixels)
  - `:em` - the size of the element's font (ends up ~ 12 pixels)
  - `:ex` - the x-height of the element's font (ends up ~ 1/2 of the :em value, or ~ 6 pixels)
  - `:user` - pulled from lower level OS settings. Usually equivalent to a pixel.
  - `:percent` - some percent of another reference value (in my tests, this ends up being 200%)
  """

  defstruct [
    :resource,
    :width,
    :height,
    :scale,
    :unit,
    :reference,
    :filename
  ]

  @type svg_unit ::
          :user
          | :em
          | :ex
          | :px
          | :in
          | :cm
          | :mm
          | :pt
          | :pc
          | :percent

  @type t :: %__MODULE__{
          resource: reference(),
          width: number(),
          height: number(),
          scale: number(),
          unit: svg_unit(),
          reference: reference(),
          filename: String.t()
        }

  @doc """
  Creates a new `SvgImage`

  Takes as required arguments a filename, width, and height. Optional keyword arguments can be giving for `scale` and `unit`.

  The default value for scale is 1.0, and the default value for `unit` is a `point` (about 1 1/3 pixels)

  ## Example

      iex> SvgImage.new("test.svg", 100, 100, scale: 2)

  creates a new image "test.svg" that is 200x200 points in size.

      iex> SvgImage.new("test.svg", 100, 100, unit: :in)

  creates an image "test.svg" that is 100x100 inches in size.
  """
  @spec new(String.t(), number(), number(), Keyword.t() | nil) :: __MODULE__.t()
  def new(filename, width, height, opts \\ []) do
    scale = Keyword.get(opts, :scale, 1.0)
    unit = Keyword.get(opts, :unit, :pt)

    width = width * 1.0
    height = height * 1.0
    scale = scale * 1.0
    scaled_width = scale * width
    scaled_height = scale * height
    {:ok, resource} = Xairo.Native.new_svg_image(scaled_width, scaled_height, filename)
    Xairo.Native.scale(resource, scale, scale)
    Xairo.Native.set_document_unit(resource, unit)

    %__MODULE__{
      filename: filename,
      unit: unit,
      width: width,
      height: height,
      scale: scale,
      resource: resource,
      reference: make_ref()
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(
          %Xairo.SvgImage{
            width: width,
            height: height,
            scale: scale,
            reference: reference,
            unit: unit,
            filename: filename
          },
          opts
        ) do
      concat([
        "#SvgImage<",
        "#{width}x#{height}@#{scale} ",
        "(#{unit})",
        filename,
        to_doc(reference, opts),
        ">"
      ])
    end
  end
end
