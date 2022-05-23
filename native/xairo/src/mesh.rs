use crate::color::Rgba;
use crate::error::Error;
use crate::shapes::Point;
use crate::xairo_image::{ImageArc, ImageResult};
use cairo::MeshCorner;
use rustler::ResourceArc;

pub struct XairoMesh {
    pub mesh: cairo::Mesh,
}

unsafe impl Send for XairoMesh {}
unsafe impl Sync for XairoMesh {}

pub type MeshArc = ResourceArc<XairoMesh>;

#[rustler::nif]
fn mesh_new() -> MeshArc {
    ResourceArc::new(XairoMesh {
        mesh: cairo::Mesh::new(),
    })
}

#[rustler::nif]
fn mesh_begin_patch(mesh: MeshArc) -> MeshArc {
    mesh.mesh.begin_patch();
    mesh
}

#[rustler::nif]
fn mesh_end_patch(mesh: MeshArc) -> MeshArc {
    mesh.mesh.end_patch();
    mesh
}

#[rustler::nif]
fn mesh_move_to(mesh: MeshArc, point: Point) -> MeshArc {
    mesh.mesh.move_to(point.x, point.y);
    mesh
}

#[rustler::nif]
fn mesh_line_to(mesh: MeshArc, point: Point) -> MeshArc {
    mesh.mesh.line_to(point.x, point.y);
    mesh
}

#[rustler::nif]
fn mesh_curve_to(mesh: MeshArc, point1: Point, point2: Point, point3: Point) -> MeshArc {
    mesh.mesh
        .curve_to(point1.x, point1.y, point2.x, point2.y, point3.x, point3.y);
    mesh
}

#[rustler::nif]
fn mesh_set_control_point(mesh: MeshArc, index: usize, point: Point) -> MeshArc {
    if let Some(corner) = mesh_corner(index) {
        mesh.mesh.set_control_point(corner, point.x, point.y);
    }
    mesh
}

#[rustler::nif]
fn mesh_control_point(mesh: MeshArc, patch_num: usize, corner: usize) -> Result<Point, Error> {
    if let Some(mesh_corner) = mesh_corner(corner) {
        match mesh.mesh.control_point(patch_num, mesh_corner) {
            Ok((x, y)) => Ok(Point { x, y }),
            Err(_) => Err(Error::ControlPointError(corner, patch_num)),
        }
    } else {
        Err(Error::ControlPointError(corner, patch_num))
    }
}

#[rustler::nif]
fn mesh_set_corner_color(mesh: MeshArc, index: usize, rgba: Rgba) -> MeshArc {
    if let Some(corner) = mesh_corner(index) {
        let (r, g, b, a) = rgba.to_tuple();
        mesh.mesh.set_corner_color_rgba(corner, r, g, b, a);
    }
    mesh
}

#[rustler::nif]
fn set_mesh_source(image: ImageArc, mesh: MeshArc) -> ImageResult {
    match image.context.set_source(&mesh.mesh) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("mesh")),
    }
}

#[rustler::nif]
fn set_mesh_mask(image: ImageArc, mesh: MeshArc) -> ImageResult {
    match image.context.mask(&mesh.mesh) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("mesh")),
    }
}

fn mesh_corner(index: usize) -> Option<MeshCorner> {
    match index {
        0 => Some(MeshCorner::MeshCorner0),
        1 => Some(MeshCorner::MeshCorner1),
        2 => Some(MeshCorner::MeshCorner2),
        3 => Some(MeshCorner::MeshCorner3),
        _ => None,
    }
}
