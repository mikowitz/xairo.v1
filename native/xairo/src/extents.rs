use crate::shapes::Point;
use crate::xairo_image::ImageArc;

pub type ExtentTuple = (Point, Point);

#[derive(Copy, Clone, Debug, NifStruct)]
#[module = "Xairo.Extents"]
pub struct Extents {
    pub fill: ExtentTuple,
    pub stroke: ExtentTuple,
    pub path: ExtentTuple,
}

#[rustler::nif]
fn extents(image: ImageArc) -> Result<Extents, ()> {
    let (fx1, fy1, fx2, fy2) = image.context.fill_extents().unwrap();
    let (sx1, sy1, sx2, sy2) = image.context.stroke_extents().unwrap();
    let (px1, py1, px2, py2) = image.context.path_extents().unwrap();

    Ok(Extents {
        fill: (Point { x: fx1, y: fy1 }, Point { x: fx2, y: fy2 }),
        stroke: (Point { x: sx1, y: sy1 }, Point { x: sx2, y: sy2 }),
        path: (Point { x: px1, y: py1 }, Point { x: px2, y: py2 }),
    })
}
