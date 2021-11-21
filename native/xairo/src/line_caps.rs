use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;

use rustler::Atom;
use cairo::LineCap;
use crate::AtomToString;

rustler::atoms! {
    default,
    butt,
    square,
    round
}

#[rustler::nif]
fn set_line_cap(image: ImageArc, line_cap: Atom) -> XairoResult {
    if let Ok(line_cap) = match_line_cap(line_cap) {
        image.context.set_line_cap(line_cap);
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

fn match_line_cap(line_cap: Atom) -> Result<LineCap, rustler::Error> {
    match &line_cap.to_string()[..] {
        "default" | "butt" => Ok(LineCap::Butt),
        "square" => Ok(LineCap::Square),
        "round" => Ok(LineCap::Round),
        _ => Err(rustler::Error::BadArg)
    }
}

