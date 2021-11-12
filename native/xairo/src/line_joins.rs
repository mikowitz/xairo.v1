use rustler::Atom;
use cairo::LineJoin;
use crate::atoms::system;

rustler::atoms! {
    default,
    miter,
    round,
    bevel
}

pub fn match_line_join(line_cap: Atom) -> Result<LineJoin, Atom> {
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
