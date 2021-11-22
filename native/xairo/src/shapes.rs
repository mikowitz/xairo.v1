use crate::xairo_image::ImageArc;

#[derive(Copy,Clone,Debug,NifStruct)]
#[module = "Xairo.Point"]
pub struct Point {
    pub x: f64,
    pub y: f64
}

#[derive(Copy,Clone,Debug,NifStruct)]
#[module = "Xairo.Arc"]
pub struct Arc {
    pub center: Point,
    pub radius: f64,
    pub start_angle: f64,
    pub stop_angle: f64
}

#[derive(Copy,Clone,Debug,NifStruct)]
#[module = "Xairo.Curve"]
pub struct Curve {
    pub first_control_point: Point,
    pub second_control_point: Point,
    pub curve_end: Point,
}

#[derive(Copy,Clone,Debug,NifStruct)]
#[module = "Xairo.Rectangle"]
pub struct Rectangle {
    pub corner: Point,
    pub width: f64,
    pub height: f64
}

#[derive(NifStruct)]
#[module = "Xairo.Dashes"]
pub struct Dashes {
    pub dashes: Vec<f64>,
    pub offset: f64,
}

#[rustler::nif]
fn set_dash(image: ImageArc, dashes: Dashes) -> ImageArc {
    image.context.set_dash(&dashes.dashes, dashes.offset);
    image
}

#[rustler::nif]
fn set_line_width(image: ImageArc, line_width: f64) -> ImageArc {
    image.context.set_line_width(line_width);
    image
}

