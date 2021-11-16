defmodule Xairo.Pattern do
  @moduledoc """
  Shared type definitions for Patterns.
  """

  @typedoc """
  Represents a color set a percentage of the way along a linear or radial gradient.
  """
  @type color_stop :: {Xairo.RGBA.t(), number()}

  @typedoc """
  Specifies the existing types of patterns.
  """
  @type pattern ::
          Xairo.Pattern.LinearGradient.t()
          | Xairo.Pattern.RadialGradient.t()
          | Xairo.Pattern.Mesh.t()
end
