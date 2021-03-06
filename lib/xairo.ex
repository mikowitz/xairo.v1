defmodule Xairo do
  @moduledoc """
  The public API for creating images using the `Xairo` library.

  With only a few exceptions, every API function takes a `Xairo.Image` struct
  as its first argument, and returns a `Xairo.Image` struct.

  Some words about how the C cairo library understands image space and rendering
  will be useful here

  ### Image types

    `Xairo` allows creating and saving images in `.png`, `.svg`, `.pdf` and `.ps`
    formats. All file formats can be created via the `new_image/4` function.

    It takes as its arguments required fields for the filename (including extension), width, and height, and an optional keyword list.

    The keyword list can contain the following keys:

    * `scale`: determines the scale of the image relative to the given width and height. See below for details on how scaling an image works.
    * `unit`: only read when creating SVG images, this determines the document unit the width and height dimensions will be measured in, defaulting to `:point`. See `Xairo.Image.Svg` for a list of allowed units. All other image types are understood to be defined in pixel size.

  The following discussions of userspace, scale, and transformations apply to
  all types of images. I have used PNG in examples below,
  but they would all hold true for `Xairo.Image.Svg` structs as well, replacing
  "pixel" with the image struct's document unit.

  ### Userspace and scale

  A new image is created with `new_image/3`. This takes as its first two
  arguments the width and height of the image, with an optional third argument
  that sets the image's scale.

  For example, the following command

      iex> Xairo.new_image("test.png", 100, 100, scale: 2.0)

  will create an image with relative userspace of 100x100 pixels, but a true,
  rendered size of 200x200. This means that while drawing on the empty image
  surface, you would draw within the coordinates [0,100]x[0,100], but when
  rendered to an image file, all those coordinates would be scaled up by a
  factor of 2. That is, the following command to draw a line

      iex> Xairo.move_to({10, 10}) |> Xairo.line_to({90, 90})

  would render to a file as a line from (20,20) to (180, 180).

  By drawing in userspace coordinates, this allows you to create an image at a
  smaller scale for rapid iteration, but easily scale it up to a higher
  resolution for a finished product without needing to recalculate every
  plotted coordinate.

  The `Xairo.Image` struct stores `width` and `height` as their unscaled values,
  allowing the user to calculate against them properly in userspace, while
  ensuring the final scaled image will render correctly.

  ### How cairo renders images

  Cairo creates images by building up paths, or collections of moving to and
  drawing between points on the image space. These paths can be initiated by
  moving to a point, which is set as the current point of the path, using the
  functions

  * `move_to/2`
  * `rel_move_to/2`

  `move_to/2` takes as its second parameter an absolute coordinate in userspace
  (see above for an explanation), while `rel_move_to/2` takes a vector defining
  the distance to the new point relative to the previous current point.

  Once a current point has been set, the path can be appended to by using any of
  these functions

  * `line_to/2`
  * `rel_line_to/2`
  * `rectangle/2` / `rectangle/4`
  * `arc/2` / `arc/5`
  * `arc_negative/2` / `arc_negative/5`
  * `curve_to/2` / `curve_to/4`
  * `rel_curve_to/2` / `rel_curve_to/4`

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
  must create and end different paths for each one. These functions can be
  called at any point before the path in initialized or during its extension,
  but if called multiple times, only the final invocation will be taken into
  account.

  These functions are:

  * `set_color/2` / `set_color/4` / `set_color/5`
  * `set_source/2`
  * `set_line_width/2`
  * `set_line_cap/2`
  * `set_line_join/2`
  * `set_dash/2` / `set_dash/3`

  To paint the entire image space (for example to set a background), you use

  * `paint/1`

  after setting a color. If this function is never called, by default the
  background, when rendering to `.png`, will be transparent.

  ### Modifying and displaying text

  Basic text can be rendered as part of an image as well. `Xairo` provides
  access to Cairo's "toy font" API, which is designed to provide only simple
  tools for manipulating text. See `Xairo.Text.Font` for a complete explanation.

  Text is displayed using

  * `show_text/2`

  Calling `show_text/2` immediately renders the text given, instead of waiting
  for `stroke/1` or `fill/1` to be called. However, it does take the current
  path into account, beginning the text render at the current point, and
  advancing the current point after being rendered. See `Xairo.Text.Extents`
  for an explanation of how that distance is calculated.

  A font can be set using

  * `set_font_face/2`
  * `select_font_face/4`

  In additon, the size and positioning of the font can be set with

  * `set_font_size/2`
  * `set_font_matrix/2`

  `set_font_matrix/2` allows setting a transformation matrix for the font face.
  See [Transformation matrices](#module-transformation-matrices) for an
  explanation of how to use these matrices.

  ### Transformation matrices

  The image context stores a "current transformation matrix" (CTM) that handles
  an affine transformation for points rendered on the image. Only a single CTM
  can be active at any time. When a new image is created, its CTM is set to the
  identity matrix: a scale value of 1 in the x and y directions, and 0 rotation,
  shearing, or translation.

  If `new_image/3` is called with a scale value, the CTM will be scaled by that
  value in both the x and y directions.

  #### Modifying matrices

  The following functions update the CTM, applying their transformation after
  any existing transformations:

  * `scale/3`
  * `translate/3`
  * `rotate/2`
  * `transform/2`

  It is also possible to create a new matrix and perform these operations
  separately before replacing the CTM. See `Xairo.Matrix`.

  #### Replacing CTM

  These functions will replace the CTM with a new matrix

  * `set_matrix/2`
  * `identity_matrix/1`

  You can also retrieve a `Xairo.Matrix` holding the current CTM by calling

  * `get_matrix/1`

  #### Other uses for `Xairo.Matrix`

  Matrices can also be used to perform affine transformations on fonts and text
  by calling

  * `set_font_matrix/2`

  """

  @typedoc """
  Shorthand for the type `a | nil`
  """
  @type or_nil(a) :: a | nil

  @typedoc """
  A 2-element tuple of numbers representing an {x, y} coordinate in userspace.
  """
  @type coordinate :: {number(), number()}

  @typedoc """
  Union type shorthand for representing a fixed point in userspace
  """
  @type point :: Xairo.Point.t() | coordinate()

  @typedoc """
  A 2-element tuple representing an error.

  The first element is always `:error`, and the second is a string defining
  the error context.
  """
  @type error :: {:error, String.t()}

  @typedoc """
  Shorthand for a valid image type
  """
  @type image ::
          Xairo.Image.Png.t() | Xairo.Image.Svg.t() | Xairo.Image.Pdf.t() | Xairo.Image.Ps.t()

  @typedoc """
  Shorthand for the API return type.

  Indicates a function either returns a `t:Xairo.image/0` struct or an
  `t:error/0` tuple.
  """
  @type image_or_error :: image() | error()

  import Xairo.NativeFn
  alias Xairo.Native

  alias Xairo.{
    Arc,
    Curve,
    Dashes,
    Image,
    Matrix,
    Pattern,
    Point,
    Rectangle,
    RGBA,
    Text.Font,
    Vector
  }

  alias Pattern.{LinearGradient, Mesh, RadialGradient, Solid, Surface}

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
  @spec new_image(String.t(), number(), number(), Keyword.t() | nil) :: image_or_error()
  def new_image(filename, width, height, opts \\ []) do
    Image.new(filename, width, height, opts)
  end

  @doc """
    Saves `image` to the filesystem at a location matching its filename.

    Saving will not create any non-extant parent directories in the filename path,
    and will return an error tuple instead.

  ## Examples

      iex> Xairo.save_image(image)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

      iex> image = Xairo.new_image("non/extant/path/test.png", 200, 200)
      iex> Xairo.save_image(image)
      {:error, :file_creation_error}

  """
  @spec save_image(image()) :: image_or_error()
  def save_image(image) do
    Image.save(image)
  end

  @doc """
  Sets the image's current point to `point`.

  This sets the current point using the given coordinates as an absolute
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
  @spec move_to(image(), Xairo.point()) :: image_or_error()
  def move_to(%{resource: _} = image, point) do
    with point <- Point.from(point) do
      Xairo.Native.move_to(image.resource, point)
      image
    end
  end

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
  @spec line_to(image(), Xairo.point()) :: image_or_error()
  def line_to(%{resource: _} = image, {x, y}) do
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
  @spec stroke(image()) :: image_or_error()
  native_fn(:stroke)

  @doc """
  Renders the lines of the current path on to the `image` and fills it in.

  Similar to `stroke/1` this takes into account the most recent values set for
  color and line style. The same color will be used to fill the path. If
  `close_path/1` has not been called, a straight line between the current
  point of the path and its origin will be created to bound the fill space.

  With a simple convex path, the entirety of the path will be filled. With a
  more complex shape, one where the path crosses over itself, cairo will
  determine which, if any, portions to fill using an internal algorithm.

  Because `set_color/2` sets the color for the stroke and fill of the path, it
  is not possible to fill a single path with a different color than its stroke.
  To accomplish this, you would need to duplicate the path, calling `fill/1` the
  first time, and `stroke/1` the second time after setting the desired color.
  """
  @spec fill(image()) :: image_or_error()
  native_fn(:fill)

  @doc """
  Fills the entirety of the `image` surface with the currently set color.
  """
  @spec paint(image()) :: image_or_error()
  native_fn(:paint)

  @doc """
  Sets `color` as the current color for the `image`.

  This color setting remains in effect until `set_color/2` is called again
  with a new color. This function can be called as many times as desired, but
  will not be used until `stroke/1`, `fill/1` or `paint/1` is called, at which
  point the most recent color set will be used.
  """
  @spec set_color(image(), RGBA.t()) :: image_or_error()
  native_fn(:set_color, [rgba])

  @doc """
  Calls `set_color/2` with the given `image` and an `t:Xairo.RGBA.t/0` struct
  constructed from the remaining arguments.
  """
  @spec set_color(image(), number(), number(), number(), number()) :: image_or_error()
  def set_color(%{resource: _} = image, red, green, blue, alpha \\ 1.0) do
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
  @spec set_line_width(image(), number()) :: image_or_error()
  native_fn(:set_line_width, [{width, Float}])

  @doc """
  Sets the line cap style for the `image`.

  The `line_cap` atom passed can be one of `:square`, `:round`, `:butt`, or
  `:default`. The default value for `line_cap` in cairo is the `:butt` style.

  - `:square` creates a square line ending centered at the start/end point
  - `:round` creates a round line ending centered at the start/end point
  - `:butt` begins/ends the line exactly at the start/end point
  """
  @spec set_line_cap(image(), atom()) :: image_or_error()
  native_fn(:set_line_cap, [cap])

  @doc """
  Sets the line join style for the `image`.

  The `line_join` atom passed can be one of `:round`, `:bevel`, `:miter`, or
  `:default`. The default value for `line_cap` in cairo is the `:miter` style.

  - `:round` creates a rounded join centered on the join point
  - `:bevel` creates a cut-off join, at half the set line width from the join
    point
  - `:miter` creates a sharp, angled, corner
  """
  @spec set_line_join(image(), atom()) :: image_or_error()
  native_fn(:set_line_join, [join])

  @doc """
  Sets the line dash pattern for the `image`.

  See the documentation for `Xairo.Dashes` for a detailed description of how
  the data from the `Xairo.Dashes` struct is parsed and used.
  """
  @spec set_dash(image(), Dashes.t()) :: image_or_error()
  native_fn(:set_dash, [dashes])

  @doc """
  Calls `set_dash/2` with the `image` and a `t:Xairo.Dashes.t/0` constructed
  from the remaining arguments.
  """
  @spec set_dash(image(), [number()], number()) :: image_or_error()
  def set_dash(%{resource: _} = image, dashes, offset) do
    with %Dashes{} = dashes <- Dashes.new(dashes, offset) do
      set_dash(image, dashes)
    end
  end

  @doc """
  Closes the current path by drawing a straight line from the current point to
  the path's start point.

  ## Example

      iex> Xairo.close_path(image)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  """
  @spec close_path(image()) :: image_or_error()
  native_fn(:close_path)

  @doc """
  Moves to a point relative to the current point.

  The point moved to is at a distance of {`dx`, `dy`} from
  the previous current point in userspace and makes this
  new point the current point.

  ## Example

  ```
  image
  |> Xairo.move_to({10, 10})
  |> Xairo.rel_move_to({10, 25})
  ```

  would result in the new current for the image at {20, 35}.
  """
  @spec rel_move_to(image(), Vector.t()) :: image_or_error()
  def rel_move_to(%{resource: _} = image, vector) do
    with vector <- Vector.from(vector) do
      Xairo.Native.rel_move_to(image.resource, vector)
      image
    end
  end

  @doc """
  Draws a line from the current point to a point offset from it by `{dx, dy}`
  in userspace.

  ## Example

  ```
  image
  |> Xairo.move_to({10, 10})
  |> Xairo.rel_line_to(10, 25)
  ```

  adds a line from {10, 10} to {20, 35} to the path.
  """
  @spec rel_line_to(image(), Vector.t()) :: image_or_error()
  def rel_line_to(%{resource: _} = image, vector) do
    with vector <- Vector.from(vector) do
      Xairo.Native.rel_line_to(image.resource, vector)
      image
    end
  end

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
  @spec arc(image(), Arc.t()) :: image_or_error()
  native_fn(:arc, [arc])

  @doc """
  Calls `arc/2` with the given `image`, and an `t:Xairo.Arc.t/0` constructed
  from the remaining arguments.
  """
  @spec arc(image(), Xairo.point(), number(), number(), number()) :: image_or_error()
  def arc(%{resource: _} = image, center, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(center, radius, start_angle, stop_angle) do
      arc(image, arc)
    end
  end

  @doc """
  Draws the defined `arc` counter-clockwise on the `image` surface.

  The `arc` struct defines a `start_angle`, `stop_angle`, `center`, and
  `radius`.  This function draws the arc counter-clockwise from `start_angle`
  to `stop_angle` at a distance of `radius` from the `center`.

  If a current point is set for the active path when `arc/2` is called, a line
  will be drawn from that current point to the start of the arc.

  ## Example

      iex> arc = Arc.new({50, 50}, 20, 0, :math.pi)
      iex> Xairo.arc(image, arc)
      #Image<100x100@2.0 #Reference<0.123.456.789>>

  """
  native_fn(:arc_negative, [arc])

  @doc """
  Calls `arc_negative/2` with the given `image`, and an `t:Xairo.Arc.t/0`
  constructed from the remaining arguments.
  """
  @spec arc_negative(image(), Xairo.point(), number(), number(), number()) :: image_or_error()
  def arc_negative(%{resource: _} = image, center, radius, start_angle, stop_angle) do
    with %Arc{} = arc <- Arc.new(center, radius, start_angle, stop_angle) do
      arc_negative(image, arc)
    end
  end

  @doc """
  Calls `curve_to/2` with the given `image` and a `t:Xairo.Curve.t/0`
  constructed from the remaining arguments.
  """
  @spec curve_to(image(), Xairo.point(), Xairo.point(), Xairo.point()) :: image_or_error()
  def curve_to(
        %{resource: _} = image,
        first_control_point,
        second_control_point,
        curve_end
      ) do
    with curve <- Curve.new(first_control_point, second_control_point, curve_end) do
      curve_to(image, curve)
    end
  end

  @doc """
  Draws a cubic B??zier `curve` from the current point of the `image`.

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
  @spec curve_to(image(), Curve.t()) :: image_or_error()
  native_fn(:curve_to, [curve])

  @doc """
  Draws a curve using coordinates relative to the current point.

  After the `image`, the remaining six arguments to this function are paired
  `x` and `y` relative distances for the first control point, second control
  point, and curve end point, respectively.

  ```
  Xairo.rel_curve_to(
    image,
    x1, y1,  # the relative x and y distance of the first control point
    x2, y2,  # the relative x and y distance of the second control point
    x3, y3   # the relative x and y distance of the curve end
  )
  ```

  All values are relative to the *current point* of the path at the time this
  function is called, not to the previous point defined by the function
  arguments.
  """
  @spec rel_curve_to(image(), Vector.t(), Vector.t(), Vector.t()) :: image_or_error
  def rel_curve_to(%{resource: _} = image, vector1, vector2, vector3) do
    with vector1 <- Vector.from(vector1),
         vector2 <- Vector.from(vector2),
         vector3 <- Vector.from(vector3),
         curve <- Curve.new(vector1, vector2, vector3) do
      rel_curve_to(image, curve)
    end
  end

  @spec rel_curve_to(image(), Curve.t()) :: image_or_error()
  native_fn(:rel_curve_to, [curve])

  @doc """
  Adds the rectangle defined by the `t:Xairo.Rectangle.t/0` argument to the
  current path.

  The `Xairo.Rectangle` struct stores the origin (top left) corner of the
  rectangle, and its width and height.

  ## Example

      iex> rect = Rectangle.new(Point.new(10, 10), 30, 50)
      iex> Xairo.rectangle(image, rect)

  This code will result in a rectangle with a top left corner at {10, 10} and a
  bottom right corner at {40, 60}. It is equivalent to calling

  ```
  Xairo.move_to(image, {10, 10})
  |> Xairo.line_to({40, 10})
  |> Xairo.line_to({40, 60})
  |> Xairo.line_to({10, 60})
  |> Xairo.line_to({10, 10})
  ```
  """
  @spec rectangle(image(), Rectangle.t()) :: image_or_error()
  native_fn(:rectangle, [rectangle])

  @doc """
  Calls `rectangle/2` with the given image and a `t:Xairo.Rectangle.t/0`
  constructed from the remaining arguments.
  """
  @spec rectangle(image(), Xairo.point(), number(), number()) :: image_or_error()
  def rectangle(%{resource: _} = image, corner, width, height) do
    with rect <- Rectangle.new(corner, width, height), do: rectangle(image, rect)
  end

  @doc """
  Sets a pattern as the color source for the image.

  The pattern can be one of

  - `Xairo.Pattern.LinearGradient`
  - `Xairo.Pattern.RadialGradient`
  - `Xairo.Pattern.Mesh`

  See the documentation for each module to understand how to construct
  it so that it can be set as the source with this function. All desired
  colors stops must be set before the source is set.
  """
  @spec set_source(image(), Pattern.pattern()) :: image_or_error()
  def set_source(%{resource: _} = image, %LinearGradient{} = gradient) do
    Native.set_linear_gradient_source(image.resource, gradient.pattern)
    image
  end

  def set_source(%{resource: _} = image, %RadialGradient{} = gradient) do
    Native.set_radial_gradient_source(image.resource, gradient.pattern)
    image
  end

  def set_source(%{resource: _} = image, %Mesh{} = mesh) do
    Native.set_mesh_source(image.resource, mesh.pattern)
    image
  end

  def set_source(%{resource: _} = image, %Solid{} = pattern) do
    Native.set_solid_pattern_source(image.resource, pattern.pattern)
    image
  end

  def set_source(%{resource: _} = image, %Surface{} = pattern) do
    Native.set_surface_pattern_source(image.resource, pattern.resource)
    image
  end

  @doc """
  Sets the font size for the context.

  The font size set will apply to all subsequent calls to `show_text/2` until
  `set_font_size/2` is called again. If this function is not called at all
  before the first calls to `show_text/2`, the font size defaults to 10.0.
  """
  @spec set_font_size(image(), number()) :: image_or_error()
  native_fn(:set_font_size, [{font_size, Float}])

  @doc """
  Prints the given text onto the image.

  The text is displayed with the origin (lower left corner of the text) at the
  current point of the given path.  After `show_text/2` has been called, the
  current point changes by the values given by `x_advance` and `y_advance`
  fields on the given string's text extents. Generally, for all languages
  except some East-Asian languages that have a vertical text layout, the
  `y_advance` will be 0, and the `x_advance` will be roughly the width of the
  displayed text.

  See `Xairo.Text.Extents` for more details.
  """
  @spec show_text(image(), String.t()) :: image_or_error()
  native_fn(:show_text, [text])

  @doc """
  Sets the current font face for the image.

  Takes an as argument a `t:Xairo.Text.Font.t/0` "toy" font definition
  and uses those values to configure the font options for all subsequent calls
  to `show_text/2`.

  See `Xairo.Text.Font` for a discussion of the font struct.
  """
  @spec set_font_face(image(), Font.t()) :: image_or_error()
  native_fn(:set_font_face, [font])

  @doc """
  Creates and sets a font from the given arguments.

  Takes as arguments values for the font family, slant, and weight, and attempts
  to create a `Xairo.Text.Font` from them. If successful, it passes that font to
  `set_font_face/2`, or else returns an error.

  Passing `nil` for any of them will use the default value for that font option,
  but `nil` must be explicitly passed to ensure argument parsing.

  See `Xairo.Text.Font` for the allowed values for each field, as well as the
  default values for each.
  """
  @spec select_font_face(image(), atom(), atom(), atom()) :: image_or_error()
  def select_font_face(%{resource: _} = image, family, slant, weight) do
    with %Font{} = font <- Font.new(family: family, slant: slant, weight: weight) do
      set_font_face(image, font)
    end
  end

  @doc """
  Sets a transformation matrix for the current font

  Takes as an argument a `Xairo.Matrix` and sets it as the affine transform
  matrix for the current font face.

  See `Xairo.Matrix` for a description of the struct and its fields.
  """
  @spec set_font_matrix(image(), Matrix.t()) :: image_or_error()
  native_fn(:set_font_matrix, [matrix])

  @doc """
  Scales the image by the given amounts along the x and y axes.

  See [userspace and scale](#module-userspace-and-scale) in the docs above
  for a full discussion of how scaling works and how it is called on every image
  created by `new_image/3`.

  """
  @spec scale(image(), number(), number()) :: image_or_error()
  native_fn(:scale, [{sx, Float}, {sy, Float}])

  @doc """
  Shifts the origin of the current transformation matrix by {dx, dy} in
  userspace.

  This is applied after any existng transformations already applied to the
  userspace.

  ## Example

      iex> Xairo.translate(image, 20, 20)

  After calling this function, all coordinates passed to `move_to/2`,
  `line_to/2`, etc., will be shifted 20 pixels (in userspace) right and down.
  """
  @spec translate(image(), number(), number()) :: image_or_error()
  native_fn(:translate, [{dx, Float}, {dy, Float}])

  @doc """
  Adds a rotation of `rad` radians to the current transformation matrix.

  This is applied after any existing transformations of the image space.

  Positive values rotate counterclockwise (from the positive X axis to the
  positive Y axis), and negative values rotate clockwise.
  """
  @spec rotate(image(), number()) :: image_or_error()
  native_fn(:rotate, [{rad, Float}])

  @doc """
  Applies the given matrix to the context's current transformation matrix as an
  additional transformation.

  This new transformation takes place after all existing transformations on the
  current matrix.
  """
  @spec transform(image(), Matrix.t()) :: image_or_error()
  native_fn(:transform, [matrix])

  @doc """
  Resets the context's matrix to the identity matrix.

  This removes all scaling, rotation, and translation from the context. It is
  equivalent to passing `Matrix.new()` to `set_matrix/2`

  This means that any scaling you applied as part of `new_image/3` will be
  removed, and so if you wish to keep working at that original scale, you'll
  need to call `scale/3` again with the desired scale.
  """
  @spec identity_matrix(image()) :: image_or_error()
  native_fn(:identity_matrix)

  @doc """
  Sets the context's matrix.

  This overrides all existing transformations
  """
  @spec set_matrix(image(), Matrix.t()) :: image_or_error()
  native_fn(:set_matrix, [matrix])

  @doc """
  Returns a `Xairo.Matrix` representing the image's current transformation
  matrix.
  """
  @spec get_matrix(image()) :: Matrix.t()
  def get_matrix(%{resource: _} = image) do
    %Matrix{} = matrix = Xairo.Native.get_matrix(image.resource)
    matrix
  end

  @doc """
  Sets the document unit type for a `Xairo.Image.Svg`.

  See `t:Xairo.Image.Svg.svg_unit/0` for a list of the possible valid values
  for the `unit` argument.
  """
  @spec set_document_unit(Image.Svg.t(), Image.Svg.svg_unit()) :: Image.Svg.t()
  native_fn(:set_document_unit, [unit])

  @doc """
  Copies the current path from the image and returns it as a `Xairo.Path` struct.
  """
  @spec copy_path(image()) :: Xairo.Path.t()
  def copy_path(%{resource: _} = image) do
    with {:ok, path} <- Xairo.Native.copy_path(image.resource) do
      Xairo.Path.new(path)
    end
  end

  @doc """
  Copies the current path from the image replacing curves with straight line
  segments.

  The precision of the line segments is determined by the current tolerance of
  the image. See `get_tolerance/1` and `set_tolerance/2`.
  """
  @spec copy_path_flat(image()) :: Xairo.Path.t()
  def copy_path_flat(%{resource: _} = image) do
    with {:ok, path} <- Xairo.Native.copy_path_flat(image.resource) do
      Xairo.Path.new(path)
    end
  end

  @doc """
  Appends `path` to the current path of the image.
  """
  @spec append_path(image(), Xairo.Path.t()) :: image_or_error()
  def append_path(%{resource: _} = image, %Xairo.Path{resource: path}) do
    Xairo.Native.append_path(image.resource, path)
    image
  end

  @doc """
  Returns the current tolerance of the image.

  Tolerance determines how precisely a curved line is translated into straight
  line segments when calling `copy_path_flat/1`.
  """
  @spec get_tolerance(image()) :: float
  def get_tolerance(%{resource: _} = image) do
    Xairo.Native.get_tolerance(image.resource)
  end

  @doc """
  Sets the tolerance of the image.

  Tolerance determines how precisely a curved line is translated into straight
  line segments when calling `copy_path_flat/1`.
  """
  @spec set_tolerance(image(), float) :: image_or_error()
  native_fn(:set_tolerance, [{tolerance, Float}])

  @doc """
    Sets the given pattern as a mask layer on the image.

    When a pattern is set as a mask, only its alpha channel is
    applied to the final image.
  """
  @spec mask(image(), Xairo.Pattern.pattern()) :: image_or_error()
  def mask(%{resource: _} = image, %RadialGradient{} = gradient) do
    with {:ok, _} <- Xairo.Native.set_radial_gradient_mask(image.resource, gradient.pattern),
         do: image
  end

  def mask(%{resource: _} = image, %LinearGradient{} = gradient) do
    with {:ok, _} <- Xairo.Native.set_linear_gradient_mask(image.resource, gradient.pattern),
         do: image
  end

  def mask(%{resource: _} = image, %Mesh{} = mesh) do
    with {:ok, _} <- Xairo.Native.set_mesh_mask(image.resource, mesh.pattern), do: image
  end

  def mask(%{resource: _} = image, %Solid{} = pattern) do
    with {:ok, _} <- Xairo.Native.set_solid_pattern_mask(image.resource, pattern.pattern),
         do: image
  end

  @doc """
    Adds the given `Mask` as a mask surface on the image.

    See `Xairo.Mask` for a description of the expected struct format.
  """
  @spec mask_surface(image(), Xairo.Mask.t(), Xairo.point()) :: image_or_error()
  def mask_surface(%{resource: _} = image, %{resource: _} = mask, {x, y}) do
    mask_surface(image, mask, Point.new(x, y))
  end

  def mask_surface(%{resource: _} = image, %{resource: _} = mask, %Point{} = point) do
    with {:ok, _} <- Native.mask_surface(image.resource, mask.resource, point), do: image
  end

  @doc """
    Begins a new path on the image, clearing the existing path.

    Any current path components that have not been rendered are removed
    from the path.
  """
  @spec new_path(image()) :: image()
  def new_path(%{resource: _} = image) do
    Native.new_path(image.resource)
    image
  end

  @doc """
    Begins a new subpath, preserving the existing path.

    After this function is called, there is no current point set. Often
    this call is not needed, as most new path segments start with a call
    to `move_to/2`. One particularly useful instance for `new_sub_path/1` is
    when the new path begins with an arc.

    In this case beginning a new subpath removes the need to calculate and move to
    the beginning of the arc in order to avoid a line connecting it to the previous
    current point.
  """
  @spec new_sub_path(image()) :: image()
  def new_sub_path(%{resource: _} = image) do
    Native.new_sub_path(image.resource)
    image
  end

  @doc """
    Returns the image's current point, if it exists, or `nil` otherwise.
  """
  @spec current_point(image()) :: or_nil(Point.t())
  def current_point(%{resource: _} = image) do
    case Native.current_point(image.resource) do
      {:ok, {x, y}} -> Point.new(x, y)
      _ -> nil
    end
  end

  @doc """
    Adds closed paths to the current path representing the given text.

    Calling `fill/1` subequently to this function is equivalent to
    calling `show_text/2` with the same text.
  """
  @spec text_path(image(), String.t()) :: image()
  native_fn(:text_path, [text])
end
