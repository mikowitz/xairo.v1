defmodule Xairo.Matrix do
  @moduledoc """
  Defines a matrix for an affine transformation.

  This matrix definition allows for scaling, shearing and translation
  along the x and y axes.

  It models these values as follows:

  - `xx`: scaling along the x axis
  - `yy`: scaling along the y axis
  - `xy`: shearing along the x axis (positive numbers shear left, negative numbers shear right)
  - `yx`: shearing along the y axis (positive numbers shear down, negative numbers shear up)
  - `xt`: translation along the x axis
  - `yt`: translation along the y axis

  ## Default values

  `xx` and `yy` default to 1.0, the other fields default to 0.0. This results in having no effect on whatever the matrix is used to transform, with one important caveat...

  ### The Caveat

  This isn't exactly true for fonts. For a font, `xx` and `yy` defaulted to 1.0 would actually scale the font to 1.0, which is unreadably small except at very high scale. If creating a matrix to be used to transform a font, you should find the current font size and set `xx` and `yy` accordingly. If you have called `Xairo.set_font_size/2` previously in your code, the value you passed to that function will be the current font size. If you have not, the default font size is 10.
  """
  defstruct xx: 1.0,
            yy: 1.0,
            xy: 0.0,
            yx: 0.0,
            xt: 0.0,
            yt: 0.0

  @type t :: %__MODULE__{
          xx: number(),
          yy: number(),
          xy: number(),
          yx: number(),
          xt: number(),
          yt: number()
        }

  @doc """
  Creates a new affine transformation matrix.

  ## Examples

  With no arguments given, the matrix is set to its default values

      iex> Matrix.new()
      #Matrix<1.0, 1.0, 0.0, 0.0, 0.0, 0.0>

  With shearing

      iex> Matrix.new(xy: -10, yx: 7)
      #Matrix<1.0, 1.0, -10.0, 7.0, 0.0, 0.0>

  """
  @spec new(keyword(number())) :: __MODULE__.t()
  def new(opts \\ []) do
    opts = Enum.map(opts, fn {k, v} -> {k, v * 1.0} end)
    struct(__MODULE__, opts)
  end

  def identity, do: new()

  def translate(%__MODULE__{} = matrix, xt, yt) do
    Xairo.Native.matrix_translate(matrix, xt * 1.0, yt * 1.0)
  end

  def scale(%__MODULE__{} = matrix, xx, yy) do
    Xairo.Native.matrix_scale(matrix, xx * 1.0, yy * 1.0)
  end

  def rotate(%__MODULE__{} = matrix, radians) do
    Xairo.Native.matrix_rotate(matrix, radians * 1.0)
  end

  def invert(%__MODULE__{} = matrix) do
    with {:ok, matrix} <- Xairo.Native.matrix_invert(matrix) do
      matrix
    end
  end

  def multiply(%__MODULE__{} = matrix1, %__MODULE__{} = matrix2) do
    Xairo.Native.matrix_multiply(matrix1, matrix2)
  end

  alias Xairo.{Point, Vector}

  def transform_point(%__MODULE__{} = matrix, %Point{} = point) do
    Xairo.Native.matrix_transform_point(matrix, point)
  end

  def transform_distance(%__MODULE__{} = matrix, %Vector{} = vector) do
    Xairo.Native.matrix_transform_distance(matrix, vector)
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(matrix, _opts) do
      concat([
        "#Matrix<",
        [
          matrix.xx,
          matrix.yy,
          matrix.xy,
          matrix.yx,
          matrix.xt,
          matrix.yt
        ]
        |> Enum.join(", "),
        ">"
      ])
    end
  end
end
