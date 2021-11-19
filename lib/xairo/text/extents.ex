defmodule Xairo.Text.Extents do
  @moduledoc """
  Models the extents for a text string.

  These extents describe a rectangle in imagespace around the rendered portion of the text,
  as well as the amounts by which the x and y coordinates of the current point would be advanced
  by passing the text to `Xairo.show_text/2`.

  The text whose extents are defined are stored as well, along with the font size for which the
  extents are generated.

  ## Descriptions of the fields

  - `text`: the text whose extents are defined by the struct
  - `font_size`: the font size with which the extents are calculated. This value will be the
    value most recently passed to `Xairo.set_font_size/2` before `Xairo.Text.extents/2` was called. If this has not been called, the default font size is 10.0.
  - `x_bearing` and `y_bearing`: the horizontal and vertical distance from the origin to
    the top-left-most corner of the rendered text
  - `width` and `height`: the width and height of the rendered text
  - `x_advance` and `y_advance`: the amounts by which the x and y coordinates of the current point
    would be shifted (to the right and down, respectively) after calling `Xairo.show_text/2`.
  """
  defstruct [
    :text,
    :font_size,
    :x_bearing,
    :y_bearing,
    :width,
    :height,
    :x_advance,
    :y_advance
  ]

  @type t :: %__MODULE__{
          text: String.t(),
          font_size: number(),
          x_bearing: number(),
          y_bearing: number(),
          width: number(),
          height: number(),
          x_advance: number(),
          y_advance: number()
        }

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%{text: text, font_size: font_size}, _opts) do
      concat([
        "#TextExtents<",
        text <> " @" <> to_string(font_size),
        ">"
      ])
    end
  end
end
