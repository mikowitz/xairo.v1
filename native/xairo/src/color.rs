use crate::xairo_image::{ImageArc, ImageResult};
use crate::error::Error;

#[derive(Copy,Clone,Debug,NifStruct)]
#[module = "Xairo.RGBA"]
pub struct Rgba {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64
}

impl Rgba {
    pub fn to_tuple(self) -> (f64, f64, f64, f64) {
        (self.red, self.green, self.blue, self.alpha)
    }
}

#[rustler::nif]
fn set_color(image: ImageArc, rgba: Rgba) -> ImageArc {
    let (r, g, b, a) = rgba.to_tuple();
    image.context.set_source_rgba(r, g, b, a);
    image
}

#[rustler::nif]
fn stroke(image: ImageArc) -> ImageResult {
    match image.context.stroke() {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::PathRender("stroke"))
    }
}

#[rustler::nif]
fn fill(image: ImageArc) -> ImageResult {
    match image.context.fill() {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::PathRender("fill"))
    }
}

#[rustler::nif]
fn paint(image: ImageArc) -> ImageResult {
    match image.context.paint() {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::PathRender("paint"))
    }
}
