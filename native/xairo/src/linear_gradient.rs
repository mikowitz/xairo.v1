use crate::shapes::Point;
use crate::color::Rgba;
use crate::xairo_image::{ImageArc, ImageResult};
use crate::error::Error;

#[derive(Debug,NifStruct)]
#[module = "Xairo.Pattern.LinearGradient"]
pub struct LinearGradient {
    pub start_point: Point,
    pub stop_point: Point,
    pub color_stops: Vec<(Rgba, f64)>
}

#[rustler::nif]
fn set_linear_gradient_source(image: ImageArc, gradient: LinearGradient) -> ImageResult {
    let lg = cairo::LinearGradient::new(
        gradient.start_point.x,
        gradient.start_point.y,
        gradient.stop_point.x,
        gradient.stop_point.y
    );

    for (rgba, position) in gradient.color_stops {
        let (r, g, b, a) = rgba.to_tuple();
        lg.add_color_stop_rgba(position, r, g, b, a);
    }

    match image.context.set_source(&lg) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("linear gradient"))
    }
}
