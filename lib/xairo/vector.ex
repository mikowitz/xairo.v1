defmodule Xairo.Vector do
  @moduledoc """
  Models a two-dimensional vector in userspace.

  Ensures that `x` and `y` are stored as floats to match Rust's type expectations

      iex> Vector.new(3, 4)
      #Vector<(3.0, 4.0)>

  """

  alias Xairo.Image

  defstruct [:x, :y]

  @type t :: %__MODULE__{
          x: number(),
          y: number()
        }

  @doc """
  Creates a two-dimensional vector positioned absolutely in userspace.

  ## Example

      iex> Vector.new(30, -35)
      #Vector<(30.0, -35.0)>

  """
  @spec new(number(), number()) :: __MODULE__.t()
  def new(x, y) when is_number(x) and is_number(y) do
    %__MODULE__{
      x: x * 1.0,
      y: y * 1.0
    }
  end

  @doc """
  Returns a Vector, if possible, from the arguments.

  Argument can be any of

  - a `t:Xairo.Vector.t/0` struct
  - a 2-element numeric tuple
  - two numeric arguments

  ## Examples

    iex> Vector.from(Vector.new(1, -2))
    #Vector<(1.0, -2.0)>

    iex> Vector.from({-3, 4})
    #Vector<(-3.0, 4.0)>

    iex> Vector.from(5, 6)
    #Vector<(5.0, 6.0)>

  """
  @spec from(__MODULE__.t()) :: __MODULE__.t()
  @spec from({number(), number()}) :: __MODULE__.t()
  @spec from(number(), number()) :: __MODULE__.t()
  def from(%__MODULE__{} = point), do: point

  def from({x, y}) when is_number(x) and is_number(y) do
    __MODULE__.new(x, y)
  end

  def from(x, y) when is_number(x) and is_number(y) do
    __MODULE__.new(x, y)
  end

  @doc """
  Converts a vector from userspace to image/device space.

  This operation uses the image's current transformation matrix to make the calculation,
  and the translation component of the image's CTM.
  """
  @spec user_to_device(__MODULE__.t(), Image.t()) :: __MODULE__.t() | Xairo.error()
  def user_to_device(%__MODULE__{} = vector, %Image{} = image) do
    with {:ok, %__MODULE__{} = vector} <-
           Xairo.Native.user_to_device_distance(image.resource, vector) do
      vector
    end
  end

  @doc """
  Converts a vector from image/device space to userspace.

  This operation uses the image's current transformation matrix to make the calculation,
  and the translation component of the image's CTM.
  """
  @spec device_to_user(__MODULE__.t(), Image.t()) :: __MODULE__.t() | Xairo.error()
  def device_to_user(%__MODULE__{} = vector, %Image{} = image) do
    with {:ok, %__MODULE__{} = vector} <-
           Xairo.Native.device_to_user_distance(image.resource, vector) do
      vector
    end
  end

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(%Xairo.Vector{x: x, y: y}, _opts) do
      concat([
        "#Vector<(",
        [x, y] |> Enum.join(", "),
        ")>"
      ])
    end
  end
end
