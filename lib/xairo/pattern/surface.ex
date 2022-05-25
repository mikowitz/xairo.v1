defmodule Xairo.Pattern.Surface do
  @moduledoc """
    Models a pattern that uses a surface to determine ink data

    ## Example

    The following code creates a surface painted red with a diagonal blue line

    ```
    pattern = Surface.new(100, 100, scale: 2)
    |> Xairo.set_color(RGBA.new(1, 0, 0))
    |> Xairo.paint()
    |> Xairo.set_color(RGBA.new(0, 0, 1))
    |> Xairo.move_to({0, 0})
    |> Xairo.line_to({100, 100})
    |> Xairo.stroke()
    ```

    Then it can be set as the source for another image and used to render
    color data onto the image

    ```
    Xairo.new_image("test.png", 100, 100, scale: 2)
    |> Xairo.set_source(pattern)
    |> Xairo.rectangle({20, 20}, 30, 40)
    |> Xairo.fill()
    ```

    Because Xairo images and surface patterns are references to mutable, in-memory
    Rust structs, it is possible to create a Surface pattern, assign it as a source,
    and *then* set its contents, as long as it is inked via calls to `paint`, `fill`,
    and `stroke` before the image it is set as the source for uses it.

    For example, the following code will return the same result as the code above.

    ```
    pattern = Surface.new(100, 100, scale: 2)

    image = Xairo.new_image("test.png", 100, 100, scale: 2)
    |> Xairo.set_source(pattern)

    pattern
    |> Xairo.set_color(RGBA.new(1, 0, 0))
    |> Xairo.paint()
    |> Xairo.set_color(RGBA.new(0, 0, 1))
    |> Xairo.move_to({0, 0})
    |> Xairo.line_to({100, 100})
    |> Xairo.stroke()

    image
    |> Xairo.rectangle({20, 20}, 30, 40)
    |> Xairo.fill()
    ```
  """

  defstruct [:resource]

  @type t :: %__MODULE__{
          resource: reference()
        }

  @doc """
    Creates a new surface pattern with the given width, height, and scale
  """
  def new(width, height, options \\ []) do
    scale = Keyword.get(options, :scale, 1.0) * 1.0
    scaled_width = round(scale * width)
    scaled_height = round(scale * height)
    {:ok, resource} = Xairo.Native.new_png_image(scaled_width, scaled_height)
    Xairo.Native.scale(resource, scale, scale)

    %__MODULE__{
      resource: resource
    }
  end
end
