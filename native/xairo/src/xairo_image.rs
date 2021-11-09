use cairo::{Context, Format, ImageSurface};
use rustler::Atom;
use crate::atoms::system;
use std::fs::File;

pub struct XairoImage {
    pub context: Context,
    pub surface: ImageSurface
}

impl XairoImage {
    pub fn new(width: i32, height: i32) -> Result<Self, Atom> {
        if let Ok(surface) = ImageSurface::create(Format::ARgb32, width, height) {
            if let Ok(context) = Context::new(&surface) {
                Ok(XairoImage { context, surface })
            } else {
                Err(system::image_creation_error())
            }
        } else {
            Err(system::image_creation_error())
        }
    }

    pub fn save(self: &Self, filename: String) -> Result<(), Atom> {
        if let Ok(mut file) = File::create(filename) {
            if let Ok(_) = self.surface.write_to_png(&mut file) {
                Ok(())
            } else {
                Err(system::image_save_error())
            }
        } else {
            Err(system::file_creation_error())
        }
    }
}

unsafe impl Send for XairoImage { }
unsafe impl Sync for XairoImage { }
