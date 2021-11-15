use crate::point::Point;

#[derive(NifStruct)]
#[module = "Xairo.Arc"]
pub struct Arc {
    pub center: Point,
    pub radius: f64,
    pub start_angle: f64,
    pub stop_angle: f64
}

#[derive(NifStruct)]
#[module = "Xairo.Curve"]
pub struct Curve {
    pub first_control_point: Point,
    pub second_control_point: Point,
    pub curve_end: Point,
}

#[derive(NifStruct)]
#[module = "Xairo.Rectangle"]
pub struct Rectangle {
    pub corner: Point,
    pub width: f64,
    pub height: f64
}
