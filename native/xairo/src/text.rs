use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;
use rustler::Atom;

#[derive(Debug,NifStruct)]
#[module = "Xairo.Text.Extents"]
pub struct TextExtents {
    pub text: String,
    pub font_size: f64,
    pub x_bearing: f64,
    pub y_bearing: f64,
    pub width: f64,
    pub height: f64,
    pub x_advance: f64,
    pub y_advance: f64
}


#[rustler::nif]
fn set_font_size(image: ImageArc, font_size: f64) -> XairoResult {
    image.context.set_font_size(font_size);
    Ok(image)
}

#[rustler::nif]
fn show_text(image: ImageArc, text: &str) -> XairoResult {
    if image.context.show_text(text).is_ok() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn text_extents(image: ImageArc, text: &str) -> Result<TextExtents, Atom> {
    if let Ok(extents) = image.context.text_extents(text) {
        Ok(TextExtents {
            text: text.to_string(),
            // a bit of a hack, since this assumes a non-sheared font matrix
            // but it'll do for now
            font_size: image.context.font_matrix().xx,
            x_bearing: extents.x_bearing,
            y_bearing: extents.y_bearing,
            width: extents.width,
            height: extents.height,
            x_advance: extents.x_advance,
            y_advance: extents.y_advance,
        })
    } else {
        Err(atoms::system::badarg())
    }
}
