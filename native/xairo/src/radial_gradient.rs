use crate::color::Rgba;
use crate::error::Error;
use crate::shapes::Point;
use crate::xairo_image::{ImageArc, ImageResult};
use rustler::ResourceArc;

pub struct XairoRadialGradient {
    pub gradient: cairo::RadialGradient,
}

unsafe impl Send for XairoRadialGradient {}
unsafe impl Sync for XairoRadialGradient {}

pub type RadialGradientArc = ResourceArc<XairoRadialGradient>;

#[rustler::nif]
fn radial_gradient_new(
    point1: Point,
    radius1: f64,
    point2: Point,
    radius2: f64,
) -> RadialGradientArc {
    ResourceArc::new(XairoRadialGradient {
        gradient: cairo::RadialGradient::new(
            point1.x, point1.y, radius1, point2.x, point2.y, radius2,
        ),
    })
}

#[rustler::nif]
fn radial_gradient_add_color_stop(
    gradient: RadialGradientArc,
    offset: f64,
    color: Rgba,
) -> RadialGradientArc {
    let (r, g, b, a) = color.to_tuple();
    gradient.gradient.add_color_stop_rgba(offset, r, g, b, a);
    gradient
}

#[rustler::nif]
fn radial_gradient_color_stop_count(gradient: RadialGradientArc) -> Result<isize, Error> {
    match gradient.gradient.color_stop_count() {
        Ok(count) => Ok(count),
        Err(_) => Err(Error::ColorStopCount),
    }
}

#[rustler::nif]
fn radial_gradient_color_stop(gradient: RadialGradientArc, index: isize) -> Result<Rgba, Error> {
    match gradient.gradient.color_stop_rgba(index) {
        Ok((_, red, green, blue, alpha)) => Ok(Rgba {
            red,
            green,
            blue,
            alpha,
        }),
        Err(_) => Err(Error::ColorStop(index)),
    }
}

#[rustler::nif]
fn radial_gradient_radial_circles(
    gradient: RadialGradientArc,
) -> Result<((Point, f64), (Point, f64)), Error> {
    match gradient.gradient.radial_circles() {
        Ok((x1, y1, r1, x2, y2, r2)) => {
            let p1 = Point { x: x1, y: y1 };
            let p2 = Point { x: x2, y: y2 };
            Ok(((p1, r1), (p2, r2)))
        }
        Err(_) => Err(Error::RadialCircles),
    }
}

#[rustler::nif]
fn set_radial_gradient_source(image: ImageArc, gradient: RadialGradientArc) -> ImageResult {
    match image.context.set_source(&gradient.gradient) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::SetSource("radial gradient")),
    }
}

#[rustler::nif]
fn set_radial_gradient_mask(image: ImageArc, gradient: RadialGradientArc) -> ImageResult {
    match image.context.mask(&gradient.gradient) {
        Ok(_) => Ok(image),
        Err(_) => Err(Error::MaskError),
    }
}
