defmodule Xairo.Image do
  @callback new(
              filename :: String.t(),
              width :: number,
              height :: number,
              options :: Keyword.t() | nil
            ) :: Xairo.image()

  def new(filename, width, height, options \\ []) do
    filename
    |> image_module_from_filename()
    |> apply(:new, [filename, width, height, options])
  end

  def save(image) do
    Xairo.Native.save_image(image.resource, image.filename)
  end

  defp image_module_from_filename(filename) do
    image_module =
      Path.extname(filename)
      |> String.trim(".")
      |> String.capitalize()
      |> String.to_atom()

    Module.safe_concat([Xairo.Image, image_module])
  end
end
