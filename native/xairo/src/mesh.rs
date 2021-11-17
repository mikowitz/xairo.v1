use crate::shapes::Point;
use crate::color::RGBA;
use crate::shapes::Curve;
use crate::xairo_image::{ImageArc, XairoResult};
use cairo::{Mesh, MeshCorner};

#[derive(Debug,NifUntaggedEnum)]
pub enum SidePath {
    Point(Point),
    Curve(Curve)
}

#[derive(Debug,NifStruct)]
#[module = "Xairo.Pattern.Mesh"]
pub struct XairoMesh {
    pub start: Point,
    side_paths: Vec<SidePath>,
    corner_colors: Vec<Option<RGBA>>,
    control_points: Vec<Option<Point>>
}

#[rustler::nif]
fn set_mesh_source(image: ImageArc, mesh: XairoMesh) -> XairoResult {
    let m = Mesh::new();
    m.begin_patch();
    m.move_to(mesh.start.x, mesh.start.y);

    draw_paths(&m, &mesh.side_paths);
    set_colors(&m, &mesh.corner_colors);
    set_control_points(&m, &mesh.control_points);

    m.end_patch();

    if let Ok(_) = image.context.set_source(&m) {
        Ok(image)
    } else {
        Err(crate::atoms::system::badarg())
    }
}

fn draw_paths<'a>(m: &'a Mesh, side_paths: &'a Vec<SidePath>) -> &'a Mesh {
    for path in side_paths {
        match path {
            SidePath::Point(point) => m.line_to(point.x, point.y),
            SidePath::Curve(curve) => {
                m.curve_to(
                    curve.first_control_point.x, curve.first_control_point.y,
                    curve.second_control_point.x, curve.second_control_point.y,
                    curve.curve_end.x, curve.curve_end.y
                );
            }
        }
    };
    m
}

fn set_colors<'a>(m: &'a Mesh, corner_colors: &'a Vec<Option<RGBA>>) -> &'a Mesh {
    for i in 0..4 {
        match &corner_colors[i] {
            Some(rgba) => {
                let (r, g, b, a) = rgba.to_tuple();
                if let Some(corner) = mesh_corner(i) {
                    m.set_corner_color_rgba(corner, r, g, b, a);
                }
            },
            None => ()
        }
    };
    m
}

fn set_control_points<'a>(m: &'a Mesh, control_points: &'a Vec<Option<Point>>) -> &'a Mesh {
    for i in 0..4 {
        match &control_points[i] {
            Some(point) => {
                if let Some(corner) = mesh_corner(i) {
                    m.set_control_point(corner, point.x, point.y);
                }
            },
            None => ()
        }
    };
    m
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
