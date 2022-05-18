use crate::error::Error;
use cairo::{Context, Format, ImageSurface, PdfSurface, PsSurface, SvgSurface};
use rustler::ResourceArc;
use std::fs::File;

#[derive(Copy, Clone, Debug, NifUnitEnum)]
pub enum SvgUnit {
    Em,
    Ex,
    Px,
    In,
    Cm,
    Mm,
    Pt,
    Pc,
    Percent,
    User,
}

#[derive(Debug)]
pub enum XairoSurface {
    Image(ImageSurface),
    Svg(SvgSurface),
    Pdf(PdfSurface),
    Ps(PsSurface),
}

#[derive(Debug)]
pub struct XairoImage {
    pub context: Context,
    pub surface: XairoSurface,
}

impl XairoImage {
    pub fn new_png(width: i32, height: i32) -> Result<Self, Error> {
        match ImageSurface::create(Format::ARgb32, width, height) {
            Ok(surface) => match Context::new(&surface) {
                Ok(context) => Ok(Self {
                    context,
                    surface: XairoSurface::Image(surface),
                }),
                Err(_) => Err(Error::ContextCreate),
            },
            Err(_) => Err(Error::SurfaceCreate),
        }
    }

    pub fn new_svg(width: f64, height: f64, filename: String) -> Result<Self, Error> {
        match SvgSurface::new(width, height, Some(filename)) {
            Ok(surface) => match Context::new(&surface) {
                Ok(context) => Ok(Self {
                    context,
                    surface: XairoSurface::Svg(surface),
                }),
                Err(_) => Err(Error::ContextCreate),
            },
            Err(_) => Err(Error::SurfaceCreate),
        }
    }

    pub fn new_pdf(width: f64, height: f64, filename: String) -> Result<Self, Error> {
        match PdfSurface::new(width, height, filename) {
            Ok(surface) => match Context::new(&surface) {
                Ok(context) => Ok(Self {
                    context,
                    surface: XairoSurface::Pdf(surface),
                }),
                Err(_) => Err(Error::ContextCreate),
            },
            Err(_) => Err(Error::SurfaceCreate),
        }
    }

    pub fn new_ps(width: f64, height: f64, filename: String) -> Result<Self, Error> {
        match PsSurface::new(width, height, filename) {
            Ok(surface) => match Context::new(&surface) {
                Ok(context) => Ok(Self {
                    context,
                    surface: XairoSurface::Ps(surface),
                }),
                Err(_) => Err(Error::ContextCreate),
            },
            Err(_) => Err(Error::SurfaceCreate),
        }
    }

    pub fn save(&self, filename: String) -> Result<(), Error> {
        match File::create(&filename) {
            Ok(mut file) => match &self.surface {
                XairoSurface::Image(surface) => match surface.write_to_png(&mut file) {
                    Ok(_) => Ok(()),
                    Err(_) => Err(Error::FileWrite(filename)),
                },
                XairoSurface::Svg(surface) => {
                    surface.finish();
                    Ok(())
                }
                XairoSurface::Pdf(surface) => {
                    surface.finish();
                    Ok(())
                }
                XairoSurface::Ps(surface) => {
                    surface.finish();
                    Ok(())
                }
            },
            Err(_) => Err(Error::FileCreate(filename)),
        }
    }

    fn set_document_unit(&self, unit: SvgUnit) -> Result<(), Error> {
        match &self.surface {
            XairoSurface::Svg(surface) => {
                surface.clone().set_document_unit(match_svg_unit(unit));
                Ok(())
            }
            _ => Err(Error::FileTypeMismatch),
        }
    }
}

unsafe impl Send for XairoImage {}
unsafe impl Sync for XairoImage {}

pub type ImageArc = ResourceArc<XairoImage>;
pub type ImageResult = Result<ImageArc, Error>;

#[rustler::nif]
pub fn new_png_image(width: i32, height: i32) -> ImageResult {
    match XairoImage::new_png(width, height) {
        Ok(image) => Ok(ResourceArc::new(image)),
        Err(e) => Err(e),
    }
}

#[rustler::nif]
pub fn new_pdf_image(width: f64, height: f64, filename: String) -> ImageResult {
    match XairoImage::new_pdf(width, height, filename) {
        Ok(image) => Ok(ResourceArc::new(image)),
        Err(e) => Err(e),
    }
}

#[rustler::nif]
pub fn new_ps_image(width: f64, height: f64, filename: String) -> ImageResult {
    match XairoImage::new_ps(width, height, filename) {
        Ok(image) => Ok(ResourceArc::new(image)),
        Err(e) => Err(e),
    }
}

#[rustler::nif]
pub fn new_svg_image(width: f64, height: f64, filename: String) -> ImageResult {
    match XairoImage::new_svg(width, height, filename) {
        Ok(image) => Ok(ResourceArc::new(image)),
        Err(e) => Err(e),
    }
}

#[rustler::nif]
pub fn save_image(image: ImageArc, filename: String) -> ImageResult {
    match image.save(filename) {
        Ok(_) => Ok(image),
        Err(e) => Err(e),
    }
}

#[rustler::nif]
pub fn set_document_unit(image: ImageArc, unit: SvgUnit) -> ImageResult {
    match image.set_document_unit(unit) {
        Ok(_) => Ok(image),
        Err(e) => Err(e),
    }
}

fn match_svg_unit(unit: SvgUnit) -> cairo::SvgUnit {
    match unit {
        SvgUnit::Em => cairo::SvgUnit::Em,
        SvgUnit::Ex => cairo::SvgUnit::Ex,
        SvgUnit::Px => cairo::SvgUnit::Px,
        SvgUnit::In => cairo::SvgUnit::In,
        SvgUnit::Cm => cairo::SvgUnit::Cm,
        SvgUnit::Mm => cairo::SvgUnit::Mm,
        SvgUnit::Pt => cairo::SvgUnit::Pt,
        SvgUnit::Pc => cairo::SvgUnit::Pc,
        SvgUnit::Percent => cairo::SvgUnit::Percent,
        SvgUnit::User => cairo::SvgUnit::User,
    }
}
