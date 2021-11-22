use crate::xairo_image::ImageArc;

#[derive(Copy,Clone,Debug,NifUnitEnum)]
enum LineJoin {
    Default,
    Miter,
    Round,
    Bevel
}

#[rustler::nif]
fn set_line_join(image: ImageArc, line_join: LineJoin) -> ImageArc {
    let line_join = match_line_join(line_join);
    image.context.set_line_join(line_join);
    image
}

fn match_line_join(line_join: LineJoin) -> cairo::LineJoin {
    match line_join {
        LineJoin::Default | LineJoin::Miter => cairo::LineJoin::Miter,
        LineJoin::Round => cairo::LineJoin::Round,
        LineJoin::Bevel => cairo::LineJoin::Bevel
    }
}
