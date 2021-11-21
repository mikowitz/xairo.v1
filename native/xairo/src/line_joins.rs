use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;

use rustler::Atom;
use cairo::LineJoin;
use crate::AtomToString;

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

fn match_line_join(line_join: Atom) -> Result<LineJoin, rustler::Error> {
    let line_join = &line_join.to_string()[..];
    match &line_join.to_string()[..] {
        "default" | "miter" => Ok(LineJoin::Miter),
        "round" => Ok(LineJoin::Round),
        "bevel" => Ok(LineJoin::Bevel),
        _ => Err(rustler::Error::BadArg)
    }
}
