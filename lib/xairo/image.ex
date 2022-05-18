defmodule Xairo.Image do
  @moduledoc """
    Common functionality for creating and saving Xairo images.

    ## Images and the filesystem

    There are two ways files are built and written to the filesystem in
    the underlying Cairo library. PNG images are built up in memory, and
    written to disk when all contents have been rendered. The ".png" file
    does not exist on the filesystem until `Xairo.Image.save/1` is called.

    SVG, PDF, and PS files are written to disk as soon as `Xairo.Image.new/4`
    is called, and are built up until `save/1` is called, at which point
    all contents are rendered to the file that already exists on the filesystem.

    This should not affect workflows, but is given as an explanation why some
    files will appear on your filesystem as soon as `new/4` is called, and
    others do not.

  """
  @callback new(
              filename :: String.t(),
              width :: number,
              height :: number,
              options :: Keyword.t() | nil
            ) :: Xairo.image()

  @doc """
    Creates a new image from the parameters given.

    The underlying cairo image surface type is determined by the file extension
    of the filename. Valid extensions are

    * `.png`
    * `.svg`
    * `.pdf`
    * `.ps`

    If the filename points to a directory that does not exist, it will not create
    the directory structure, returning an error instead.

  """
  @spec new(String.t(), number(), number(), Keyword.t() | nil) :: Xairo.image_or_error()
  def new(filename, width, height, options \\ []) do
    filename
    |> image_module_from_filename()
    |> apply(:new, [filename, width, height, options])
  end

  @doc """
    Save the image to disk at a location defined by the struct's filename value.
  """
  @spec save(Xairo.image()) :: Xairo.image_or_error()
  def save(image) do
    with {:ok, _} <- Xairo.Native.save_image(image.resource, image.filename), do: image
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
