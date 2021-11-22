use crate::xairo_image::ImageArc;
use crate::shapes::{Arc, Curve, Point, Rectangle};

#[rustler::nif]
fn move_to(image: ImageArc, point: Point) -> ImageArc {
    image.context.move_to(point.x, point.y);
    image
}

#[rustler::nif]
fn rel_move_to(image: ImageArc, dx: f64, dy: f64) -> ImageArc {
    image.context.rel_move_to(dx, dy);
    image
}

#[rustler::nif]
fn line_to(image: ImageArc, point: Point) -> ImageArc {
    image.context.line_to(point.x, point.y);
    image
}

#[rustler::nif]
fn rel_line_to(image: ImageArc, dx: f64, dy: f64) -> ImageArc {
    image.context.rel_line_to(dx, dy);
    image
}

#[rustler::nif]
fn close_path(image: ImageArc) -> ImageArc {
    image.context.close_path();
    image
}

#[rustler::nif]
fn arc(image: ImageArc, shape: Arc) -> ImageArc {
    image.context.arc(shape.center.x, shape.center.y, shape.radius, shape.start_angle, shape.stop_angle);
    image
}

#[rustler::nif]
fn arc_negative(image: ImageArc, shape: Arc) -> ImageArc {
    image.context.arc_negative(shape.center.x, shape.center.y, shape.radius, shape.start_angle, shape.stop_angle);
    image
}

#[rustler::nif]
fn rectangle(image: ImageArc, rect: Rectangle) -> ImageArc {
    image.context.rectangle(rect.corner.x, rect.corner.y, rect.width, rect.height);
    image
}

#[rustler::nif]
fn curve_to(image: ImageArc, curve: Curve) -> ImageArc {
    image.context.curve_to(
        curve.first_control_point.x, curve.first_control_point.y,
        curve.second_control_point.x, curve.second_control_point.y,
        curve.curve_end.x, curve.curve_end.y
    );

    image
}

#[rustler::nif]
fn rel_curve_to(image: ImageArc, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) -> ImageArc {
    image.context.rel_curve_to(x1, y1, x2, y2, x3, y3);
    image
}

