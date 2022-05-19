use crate::color::Rgba;
use crate::error::Error;
use crate::shapes::Point;
use crate::xairo_image::{ImageArc, ImageResult};

#[derive(Debug, NifStruct)]
#[module = "Xairo.Pattern.LinearGradient"]
pub struct LinearGradient {
    pub start_point: Point,
    pub stop_point: Point,
    pub color_stops: Vec<(Rgba, f64)>,
}

#[rustler::nif]
fn set_linear_gradient_source(image: ImageArc, gradient: LinearGradient) -> ImageResult {
    let lg = into_cairo_linear_gradient(gradient);

    match image.context.set_source(&lg) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("linear gradient")),
    }
}

#[rustler::nif]
fn set_linear_gradient_mask(image: ImageArc, gradient: LinearGradient) -> ImageResult {
    let mask_pattern = into_cairo_linear_gradient(gradient);
    match image.context.mask(&mask_pattern) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::MaskError),
    }
}

fn into_cairo_linear_gradient(gradient: LinearGradient) -> cairo::LinearGradient {
    let lg = cairo::LinearGradient::new(
        gradient.start_point.x,
        gradient.start_point.y,
        gradient.stop_point.x,
        gradient.stop_point.y,
    );

    for (rgba, position) in gradient.color_stops {
        let (r, g, b, a) = rgba.to_tuple();
        lg.add_color_stop_rgba(position, r, g, b, a);
    }

    lg
}
