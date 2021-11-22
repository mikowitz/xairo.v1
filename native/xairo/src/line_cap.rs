use crate::xairo_image::ImageArc;

#[derive(Copy,Clone,Debug,NifUnitEnum)]
enum LineCap {
    Default,
    Butt,
    Square,
    Round
}

#[rustler::nif]
fn set_line_cap(image: ImageArc, line_cap: LineCap) -> ImageArc {
    let line_cap = match_line_cap(line_cap);
    image.context.set_line_cap(line_cap);
    image
}

fn match_line_cap(line_cap: LineCap) -> cairo::LineCap {
    match line_cap {
        LineCap::Default | LineCap::Butt => cairo::LineCap::Butt,
        LineCap::Square => cairo::LineCap::Square,
        LineCap::Round => cairo::LineCap::Round
    }
}

