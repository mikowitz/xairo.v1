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
  """
  @spec extents(Xairo.Image.t(), String.t()) :: Extents.t() | Xairo.error()
  def extents(%Xairo.Image{} = image, text) do
    with {:ok, %Extents{} = extents} <- Native.text_extents(image.resource, text), do: extents
  end
end
