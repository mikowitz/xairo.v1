use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;

#[derive(Debug,NifStruct)]
#[module = "Xairo.RGBA"]
pub struct Rgba {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64
}

impl Rgba {
    pub fn to_tuple(&self) -> (f64, f64, f64, f64) {
        (self.red, self.green, self.blue, self.alpha)
    }
}

#[rustler::nif]
fn set_color(image: ImageArc, rgba: Rgba) -> XairoResult {
    let (r, g, b, a) = rgba.to_tuple();
    image.context.set_source_rgba(r, g, b, a);
    Ok(image)
}

#[rustler::nif]
fn stroke(image: ImageArc) -> XairoResult {
    if image.context.stroke().is_ok() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn fill(image: ImageArc) -> XairoResult {
    if image.context.fill().is_ok() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn paint(image: ImageArc) -> XairoResult {
    if image.context.paint().is_ok() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}
