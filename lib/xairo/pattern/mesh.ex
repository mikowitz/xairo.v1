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
  mesh = Mesh.new()
  |> Mesh.begin_patch()
  |> Mesh.move_to(Point.new(0,0))
  ```

  draw the 4 sides of the mesh

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
  |> Mesh.set_corner_color(0, RGBA.new(1, 0, 0)) # sets the color at C0 to red
  |> Mesh.set_corner_color(1, RGBA.new(0, 1, 0)) # sets the color at C1 to green
  |> Mesh.set_corner_color(2, RGBA.new(1, 0, 1)) # sets the color at C2 to blue
  |> Mesh.set_corner_color(3, RGBA.new(0, 1, 1)) # sets the color at C3 to cyan
  ```

  set control points for corners C0 and C2

  ```
  mesh
  |> Mesh.set_control_point(0, Point.new(20, 20))
  |> Mesh.set_control_point(2, Point.new(50, 50))
  ```

  finalize the current patch for the mesh

  ```
  Mesh.end_patch(mesh)
  ```

  and set the mesh as the color source for an image

  ```
  Xairo.set_source(image, mesh)
  ```
  """
  alias Xairo.{Point, RGBA}

  defstruct [:pattern]

  @type t :: %__MODULE__{
          pattern: reference()
        }

  @doc """
    Initialize a new mesh.
  """
  @spec new() :: __MODULE__.t()
  def new do
    %__MODULE__{
      pattern: Xairo.Native.mesh_new()
    }
  end

  @doc """
    Starts a new patch (layer) of the mesh pattern.

    A mesh can have any number of patches. When the mesh
    is used as a source, the patches are rendered in order
    from bottom up, so the most recently defined patch is on
    top.
  """
  @spec begin_patch(__MODULE__.t()) :: __MODULE__.t()
  def begin_patch(%__MODULE__{} = mesh) do
    Xairo.Native.mesh_begin_patch(mesh.pattern)
    mesh
  end

  @doc """
    Marks the completion of a patch for the mesh.

    For a mesh pattern to be considered valid, it must have matched
    pairs of `begin_patch/1` and `end_patch/1`.
  """
  @spec end_patch(__MODULE__.t()) :: __MODULE__.t()
  def end_patch(%__MODULE__{} = mesh) do
    Xairo.Native.mesh_end_patch(mesh.pattern)
    mesh
  end

  @doc """
    Defines the first point of the current patch for the mesh pattern.

    This should only be called directly after calling `begin_patch/1`. Once
    the initial point is set, the subsequent points will be defined via
    calls to `line_to/2` or `curve_to/2`.

  """
  @spec move_to(__MODULE__.t(), Xairo.point()) :: __MODULE__.t()
  def move_to(%__MODULE__{} = mesh, point) do
    Xairo.Native.mesh_move_to(mesh.pattern, Point.from(point))
    mesh
  end

  @doc """
    Creates a side of the current patch defined by a straight line from
    the current point to the prowided point.
  """
  @spec line_to(__MODULE__.t(), Xairo.point()) :: __MODULE__.t()
  def line_to(%__MODULE__{} = mesh, point) do
    Xairo.Native.mesh_line_to(mesh.pattern, Point.from(point))
    mesh
  end

  @doc """
    Creates a side of the current patch defined by a Bézier curve
    calculated from the current point and the three provided points.
  """
  @spec curve_to(__MODULE__.t(), Xairo.point(), Xairo.point(), Xairo.point()) :: __MODULE__.t()
  def curve_to(%__MODULE__{} = mesh, point1, point2, point3) do
    Xairo.Native.mesh_curve_to(
      mesh.pattern,
      Point.from(point1),
      Point.from(point2),
      Point.from(point3)
    )

    mesh
  end

  @doc """
    Sets the control point for the given corner of the current patch.

    When mesh patch sides are defined, default values for the control
    points are calculated, but this function can be used to overwrite
    those defaults to affect how the colors of the mesh are blended.
  """
  @spec set_control_point(__MODULE__.t(), integer(), Xairo.point()) :: __MODULE__.t()
  def set_control_point(%__MODULE__{} = mesh, corner, point) do
    Xairo.Native.mesh_set_control_point(
      mesh.pattern,
      corner,
      Point.from(point)
    )

    mesh
  end

  @doc """
    Returns the control point on the mesh for the given patch and corner.

    If there is no patch at the given index, returns an error.
  """
  @spec control_point(__MODULE__.t(), integer(), integer()) :: Point.t() | Xairo.error()
  def control_point(%__MODULE__{} = mesh, patch_num, corner) do
    with {:ok, point} <- Xairo.Native.mesh_control_point(mesh.pattern, patch_num, corner),
         do: point
  end

  @doc """
    Sets the color for the given corner of the current patch.
  """
  @spec set_corner_color(__MODULE__.t(), integer(), RGBA.t()) :: __MODULE__.t()
  def set_corner_color(%__MODULE__{} = mesh, corner, color) do
    Xairo.Native.mesh_set_corner_color(
      mesh.pattern,
      corner,
      color
    )

    mesh
  end

  @doc """
    Returns the color on the mesh for the given patch and corner.

    If there is no patch at the given index, returns an error.
  """
  @spec corner_color(__MODULE__.t(), integer(), integer()) :: RGBA.t() | Xairo.error()
  def corner_color(%__MODULE__{} = mesh, patch_num, corner) do
    with {:ok, color} <- Xairo.Native.mesh_corner_color(mesh.pattern, patch_num, corner),
         do: color
  end
end
