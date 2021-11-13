defmodule Xairo do
  @moduledoc """
  The public API for creating images using the `Xairo` library.

  With the exeception of `new_image/3` every API function takes a `Xairo.Image`
  struct as its first argument, and all API functions return a `Xairo.Image`
  struct.

  Some words about how the C cairo library understands image space and rendering
  will be useful here


  ### Imagespace and scale

  A new image is created with `new_image/3`. This takes as its first two arguments
  the width and height of the image, with an optional third argument that sets
  the image's scale.

  For example, the following command

      iex> Xairo.new_image(100, 100, 2.0)

  will create an image with relative imagespace of 100x100 pixels, but a true,
  rendered size of 200x200. This means that while drawing on the empty image
  surface, you would draw within the coordinates [0,100]x[0,100], but when
  rendered to an image file, all those coordinates would be scaled up by a
  factor of 2. That is, the following command to draw a line

      iex> Xairo.move_to({10, 10}) |> Xairo.line_to({90, 90})

  would render to a file as a line from (20,20) to (180, 180).

  By drawing in imagespace coordinates, this allows you to create an image at a
  smaller scale for rapid iteration, but easily scale it up to a higher
  resolution for a finished product without needing to recalculate every
  plotted coordinate.

  The `Xairo.Image` struct stores `width` and `height` as their unscaled values,
  allowing the user to calculate against them properly in imagespace, while
  ensuring the final scaled image will render correctly.

  ### How cairo renders images

  Cairo creates images by building up paths, or collections of moving to and
  drawing between points on the image space. These paths can be initiated by
  moving to a point, which is set as the current point of the path, using the
  functions

  * `move_to/2`
  * `rel_move_to/3`

  `move_to/2` takes as its second parameter an absolute coordinate in imagespace
  (see above for an explanation), while `rel_move_to/2` takes `x` and `y` values
  relative to the previosu current point.

  Once a current point has been set, the path can be appended to by using any of
  these functions

  * `line_to/2`
  * `rel_line_to/3`
  * `arc/2` / `arc/5`
  * `arc_negative/2` / `arc_negative/5`
  * `curve_to/2` / `curve_to/4`
  * `rel_curve_to/7`

  A path may be built up as large as desired, using these functions as well as
  the functions above for moving the current point. However, nothing will
  be rendered onto the image until one of the following functions is called

  * `stroke/1`
  * `fill/1`

  `stroke/1` will render all the lines created as part of the path, while
  `fill/1` will render the lines as well as fill in the space between them. For
  simple convex paths, this will fill the entirely of the interior (assuming a
  line between the first and last coordinates of the path, if `close_path/1` has
  not been called). For more complex shapes, or instances where the path crosses
  over itself, cairo uses an internal algorithm to determine which portions, if
  any, to fill in.

  ### Modifying color, line width, etc.

  Because nothing is rendered until these functions are called, only the most
  recent function calls to set the path's color, line width, etc. will be taken
  into account. This means that to draw lines of different colors or widths, you
  must create and end different paths for each one. These functions can be called
  at any point before the path in initialized or during its extension, but if
  called multiple times, only the final invocation will be taken into account.

  These functions are:

  * `set_color/2` / `set_color/4` / `set_color/5`
  * `set_line_width/2`
  * `set_line_cap/2`
  * `set_line_join/2`
  * `set_dash/2` / `set_dash/3`

  To paint the entire image space (for example to set a background), you use

  * `paint/1`

  after setting a color. If this function is never called, by default the
  background, when rendering to `.png`, will be transparent.

  """

  @typedoc """
  A 2-element tuple of numbers representing an {x, y} coordinate in imagespace.
  """
  @type coordinate :: {number(), number()}
  @typedoc """
  A 2-element tuple representing an error.

  The first element is always `:error`, and the second is an atom defining
  the error context.
  """
  @type error :: {:error, atom()}
  @typedoc """
  Shorthand for the API return type.

  Indicates a function either returns a `t:Xairo.Image.t/0` struct or an
  `t:error/0` tuple.
  """
  @type image_or_error :: Image.t() | error()

  import Xairo.NativeFn

  alias Xairo.{Arc, Curve, Dashes, Image, Point, RGBA}

  @doc """
  Creates and returns a new `Xairo.Image` struct

  This struct is a wrapper around the `width`, `height`, and `scale` values
  of the image, as well as a reference to the in-memory C cairo resource,
  and an identfier in the form of a `Reference`.

  `new_image/3` handles type conversions to ensure that `width` and `height`
  are stored as integers, while `scale` is a floating point number, to match
  the types expected by the Rust/C API.

  ## Example

      iex> Xairo.new_image(100, 100, 2)
      #Image<100x100@2.0 #Reference<0.123.456,789>>

  """
  @spec new_image(number, number, number | nil) :: image_or_error()
  def new_image(width, height, scale \\ 1.0) do
    with {:ok, image} <- Image.new(width, height, scale), do: image
  end

  @doc """
  Saves `image` to the given location `filename` on the file system.

  If `filename` contains any non-existant directories, `save_image/2` will
  not create them, and return an error instead.

  ## Examples

      iex> Xairo.save_image(image, "test.png")
      #Image<100x100@2.0 #Reference<0.123.456.789>>

      iex> Xairo.save_image(image, "non/existant/path/test.png")
      {:error, :file_creation_error}

  """
  @spec save_image(Image.t(), String.t()) :: image_or_error()
  native_fn(:save_image, [filename])

  @doc """
  Sets the image's current point to `point`.

  This sets the current point using the given coordinates as an absolution
  position (see `rel_move_to/2` for moving relative to the previous current
  point).

  The current point is not currently represented in the `Xairo.Image` struct,
  but is used by the C cairo library to determine the next starting point for
  any drawn paths.


  ## Examples

  `move_to/2` can take as its second argument a `Xairo.Point` struct

      iex> point = Point.new(20, 30)
      iex> Xairo.move_to(image, point)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  or a 2-element tuple coordinate pair

      iex> Xairo.move_to(image, {20, 30})
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  """
  @spec move_to(Image.t(), Point.t()) :: image_or_error()
  @spec move_to(Image.t(), coordinate) :: image_or_error()
  def move_to(%Image{} = image, {x, y}) do
    with point <- Point.new(x, y), do: move_to(image, point)
  end

  native_fn(:move_to, [point])

  @doc """
  Draws a line to the given `point`.

  This draws a line from the image's current point to the given point as an
  absolute coordinate (see `rel_point_to/2` for drawing relative to the current
  point).

  ## Examples

  `line_to/2` can take as its second argument a `Xairo.Point` struct

      iex> point = Point.new(90, 90)
      iex> Xairo.line_to(image, point)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  or a 2-element tuple coordinate pair

      iex> Xairo.line_to(image, {90, 90})
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  """
  @spec line_to(Image.t(), Point.t()) :: image_or_error()
  @spec line_to(Image.t(), coordinate) :: image_or_error()
  def line_to(%Image{} = image, {x, y}) do
    with point <- Point.new(x, y), do: line_to(image, point)
  end

  native_fn(:line_to, [point])

  @doc """
  Renders the lines of the current path on to the `image`.

  This takes into account the values most recently set for

  - line color
  - line thickness
  - line cap
  - line join

  or uses the default values for each of these as determined by cairo.
  """
  @spec stroke(Image.t()) :: image_or_error()
  native_fn(:stroke)

  @doc """
  Renders the lines of the current path on to the `image` and fills it in.

  Similar to `stroke/1` this takes into account the most recent values set for
  color and line style. The same color will be used to fill the path. If
  `close_path/1` has not been called, a straight line between the current
  point of the path and its origin will be created to bound the fill space.

  With a simple convex path, the entirety of the path will be filled. With a more
  complex shape, one where the path crosses over itself, cairo will determine
  which, if any, portions to fill using an internal algorithm.

  Because `set_color/2` sets the color for the stroke and fill of the path, it
  is not possible to fill a single path with a different color than its stroke.
  To accomplish this, you would need to duplicate the path, calling `fill/1` the
  first time, and `stroke/1` the second time after setting the desired color.
  """
  @spec fill(Image.t()) :: image_or_error()
  native_fn(:fill)

  @doc """
  Fills the entirety of the `image` surface with the currently set color.
  """
  @spec paint(Image.t()) :: image_or_error()
  native_fn(:paint)

  @doc """
  Sets `color` as the current color for the `image`.

  This color setting remains in effect until `set_color/2` is called again
  with a new color. This function can be called as many times as desired, but
  will not be used until `stroke/1`, `fill/1` or `paint/1` is called, at which
  point the most recent color set will be used.
  """
  @spec set_color(Image.t(), RGBA.t()) :: image_or_error()
  native_fn(:set_color, [rgba])

  @doc """
  Calls `set_color/2` with the given `image` and an `t:Xairo.RGBA.t/0` struct
  constructed from the remaining arguments.
  """
  @spec set_color(Image.t(), number(), number(), number(), number()) :: image_or_error()
  def set_color(%Image{} = image, red, green, blue, alpha \\ 1.0) do
    with %RGBA{} = rgba <- RGBA.new(red, green, blue, alpha) do
      set_color(image, rgba)
    end
  end

  @doc """
  Sets the `width` of lines drawn on the `image`.

  This function can be called as many times a desired, but when `stroke/1` or
  `fill/1` is called, only the most recent call to this function will be in
  effect.
  """
  @spec set_line_width(Image.t(), number()) :: image_or_error()
  native_fn(:set_line_width, [{width, Float}])

  @doc """
  Sets the line cap style for the `image`.

  The `line_cap` atom passed can be one of `:square`, `:round`, `:butt`, or
  `:default`. The default value for `line_cap` in cairo is the `:butt` style.

  - `:square` creates a square line ending centered at the start/end point
  - `:round` creates a round line ending centered at the start/end point
  - `:butt` begins/ends the line exactly at the start/end point
  """
  @spec set_line_cap(Image.t(), atom()) :: image_or_error()
  native_fn(:set_line_cap, [cap])

  @doc """
  Sets the line join style for the `image`.

  The `line_join` atom passed can be one of `:round`, `:bevel`, `:miter`, or
  `:default`. The default value for `line_cap` in cairo is the `:miter` style.

  - `:round` creates a rounded join centered on the join point
  - `:bevel` creates a cut-off join, at half the set line width from the join point
  - `:miter` creates a sharp, angled, corner
  """
  @spec set_line_cap(Image.t(), atom()) :: image_or_error()
  native_fn(:set_line_join, [join])

  @doc """
  Sets the line dash pattern for the `image`.

  See the documentation for `Xairo.Dashes` for a detailed description of how
  the data from the `Xairo.Dashes` struct is parsed and used.
  """
  @spec set_dash(Image.t(), Dashes.t()) :: image_or_error()
  native_fn(:set_dash, [dashes])

  @doc """
  Calls `set_dash/2` with the `image` and a `t:Xairo.Dashes.t/0` constructed
  from the remaining arguments.
  """
  @spec set_dash(Image.t(), [number()], number()) :: image_or_error()
  def set_dash(%Image{} = image, dashes, offset) do
    with %Dashes{} = dashes <- Dashes.new(dashes, offset) do
      set_dash(image, dashes)
    end
  end

  @doc """
  Closes the current path by drawing a straight line from the current point to the path's
  start point.


  ## Example

      iex> Xairo.close_path(image)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  """
  @spec close_path(Image.t()) :: image_or_error()
  native_fn(:close_path)

  native_fn(:rel_move_to, [{dx, Float}, {dy, Float}])
  native_fn(:rel_line_to, [{dx, Float}, {dy, Float}])

  @doc """
  Draws the defined `arc` clockwise on the `image` surface.

  The `arc` struct defines a `start_angle`, `stop_angle`, `center`, and `radius`.
  This function draws the arc clockwise from `start_angle` to `stop_angle` at
  a distance of `radius` from the `center`.

  If a current point is set for the active path when `arc/2` is called, a line
  will be drawn from that current point to the start of the arc.

  ## Example

      iex> arc = Arc.new({50, 50}, 20, 0, :math.pi)
      iex> Xairo.arc(image, arc)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  """
  @spec arc(Image.t(), Arc.t()) :: image_or_error()
  native_fn(:arc, [arc])

  @doc """
  Calls `arc/2` with the given `image`, and an `t:Xairo.Arc.t/0` constructed from the remaining arguments.
  """
  @spec arc(Image.t(), coordinate(), number(), number(), number()) :: image_or_error()
  @spec arc(Image.t(), Point.t(), number(), number(), number()) :: image_or_error()
  def arc(%Image{} = image, center, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(center, radius, start_angle, stop_angle) do
      arc(image, arc)
    end
  end

  @doc """
  Draws the defined `arc` counter-clockwise on the `image` surface.

  The `arc` struct defines a `start_angle`, `stop_angle`, `center`, and `radius`.
  This function draws the arc counter-clockwise from `start_angle` to `stop_angle` at
  a distance of `radius` from the `center`.

  If a current point is set for the active path when `arc/2` is called, a line
  will be drawn from that current point to the start of the arc.

  ## Example

      iex> arc = Arc.new({50, 50}, 20, 0, :math.pi)
      iex> Xairo.arc(image, arc)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  """
  native_fn(:arc_negative, [arc])

  @doc """
  Calls `arc_negative/2` with the given `image`, and an `t:Xairo.Arc.t/0` constructed from the remaining arguments.
  """
  @spec arc_negative(Image.t(), Point.t(), number(), number(), number()) :: image_or_error()
  @spec arc_negative(Image.t(), coordinate(), number(), number(), number()) :: image_or_error()
  def arc_negative(%Image{} = image, center, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(center, radius, start_angle, stop_angle) do
      arc_negative(image, arc)
    end
  end

  @doc """
  Calls `curve_to/2` with the given `image` and a `t:Xairo.Curve.t/0` constructed
  from the remaining arguments.
  """
  @spec curve_to(Image.t(), Point.t(), Point.t(), Point.t()) :: image_or_error()
  @spec curve_to(Image.t(), coordinate(), coordinate(), coordinate()) :: image_or_error()
  def curve_to(%Image{} = image, first_control_point, second_control_point, curve_end) do
    with curve <- Curve.new(first_control_point, second_control_point, curve_end) do
      curve_to(image, curve)
    end
  end

  @doc """
  Draws a cubic Bézier `curve` from the current point of the `image`.

  If no current point is set, this function will act as though it was preceded
  by a call to `move_to/2` with the first control point of the curve.

  ## Example

  Assuming a `t:Xairo.Curve.t/0` created

      iex> curve = Curve.new({20, 20}, {80, 50}, {20, 80})

  with a current point set

      iex> Xairo.move_to(image, {10, 10})
      iex> Xairo.curve_to(image, curve)

  Without a current point set, the function call

      iex> Xairo.curve_to(image, curve)

  is equivalent to

      iex> Xairo.move_to(image, {20, 20})
      iex> Xairo.curve_to(image, curve)

  """
  @spec curve_to(Image.t(), Curve.t()) :: image_or_error()
  native_fn(:curve_to, [curve])

  native_fn(:rel_curve_to, [
    {cx1, Float},
    {cy1, Float},
    {cx2, Float},
    {cy2, Float},
    {cx3, Float},
    {cy3, Float}
  ])
end
