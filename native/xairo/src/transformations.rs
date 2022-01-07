use crate::xairo_image::ImageArc;
// use crate::shapes::{Arc, Curve, Point, Rectangle};
use crate::matrix::Matrix;

#[rustler::nif]
fn translate(image: ImageArc, dx: f64, dy: f64) -> ImageArc {
    image.context.translate(dx, dy);
    image
}

#[rustler::nif]
fn rotate(image: ImageArc, rad: f64) -> ImageArc {
    image.context.rotate(rad);
    image
}

#[rustler::nif]
fn transform(image: ImageArc, matrix: Matrix) -> ImageArc {
    let matrix = cairo::Matrix::from(matrix);
    image.context.transform(matrix);
    image
}

#[rustler::nif]
fn identity_matrix(image: ImageArc) -> ImageArc {
    image.context.identity_matrix();
    image
}

#[rustler::nif]
pub fn scale(image: ImageArc, sx: f64, sy: f64) -> ImageArc {
    image.context.scale(sx, sy);
    image
}
