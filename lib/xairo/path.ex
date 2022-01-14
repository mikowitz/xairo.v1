defmodule Xairo.Path do
  @moduledoc """
  Holds a reference to a
  """

  defstruct [:resource]

  @type t :: %__MODULE__{
          resource: reference
        }

  @doc """
  Takes a resource reference passed from a NIF and wraps it in a `Xairo.Path`
  struct.
  """
  @spec new(reference) :: __MODULE__.t()
  def new(path) when is_reference(path) do
    %__MODULE__{resource: path}
  end

  @doc """
  Calls `Xairo.copy_path_flat/1` on the given image, temporarily setting the
  image `tolerance`.

  Returns a tuple of `{path, image}`, ensuring that the returned image has its
  tolerance set back to its value before calling `flat/1`.
  """
  @spec flat(Xairo.Image.t()) :: {__MODULE__.t(), Xairo.Image.t()}
  def flat(%Xairo.Image{} = image, tolerance \\ nil) do
    original_tolerance = Xairo.get_tolerance(image)

    path =
      image
      |> Xairo.set_tolerance(tolerance || original_tolerance)
      |> Xairo.copy_path_flat()

    {
      path,
      Xairo.set_tolerance(image, original_tolerance)
    }
  end
end
