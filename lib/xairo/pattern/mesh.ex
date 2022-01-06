defmodule Xairo.Pattern.Mesh do
  @moduledoc """
  Models a tensor-product patch mesh that can be used as an image's color source.

  At the most basic level, a mesh is defined by 4 Bézier curves that describe
  the sides of the mesh, joined at 4 corners. Each corner is assigned an RGBA color
  (if no color is set, it defaults to fully transparent black), and each corner can
  have an optional additional control point set to determine how the colors blend between
  the corners.

  A triangular mesh can be created by only defining 3 sides.

  In addition to Bézier curves, the 4 sides can also be defined by simple lines.

  For a more detailed understanding of how these patterns work, see the
  [cairo definition](https://www.cairographics.org/manual/cairo-cairo-pattern-t.html#cairo-pattern-create-mesh).

  The following diagram (taken from the documentation above), shows the basic shape of a mesh pattern,
  and will be a useful reference in explaining how to construct a `t:Xairo.Mesh.t/0` struct

  ```
        C1        Side 1           C2
         +-------------------------+
         |                         |
         |    P1             P2    |
         |                         |
  Side 0 |                         | Side 2
         |                         |
         |                         |
         |    P0             P3    |
         |                         |
         +-------------------------+
       C0          Side 3          C3
  ```

  **NB** in this diagram the starting point of the mesh is C0 in the bottom left, but
  the mesh can be oriented starting from any corner. In the example below, for
  instance, C0 is at {0,0} in the top left.

  ## Example

  ### Creating the mesh struct

  Create a new Mesh struct and sets the start point (C0 in the diagram above)

  ```
  mesh = Mesh.new(Point.new(0,0))
  ```

  draws the 4 sides of the mesh

  ```
  mesh
  |> Mesh.curve_to({30, 20}, {80, -10}, {100, 0}) # draws Side 0 as a curve from C0 to C1
  |> Mesh.line_to({100, 100})                     # draws Side 1 as a straight line from C1 to C2
  |> Mesh.line_to({0, 100})                       # draws Side 2 as a straight line from C2 to C3
  |> Mesh.curve_to({-20, 80}, {30, 30}, {0, 0})   # draws Side 3 as a curve from C3 to C0
  ```

  set colors for each of the four corners

  ```
  mesh
  |> set_corner_color(0, RGBA.new(1, 0, 0)) # sets the color at C0 to red
  |> set_corner_color(1, RGBA.new(0, 1, 0)) # sets the color at C1 to green
  |> set_corner_color(2, RGBA.new(1, 0, 1)) # sets the color at C2 to blue
  |> set_corner_color(3, RGBA.new(0, 1, 1)) # sets the color at C3 to cyan
  ```

  set control points for corners C0 and C2

  ```
  mesh
  |> set_control_point(0, Point.new(20, 20))
  |> set_control_point(2, Point.new(50, 50))
  ```

  set the mesh as the color source for an image

  ```
  Xairo.set_source(image, mesh)
  ```
  """
  alias Xairo.{Curve, Point, RGBA}

  defstruct [
    :start,
    :side_paths,
    :corner_colors,
    :control_points
  ]

  @type corner_index :: 0 | 1 | 2 | 3
  @type path_definition :: Point.t() | Curve.t()
  @type t :: %__MODULE__{
          start: Point.t(),
          side_paths: [path_definition()],
          corner_colors: [Xairo.or_nil(RGBA)],
          control_points: [Xairo.or_nil(Point)]
        }

  @doc """
  Initializes a new mesh pattern with a start point.

  Returns a `t:Xairo.Mesh.t/0` struct with its C0 coordinate set in userspace.

  ## Example

      iex> Mesh.new({0,0})
      #Mesh<(0.0, 0.0), 0, 0>

  """
  @spec new(Xairo.point()) :: __MODULE__.t()
  def new(%Point{} = start) do
    %__MODULE__{
      start: start,
      side_paths: [],
      corner_colors: [nil, nil, nil, nil],
      control_points: [nil, nil, nil, nil]
    }
  end

  def new({x, y}) do
    with start <- Point.new(x, y), do: new(start)
  end

  @doc """
  Adds a new side of the mesh as a straight line.

  The point passed as an argument is the next corner of the mesh.

  ## Example

      iex> mesh = Mesh.new({0, 0})
      #Mesh<(0.0, 0.0), 0, 0>
      iex> Mesh.line_to(mesh, {100, 0})
      #Mesh<(0.0, 0.0), 1, 0>

  """
  @spec line_to(__MODULE__.t(), Xairo.point()) :: __MODULE__.t()
  def line_to(%__MODULE__{} = mesh, point) do
    %__MODULE__{
      mesh
      | side_paths: mesh.side_paths ++ [Point.from(point)]
    }
  end

  @doc """
  Adds a new side of the mesh as a Bézier curve.

  The points passed in as arguments are the

  - first control point
  - second control point
  - curve end

  of the curve, respectively

  ## Example

      iex> mesh = Mesh.new({0, 0})
      #Mesh<(0.0, 0.0), 0, 0>
      iex> Mesh.curve_to(mesh, {20, 10}, {70, -10}, {100, 0})
      #Mesh<(0.0, 0.0), 1, 0>

  """
  @spec curve_to(__MODULE__.t(), Curve.t()) :: __MODULE__.t()
  def curve_to(%__MODULE__{} = mesh, %Curve{} = curve) do
    %__MODULE__{
      mesh
      | side_paths: mesh.side_paths ++ [curve]
    }
  end

  @doc """
  Calls `curve_to/2` with `mesh` and a `Xairo.Curve` constructed from the
  remaining arguments.
  """
  @spec curve_to(__MODULE__.t(), Xairo.coordinate(), Xairo.coordinate(), Xairo.coordinate()) ::
          __MODULE__.t()
  def curve_to(%__MODULE__{} = mesh, p1, p2, p3) do
    with curve <- Curve.new(p1, p2, p3), do: curve_to(mesh, curve)
  end

  @doc """
  Sets the corner color for the given corner.

  Takes as arguments, in addition to the `t:Xairo.Pattern.Mesh.t/0` struct, the index of the corner 0..3, and the color to be assigned.

  ## Example

      iex> mesh = Mesh.new({0, 0})
      #Mesh<(0.0, 0.0), 0, 0>
      iex> Mesh.set_corner_color(mesh, 0, RGBA.new(1, 0, 0))
      #Mesh<(0.0, 0.0), 0, 1>

  """
  @spec set_corner_color(__MODULE__.t(), corner_index, RGBA.t()) :: __MODULE__.t()
  def set_corner_color(%__MODULE__{} = mesh, corner_index, %RGBA{} = color)
      when is_number(corner_index) do
    corner_colors = List.insert_at(mesh.corner_colors, corner_index, color)
    %__MODULE__{mesh | corner_colors: corner_colors}
  end

  @doc """
  Adds a control point for the given corner.

  Takes as arguments, in addition to the `t:Xairo.Pattern.Mesh.t/0` struct, the
  index of the corner 0..3, and the coordinates (in userspace) of the control
  point.

  These control points further affect the blending of the colors in the mesh.

  ## Example

      iex> Mesh.new({0, 0})
      ...> |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0))
      ...> |> Mesh.set_control_point(0, {50, 50})
      #Mesh<(0.0, 0.0), 0, 1>
  """
  @spec set_control_point(__MODULE__.t(), corner_index(), Xairo.point()) :: __MODULE__.t()
  def set_control_point(%__MODULE__{} = mesh, corner_index, point) when is_number(corner_index) do
    control_points = List.insert_at(mesh.control_points, corner_index, Point.from(point))
    %__MODULE__{mesh | control_points: control_points}
  end

  defimpl Inspect do
    def inspect(%Xairo.Pattern.Mesh{} = mesh, _opts) do
      [
        "#Mesh<",
        [
          inspect_point(mesh.start),
          length(mesh.side_paths),
          length(Enum.reject(mesh.corner_colors, &is_nil/1))
        ]
        |> Enum.join(", "),
        ">"
      ]
      |> Enum.join("")
    end

    defp inspect_point(%Point{x: x, y: y}) do
      "(#{x}, #{y})"
    end
  end
end
