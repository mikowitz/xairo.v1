use crate::shapes::Point;
use crate::color::Rgba;
use crate::shapes::Curve;
use crate::xairo_image::{ImageArc, ImageResult};
use cairo::MeshCorner;
use crate::error::Error;

#[derive(Debug,NifUntaggedEnum)]
pub enum SidePath {
    Point(Point),
    Curve(Curve)
}

#[derive(Debug,NifStruct)]
#[module = "Xairo.Pattern.Mesh"]
pub struct Mesh {
    pub start: Point,
    side_paths: Vec<SidePath>,
    corner_colors: Vec<Option<Rgba>>,
    control_points: Vec<Option<Point>>
}

#[rustler::nif]
fn set_mesh_source(image: ImageArc, mesh: Mesh) -> ImageResult {
    let m = cairo::Mesh::new();
    m.begin_patch();
    m.move_to(mesh.start.x, mesh.start.y);

    draw_paths(&m, &mesh.side_paths);
    set_colors(&m, &mesh.corner_colors);
    set_control_points(&m, &mesh.control_points);

    m.end_patch();

    match image.context.set_source(&m) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("mesh"))
    }
}

fn draw_paths<'a>(mesh: &'a cairo::Mesh, side_paths: &[SidePath]) -> &'a cairo::Mesh {
    for path in side_paths {
        match path {
            SidePath::Point(point) => mesh.line_to(point.x, point.y),
            SidePath::Curve(curve) => {
                let ((x1, y1), (x2, y2), (x3, y3)) = curve.to_tuple();
                mesh.curve_to(x1, y1, x2, y2, x3, y3);
            }
        }
    };
    mesh
}

fn set_colors<'a>(mesh: &'a cairo::Mesh, corner_colors: &[Option<Rgba>]) -> &'a cairo::Mesh {
    for (i, color) in corner_colors.iter().enumerate().take(4) {
        match color {
            Some(rgba) => {
                let (r, g, b, a) = rgba.to_tuple();
                if let Some(corner) = mesh_corner(i) {
                    mesh.set_corner_color_rgba(corner, r, g, b, a);
                }
            },
            None => ()
        }
    };
    mesh
}

fn set_control_points<'a>(mesh: &'a cairo::Mesh, control_points: &[Option<Point>]) -> &'a cairo::Mesh {
    for (i, point) in control_points.iter().enumerate().take(4) {
        match point {
            Some(point) => {
                if let Some(corner) = mesh_corner(i) {
                    mesh.set_control_point(corner, point.x, point.y);
                }
            },
            None => ()
        }
    };
    mesh
}

fn mesh_corner(index: usize) -> Option<MeshCorner> {
    match index {
        0 => Some(MeshCorner::MeshCorner0),
        1 => Some(MeshCorner::MeshCorner1),
        2 => Some(MeshCorner::MeshCorner2),
        3 => Some(MeshCorner::MeshCorner3),
        _ => None
    }
}
