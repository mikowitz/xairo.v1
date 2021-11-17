use crate::shapes::Point;
use crate::color::RGBA;
use crate::xairo_image::{ImageArc, XairoResult};
use cairo::RadialGradient;

#[derive(Debug,NifStruct)]
#[module = "Xairo.Pattern.RadialGradient"]
pub struct XairoRadialGradient {
    pub first_circle: (Point, f64),
    pub second_circle: (Point, f64),
    pub color_stops: Vec<(RGBA, f64)>
}

#[rustler::nif]
fn set_radial_gradient_source(image: ImageArc, gradient: XairoRadialGradient) -> XairoResult {
    let (c1, r1) = gradient.first_circle;
    let (c2, r2) = gradient.second_circle;

    let rg = RadialGradient::new(
        c1.x, c1.y, r1,
        c2.x, c2.y, r2
    );

    for (rgba, position) in gradient.color_stops {
        let (r, g, b, a) = rgba.to_tuple();
        rg.add_color_stop_rgba(position, r, g, b, a);
    }

    if let Ok(_) = image.context.set_source(&rg) {
        Ok(image)
    } else {
        Err(crate::atoms::system::badarg())
    }
}

