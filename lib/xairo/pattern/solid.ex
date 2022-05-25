defmodule Xairo.Pattern.Solid do
  @moduledoc """
    Models a pattern containing a single color.

    A solid pattern requires one piece of data:

    - a single `Xairo.RGBA` value defining the color drawn by the pattern.

    ## Example

    Defines a simple solid pattern containing the color purple, 75% opaque

    ```
    pattern = Solid.new(RGBA.new(1, 0, 1, 0.75)
    ```

    Then the pattern can be used as a color source via

    ```
    Xairo.set_source(image, pattern)
    ```

  """

  alias Xairo.RGBA

  defstruct [:pattern]

  @type t :: %__MODULE__{
          pattern: reference()
        }

  @spec new(RGBA.t()) :: __MODULE__.t()
  def new(%RGBA{} = color) do
    %__MODULE__{
      pattern: Xairo.Native.solid_pattern_from_rgba(color)
    }
  end

  @spec color(__MODULE__.t()) :: RGBA.t() | Xairo.error()
  def color(%__MODULE__{pattern: pattern}) do
    with {:ok, color} <- Xairo.Native.solid_pattern_color(pattern),
         do: color
  end
end
