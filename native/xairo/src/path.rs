use cairo::Path;
use crate::xairo_image::ImageArc;
use rustler::ResourceArc;
use crate::error::Error;

#[derive(Debug)]
pub struct XairoPath {
    pub path: Path
}

unsafe impl Send for XairoPath { }
unsafe impl Sync for XairoPath { }

pub type PathArc = ResourceArc<XairoPath>;
pub type PathResult = Result<PathArc, Error>;


#[rustler::nif]
fn copy_path(image: ImageArc) -> PathResult {
    match image.context.copy_path() {
        Ok(path) => Ok(ResourceArc::new(XairoPath { path })),
        Err(_) => Err(Error::CopyPath)
    }
}

#[rustler::nif]
fn copy_path_flat(image: ImageArc) -> PathResult {
    match image.context.copy_path_flat() {
        Ok(path) => Ok(ResourceArc::new(XairoPath { path })),
        Err(_) => Err(Error::CopyPath)
    }
}

#[rustler::nif]
fn append_path(image: ImageArc, path: PathArc) -> ImageArc {
    image.context.append_path(&path.path);
    image
}

#[rustler::nif]
fn get_tolerance(image: ImageArc) -> f64 {
    image.context.tolerance()
}

#[rustler::nif]
fn set_tolerance(image: ImageArc, tolerance: f64) -> ImageArc {
    image.context.set_tolerance(tolerance);
    image
}
