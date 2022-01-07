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
}

impl From<Matrix> for cairo::Matrix {
    fn from(matrix: Matrix) -> Self {
        let (xx, yy, xy, yx, xt, yt) = matrix.to_tuple();
        cairo::Matrix::new(xx, yx, xy, yy, xt, yt)
    }
}

impl From<cairo::Matrix> for Matrix {
    fn from(matrix: cairo::Matrix) -> Self {
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
    let matrix = cairo::Matrix::from(matrix);
    image.context.set_font_matrix(matrix);
    image
}

#[rustler::nif]
fn set_matrix(image: ImageArc, matrix: Matrix) -> ImageArc {
    let matrix = cairo::Matrix::from(matrix);
    image.context.set_matrix(matrix);
    image
}

#[rustler::nif]
fn get_matrix(image: ImageArc) -> Matrix {
    let matrix: cairo::Matrix = image.context.matrix();
    matrix.into()
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

#[rustler::nif]
fn matrix_translate(matrix: Matrix, xt: f64, yt: f64) -> Matrix {
    let mut matrix = cairo::Matrix::from(matrix);
    matrix.translate(xt, yt);
    matrix.into()
}

#[rustler::nif]
fn matrix_scale(matrix: Matrix, xx: f64, yy: f64) -> Matrix {
    let mut matrix = cairo::Matrix::from(matrix);
    matrix.scale(xx, yy);
    matrix.into()
}

#[rustler::nif]
fn matrix_rotate(matrix: Matrix, radians: f64) -> Matrix {
    let mut matrix = cairo::Matrix::from(matrix);
    matrix.rotate(radians);
    matrix.into()
}

#[rustler::nif]
fn matrix_invert(matrix: Matrix) -> Result<Matrix, Error> {
    let matrix = cairo::Matrix::from(matrix);
    match matrix.try_invert() {
        Ok(matrix) => Ok(matrix.into()),
        _ => Err(Error::UninvertibleMatrix)
    }
}

#[rustler::nif]
fn matrix_multiply(matrix1: Matrix, matrix2: Matrix) -> Matrix {
    let matrix1 = cairo::Matrix::from(matrix1);
    let matrix2 = cairo::Matrix::from(matrix2);
    let matrix3 = cairo::Matrix::multiply(&matrix1, &matrix2);
    matrix3.into()
}

#[rustler::nif]
fn matrix_transform_point(matrix: Matrix, point: Point) -> Point {
    let matrix = cairo::Matrix::from(matrix);
    let (x, y) = matrix.transform_point(point.x, point.y);
    Point { x, y }
}

#[rustler::nif]
fn matrix_transform_distance(matrix: Matrix, vector: Vector) -> Vector {
    let matrix = cairo::Matrix::from(matrix);
    let (x, y) = matrix.transform_distance(vector.x, vector.y);
    Vector { x, y }
}
