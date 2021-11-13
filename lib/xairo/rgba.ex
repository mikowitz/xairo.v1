defmodule Xairo.RGBA do
  import Bitwise

  @moduledoc """
  Models a color in RGBA (red, green, blue, alpha) colorspace.

  Values passed to `new/4` can be given as floats in the range [0.0, 1.0] or
  integers in the range [0, 255].

      iex> RGBA.new(0.5, 0, 1)
      #RGBA<0.5, 0.0, 1.0, 1.0>

  While it can be easier for those used to working with RGB colors to think
  about creating them using integers, the values that are stored in the
  struct are normalized to floats in the range [0.0, 1.0].

      iex> RGBA.new(100, 0, 255, 100)
      #RGBA<0.39, 0.0, 1.0, 0.39>

  Colors can also be created from a single integer representing a hex code for
  an RGB(A) value. The alpha value is set in the highest 8 bits of the value.

      iex> RGBA.new(0x10161b)
      #RGBA<0.06, 0.09, 0.11, 1.0>

      iex> RGBA.new(0xf010161b)
      #RGBA<0.06, 0.09, 0.11, 0.94>

  The alpha value defaults to 1.0 (fully opaque).
  """

  defstruct [:red, :green, :blue, :alpha]

  @type t :: %__MODULE__{
          red: number(),
          green: number(),
          blue: number(),
          alpha: number()
        }

  @doc """
  Creates a new color struct from numeric red, green, blue, and alpha values.

  The values given for the red, green, blue, and alpha values can be given
  in float values [0.0, 1.0] or integer values [0, 255].

  In either case, the values are normalized and stored in the struct in the
  range [0.0, 1.0].

  If no alpha value is given, it defaults to 1.0 (fully opaque).

  ## Examples

      iex> RGBA.new(0.5, 0, 1)
      #RGBA<0.5, 0.0, 1.0, 1.0>

  The values can be passed in as a combination of float and integer values

      iex> RGBA.new(100, 50, 255, 0.5)
      #RGBA<0.39, 0.2, 1.0, 0.5>

  """
  @spec new(number(), number(), number(), number() | nil) :: __MODULE__.t()
  def new(red, green, blue, alpha \\ 1.0) do
    %__MODULE__{
      red: normalize(red),
      green: normalize(green),
      blue: normalize(blue),
      alpha: normalize(alpha)
    }
  end

  @doc """
  Creates a new color struct from a hex RGB(A) color value.

  If the value takes only 24 bits of data, it is interpreted as only containing
  red, green, and blue values, and the alpha value defaults to fully opaque

      iex> RGBA.new(0x10161b)
      #RGBA<0.06, 0.09, 0.11, 1.0>

  If the value is greater than 0xffffff (the largest value that fits in 24 bits),
  the highest 8 bits are interpreted as the alpha value, and the lower 24 bits as
  red, green, and blue.

      iex> RGBA.new(0xf010161b)
      #RGBA<0.06, 0.09, 0.11, 0.94>

  There is one caveat, which is that this format can not be used to explicitly
  set a fully transparent color, since if the highest 8 bits are equal to 0,
  they will be ignored and the alpha value will default to opaque.

  As fully transparent colors are of little use in 2d graphics, allowing the
  shorthand of not needing to explicity specify the highest bits for fully
  opaque values feels like a reasonable tradeoff.

  Thus, in order to create a fully transparent color, you will need to use `new/4`
  with a final argument of `0`.
  """
  @spec new(number()) :: __MODULE__.t()
  def new(hex) when hex < 0x1000000 do
    with red <- hex >>> 16 &&& 0xFF,
         green <- hex >>> 8 &&& 0xFF,
         blue <- hex &&& 0xFF do
      new(red, green, blue)
    end
  end

  def new(hex) when hex >= 0x1000000 do
    with alpha <- hex >>> 24 &&& 0xFF,
         red <- hex >>> 16 &&& 0xFF,
         green <- hex >>> 8 &&& 0xFF,
         blue <- hex &&& 0xFF do
      new(red, green, blue, alpha)
    end
  end

  defp normalize(n) when n <= 1, do: n * 1.0

  defp normalize(n) when n > 1 do
    Float.round(n / 255, 2)
  end

  defimpl Inspect do
    def inspect(%Xairo.RGBA{red: r, green: g, blue: b, alpha: a}, _opts) do
      [
        "#RGBA<",
        [r, g, b, a] |> Enum.join(", "),
        ">"
      ]
      |> Enum.join("")
    end
  end
end
