use crate::xairo_image::ImageArc;

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


#[rustler::nif]
fn set_font_matrix(image: ImageArc, matrix: Matrix) -> ImageArc {
    let (xx, yy, xy, yx, xt, yt) = matrix.to_tuple();
    let cairo_matrix = cairo::Matrix::new(xx, yx, xy, yy, xt, yt);

    image.context.set_font_matrix(cairo_matrix);
    image
}
