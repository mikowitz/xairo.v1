use crate::xairo_image::ImageArc;
use crate::shapes::{Point, Vector};
use crate::error::Error;

#[derive(Copy,Clone,Debug,NifStruct)]
#[module = "Xairo.Matrix"]
pub struct Matrix {
    pub xx: f64,
    pub yy: f64,
    pub xy: f64,
    pub yx: f64,
    pub xt: f64,
    pub yt: f64,
}

impl Matrix {
    pub fn to_tuple(self) -> (f64, f64, f64, f64, f64, f64) {
        (self.xx, self.yy, self.xy, self.yx, self.xt, self.yt)
    }

    pub fn to_cairo_matrix(self) -> cairo::Matrix {
        let (xx, yy, xy, yx, xt, yt) = self.to_tuple();
        cairo::Matrix::new(xx, yx, xy, yy, xt, yt)
    }

    pub fn from_cairo_matrix(matrix: cairo::Matrix) -> Self {
        Self {
            xx: matrix.xx,
            yy: matrix.yy,
            xy: matrix.xy,
            yx: matrix.yx,
            xt: matrix.x0,
            yt: matrix.y0
        }
    }
}


#[rustler::nif]
fn set_font_matrix(image: ImageArc, matrix: Matrix) -> ImageArc {
    let matrix = matrix.to_cairo_matrix();
    image.context.set_font_matrix(matrix);
    image
}

#[rustler::nif]
fn set_matrix(image: ImageArc, matrix: Matrix) -> ImageArc {
    let matrix = matrix.to_cairo_matrix();
    image.context.set_matrix(matrix);
    image
}

#[rustler::nif]
fn get_matrix(image: ImageArc) -> Matrix {
    let matrix: cairo::Matrix = image.context.matrix();
    Matrix::from_cairo_matrix(matrix)
}

#[rustler::nif]
fn user_to_device(image: ImageArc, point: Point) -> Point {
    let (x, y) = image.context.user_to_device(point.x, point.y);
    Point { x, y }
}

#[rustler::nif]
fn user_to_device_distance(image: ImageArc, vector: Vector) -> Result<Vector, Error> {
    match image.context.user_to_device_distance(vector.x, vector.y) {
        Ok((x, y)) => Ok(Vector{ x, y }),
        Err(_) => Err(Error::TranslatedVector)
    }
}

#[rustler::nif]
fn device_to_user(image: ImageArc, point: Point) -> Result<Point, Error> {
    match image.context.device_to_user(point.x, point.y) {
        Ok((x, y)) => Ok(Point{ x, y }),
        Err(_) => Err(Error::TranslatedPoint)
    }
}

#[rustler::nif]
fn device_to_user_distance(image: ImageArc, vector: Vector) -> Result<Vector, Error> {
    match image.context.device_to_user_distance(vector.x, vector.y) {
        Ok((x, y)) => Ok(Vector{ x, y }),
        Err(_) => Err(Error::TranslatedVector)
    }
}
