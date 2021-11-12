use rustler::Atom;
use cairo::LineCap;
use crate::atoms::system;

rustler::atoms! {
    default,
    butt,
    square,
    round
}

pub fn match_line_cap(line_cap: Atom) -> Result<LineCap, Atom> {
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
