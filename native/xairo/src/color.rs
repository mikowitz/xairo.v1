use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;

#[derive(Debug,NifStruct)]
#[module = "Xairo.RGBA"]
pub struct RGBA {
    pub red: f64,
    pub green: f64,
    pub blue: f64,
    pub alpha: f64
}

impl RGBA {
    pub fn to_tuple(self: &Self) -> (f64, f64, f64, f64) {
        (self.red, self.green, self.blue, self.alpha)
    }
}

#[rustler::nif]
fn set_color(image: ImageArc, rgba: RGBA) -> XairoResult {
    let (r, g, b, a) = rgba.to_tuple();
    image.context.set_source_rgba(r, g, b, a);
    Ok(image)
}

#[rustler::nif]
fn stroke(image: ImageArc) -> XairoResult {
    if let Ok(_) = image.context.stroke() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn fill(image: ImageArc) -> XairoResult {
    if let Ok(_) = image.context.fill() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn paint(image: ImageArc) -> XairoResult {
    if let Ok(_) = image.context.paint() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}
