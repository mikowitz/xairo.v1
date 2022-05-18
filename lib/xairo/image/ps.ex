defmodule Xairo.Image.Ps do
  @moduledoc """
  `Xairo.Image.Pdf` provides a wrapper around the in-memory C representation of a
  cairo image that renders out to a PDF file on disk.

  In addition to a reference to the C resource, it stores information about the
  `width`, `height`, and `scale` of the cairo image. The width and height are
  stored as unscaled so that they can be used in calculations of userspace
  while drawing, while ensuring that they are correctly scaled on the generated
  image.

  This means that scaling an image up is as easy as increasing the scale value
  when creating the image, rather than having to recalculate the values for
  every subsequent operation.

  As an example, the following code

      iex> ps = Ps.new(100, 100, scale: 2)
      iex> ps |> Xairo.move_to({10, 90}) |> Xairo.line_to({90, 10})

  will produce a 200x200 pixel PDF image with a line from (20, 180) to (180, 20).

  """

  defstruct [
    :resource,
    :width,
    :height,
    :filename,
    :scale
  ]

  @type t :: %__MODULE__{
          resource: reference(),
          width: number(),
          height: number(),
          scale: number(),
          filename: String.t()
        }

  @doc """
    Creates a new `Ps` Image

    Takes as required arguments a filename, width, and height. An optional
    keyword argument can be given for `scale` (default is 1.0)

    ## Example

      iex> Ps.new("test.ps", 100, 100)

    creates a new image "test.ps" that is 100x100 pixels in size, and

      iex> Ps.new("test.ps", 100, 100, scale: 3)

    creates a new image "test.ps" that is 300x300 pixels in size.

  """
  @behaviour Xairo.Image
  @spec new(String.t(), number(), number(), Keyword.t() | nil) :: __MODULE__.t()
  def new(filename, width, height, opts \\ []) do
    scale = Keyword.get(opts, :scale, 1.0)

    width = width * 1.0
    height = height * 1.0
    scale = scale * 1.0
    scaled_width = scale * width
    scaled_height = scale * height
    {:ok, resource} = Xairo.Native.new_ps_image(scaled_width, scaled_height, filename)
    Xairo.Native.scale(resource, scale, scale)

    %__MODULE__{
      filename: filename,
      width: width,
      height: height,
      scale: scale,
      resource: resource
    }
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(
          %Xairo.Image.Ps{
            width: width,
            height: height,
            scale: scale,
            resource: resource,
            filename: filename
          },
          opts
        ) do
      concat([
        "#Xairo.Image.Ps<",
        "#{width}x#{height}@#{scale} ",
        filename,
        " ",
        to_doc(resource, opts),
        ">"
      ])
    end
  end
end
