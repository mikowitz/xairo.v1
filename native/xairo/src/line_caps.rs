use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;

use rustler::Atom;
use cairo::LineCap;
use crate::atoms::system;

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

fn match_line_cap(line_cap: Atom) -> Result<LineCap, Atom> {
    if line_cap == default() {
        Ok(LineCap::Butt)
    } else if line_cap == butt() {
        Ok(LineCap::Butt)
    } else if line_cap == square() {
        Ok(LineCap::Square)
    } else if line_cap == round() {
        Ok(LineCap::Round)
    } else {
        Err(system::badarg())
    }
}

