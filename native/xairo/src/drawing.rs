use crate::xairo_image::ImageArc;
use crate::shapes::{Arc, Curve, Point, Rectangle, Vector};

#[rustler::nif]
fn move_to(image: ImageArc, point: Point) -> ImageArc {
    image.context.move_to(point.x, point.y);
    image
}

#[rustler::nif]
fn rel_move_to(image: ImageArc, vector: Vector) -> ImageArc {
    image.context.rel_move_to(vector.x, vector.y);
    image
}

#[rustler::nif]
fn line_to(image: ImageArc, point: Point) -> ImageArc {
    image.context.line_to(point.x, point.y);
    image
}

#[rustler::nif]
fn rel_line_to(image: ImageArc, vector: Vector) -> ImageArc {
    image.context.rel_line_to(vector.x, vector.y);
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
    let ((x1, y1), (x2, y2), (x3, y3)) = curve.to_tuple();
    image.context.curve_to(x1, y1, x2, y2, x3, y3);
    image
}

#[rustler::nif]
fn rel_curve_to(image: ImageArc, curve: Curve) -> ImageArc {
    let ((x1, y1), (x2, y2), (x3, y3)) = curve.to_tuple();
    image.context.rel_curve_to(x1, y1, x2, y2, x3, y3);
    image
}
