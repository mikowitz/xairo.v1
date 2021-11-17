use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;

use rustler::Atom;
use cairo::LineJoin;
use crate::atoms::system;

rustler::atoms! {
    default,
    miter,
    round,
    bevel
}

#[rustler::nif]
fn set_line_join(image: ImageArc, line_join: Atom) -> XairoResult {
    if let Ok(line_join) = match_line_join(line_join) {
        image.context.set_line_join(line_join);
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

fn match_line_join(line_cap: Atom) -> Result<LineJoin, Atom> {
    if line_cap == default() {
        Ok(LineJoin::Miter)
    } else if line_cap == miter() {
        Ok(LineJoin::Miter)
    } else if line_cap == round() {
        Ok(LineJoin::Round)
    } else if line_cap == bevel() {
        Ok(LineJoin::Bevel)
    } else {
        Err(system::badarg())
    }
}
