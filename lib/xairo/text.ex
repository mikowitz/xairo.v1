defmodule Xairo.Text do
  @moduledoc """
  Helper methods for interacting with text in a `t:Xairo.Image.t/0`
  """

  alias Xairo.Native
  alias Xairo.Text.Extents

  @doc """
  Returns `t:Xairo.Text.Extents.t/0` for `text` in the context of `image`.

  See `Xairo.Text.Extents` for a description of what the struct contains.

  ## Example

      iex> image = Xairo.new_image(100, 100, 2)
      ...> |> Xairo.set_font_size(15)
      iex> Text.extents(image, "hello")
      #TextExtents<hello @15.0>

  It also works for SVG images

    iex> image = Xairo.new_svg_image("test.svg", 100, 100, scale: 2)
    ...> |> Xairo.set_font_size(20)
    iex> Text.extents(image, "hello")
    #TextExtents<hello @20.0>

  """
  @spec extents(Xairo.image(), String.t()) :: Extents.t() | Xairo.error()
  def extents(%{resource: resource}, text) do
    with {:ok, %Extents{} = extents} <- Native.text_extents(resource, text), do: extents
  end
end
