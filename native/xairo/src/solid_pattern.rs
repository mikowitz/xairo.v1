use crate::color::Rgba;
use crate::error::Error;
use crate::xairo_image::{ImageArc, ImageResult};
use rustler::ResourceArc;

pub struct XairoSolidPattern {
    pub pattern: cairo::SolidPattern,
}

unsafe impl Send for XairoSolidPattern {}
unsafe impl Sync for XairoSolidPattern {}

pub type SolidPatternArc = ResourceArc<XairoSolidPattern>;

#[rustler::nif]
fn solid_pattern_from_rgba(color: Rgba) -> SolidPatternArc {
    let (r, g, b, a) = color.to_tuple();
    ResourceArc::new(XairoSolidPattern {
        pattern: cairo::SolidPattern::from_rgba(r, g, b, a),
    })
}

#[rustler::nif]
fn solid_pattern_color(pattern: SolidPatternArc) -> Result<Rgba, Error> {
    match pattern.pattern.rgba() {
        Ok((red, green, blue, alpha)) => Ok(Rgba {
            red,
            green,
            blue,
            alpha,
        }),
        Err(_) => Err(Error::SolidPatternColor),
    }
}

#[rustler::nif]
fn set_solid_pattern_source(image: ImageArc, pattern: SolidPatternArc) -> ImageResult {
    match image.context.set_source(&pattern.pattern) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("solid pattern")),
    }
}

#[rustler::nif]
fn set_solid_pattern_mask(image: ImageArc, pattern: SolidPatternArc) -> ImageResult {
    match image.context.mask(&pattern.pattern) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::MaskError),
    }
}
