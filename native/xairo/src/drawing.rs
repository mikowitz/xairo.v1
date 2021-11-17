use crate::xairo_image::{ImageArc, XairoResult};
use crate::shapes::{Arc, Curve, Point, Rectangle};

#[rustler::nif]
fn move_to(image: ImageArc, point: Point) -> XairoResult {
    image.context.move_to(point.x, point.y);
    Ok(image)
}

#[rustler::nif]
fn rel_move_to(image: ImageArc, dx: f64, dy: f64) -> XairoResult {
    image.context.rel_move_to(dx, dy);
    Ok(image)
}

#[rustler::nif]
fn line_to(image: ImageArc, point: Point) -> XairoResult {
    image.context.line_to(point.x, point.y);
    Ok(image)
}

#[rustler::nif]
fn rel_line_to(image: ImageArc, dx: f64, dy: f64) -> XairoResult {
    image.context.rel_line_to(dx, dy);
    Ok(image)
}

#[rustler::nif]
fn close_path(image: ImageArc) -> XairoResult {
    image.context.close_path();
    Ok(image)
}

#[rustler::nif]
fn arc(image: ImageArc, shape: Arc) -> XairoResult {
    image.context.arc(shape.center.x, shape.center.y, shape.radius, shape.start_angle, shape.stop_angle);
    Ok(image)
}

#[rustler::nif]
fn arc_negative(image: ImageArc, shape: Arc) -> XairoResult {
    image.context.arc_negative(shape.center.x, shape.center.y, shape.radius, shape.start_angle, shape.stop_angle);
    Ok(image)
}

#[rustler::nif]
fn rectangle(image: ImageArc, rect: Rectangle) -> XairoResult {
    image.context.rectangle(rect.corner.x, rect.corner.y, rect.width, rect.height);
    Ok(image)
}

#[rustler::nif]
fn curve_to(image: ImageArc, curve: Curve) -> XairoResult {
    image.context.curve_to(
        curve.first_control_point.x, curve.first_control_point.y,
        curve.second_control_point.x, curve.second_control_point.y,
        curve.curve_end.x, curve.curve_end.y
    );

    Ok(image)
}

#[rustler::nif]
fn rel_curve_to(image: ImageArc, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) -> XairoResult {
    image.context.rel_curve_to(x1, y1, x2, y2, x3, y3);
    Ok(image)
}

