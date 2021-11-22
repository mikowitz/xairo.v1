use cairo::{Context, Format, ImageSurface};
use rustler::ResourceArc;
use std::fs::File;
use crate::error::Error;

#[derive(Debug)]
pub struct XairoImage {
    pub context: Context,
    pub surface: ImageSurface
}

impl XairoImage {
    pub fn new(width: i32, height: i32) -> Result<Self, Error> {
        match ImageSurface::create(Format::ARgb32, width, height) {
            Ok(surface) => {
                match Context::new(&surface) {
                    Ok(context) => Ok(Self { context, surface }),
                    Err(_) => Err(Error::ContextCreate)
                }
            },
            Err(_) => Err(Error::SurfaceCreate)
        }
    }

    pub fn save(&self, filename: String) -> Result<(), Error> {
        match File::create(&filename) {
            Ok(mut file) =>
                match self.surface.write_to_png(&mut file) {
                    Ok(_) => Ok(()),
                    Err(_) => Err(Error::FileWrite(filename))
                },
            Err(_) => Err(Error::FileCreate(filename))
        }
    }

    pub fn scale(&self, sx: f64, sy: f64) -> &Self {
        self.context.scale(sx, sy);
        self
    }
}

unsafe impl Send for XairoImage { }
unsafe impl Sync for XairoImage { }

pub type ImageArc = ResourceArc<XairoImage>;
pub type ImageResult = Result<ImageArc, Error>;

#[rustler::nif]
pub fn new_image(width: i32, height: i32) -> ImageResult {
    match XairoImage::new(width, height) {
        Ok(image) => Ok(ResourceArc::new(image)),
        Err(e) => Err(e)
    }
}

#[rustler::nif]
pub fn save_image(image: ImageArc, filename: String) -> ImageResult {
    match image.save(filename) {
        Ok(_) => Ok(image),
        Err(e) => Err(e)
    }
}

#[rustler::nif]
pub fn scale(image: ImageArc, sx: f64, sy: f64) -> ImageArc {
    image.scale(sx, sy);
    image
}


