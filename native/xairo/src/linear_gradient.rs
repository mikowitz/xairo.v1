use crate::color::Rgba;
use crate::error::Error;
use crate::shapes::Point;
use crate::xairo_image::{ImageArc, ImageResult};
use rustler::ResourceArc;

pub struct XairoLinearGradient {
    pub gradient: cairo::LinearGradient,
}

unsafe impl Send for XairoLinearGradient {}
unsafe impl Sync for XairoLinearGradient {}

pub type LinearGradientArc = ResourceArc<XairoLinearGradient>;

#[rustler::nif]
fn linear_gradient_new(start_point: Point, stop_point: Point) -> LinearGradientArc {

    ResourceArc::new(XairoLinearGradient{
        gradient: cairo::LinearGradient::new(
            start_point.x,
            start_point.y,
            stop_point.x,
            stop_point.y
        ),
    })
}

#[rustler::nif]
fn linear_gradient_add_color_stop(gradient: LinearGradientArc, offset: f64, color: Rgba) -> LinearGradientArc {
    let (r, g, b, a) = color.to_tuple();
    gradient.gradient.add_color_stop_rgba(offset, r, g, b, a);
    gradient
}

#[rustler::nif]
fn linear_gradient_color_stop_count(gradient: LinearGradientArc) -> Result<isize, Error> {
    match gradient.gradient.color_stop_count() {
        Ok(count) => Ok(count),
        Err(_) => Err(Error::ColorStopCount)
    }
}

#[rustler::nif]
fn linear_gradient_color_stop(gradient: LinearGradientArc, index: isize) -> Result<Rgba, Error> {
    match gradient.gradient.color_stop_rgba(index) {
        Ok((_, red, green, blue, alpha)) => Ok(Rgba { red, green, blue, alpha }),
        Err(_) => Err(Error::ColorStop(index))
    }
}

#[rustler::nif]
fn linear_gradient_linear_points(gradient: LinearGradientArc) -> Result<(Point, Point), Error> {
    match gradient.gradient.linear_points() {
        Ok((x1, y1, x2, y2)) => Ok((Point { x: x1, y: y1 }, Point { x: x2, y: y2 })),
        Err(_) => Err(Error::LinearPoints)
    }
}

#[rustler::nif]
fn set_linear_gradient_source(image: ImageArc, gradient: LinearGradientArc) -> ImageResult {
    match image.context.set_source(&gradient.gradient) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("linear gradient")),
    }
}

#[rustler::nif]
fn set_linear_gradient_mask(image: ImageArc, gradient: LinearGradientArc) -> ImageResult {
    match image.context.mask(&gradient.gradient) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::MaskError),
    }
}

