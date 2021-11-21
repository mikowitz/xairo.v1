use crate::xairo_image::{ImageArc, XairoResult};
use crate::atoms;
use rustler::Atom;
use crate::AtomToString;
use cairo::{FontSlant, FontWeight};

rustler::atoms! {
    serif, sans, cursive, fantasy, monospace,
    normal, italic, oblique,
    bold
}

#[derive(Debug,NifStruct)]
#[module="Xairo.Text.Font"]
pub struct Font {
    pub family: Atom,
    pub slant: Atom,
    pub weight: Atom,
}

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
            font_size: image.context.font_matrix().yy,
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

#[rustler::nif]
fn set_font_face(image: ImageArc, font: Font) -> XairoResult {
    let family = match_font_family(font.family).unwrap();
    let slant = match_font_slant(font.slant).unwrap();
    let weight = match_font_weight(font.weight).unwrap();

    let font_face = cairo::FontFace::toy_create(&family, slant, weight);

    if let Ok(font_face) = font_face {
        image.context.set_font_face(&font_face);
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

fn match_font_slant(slant: Atom) -> Result<FontSlant, rustler::Error> {
    match &slant.to_string()[..] {
        "normal" => Ok(FontSlant::Normal),
        "italic" => Ok(FontSlant::Italic),
        "oblique" => Ok(FontSlant::Oblique),
        _ => Err(rustler::Error::BadArg)
    }
}

fn match_font_weight(weight: Atom) -> Result<FontWeight, rustler::Error> {
    match &weight.to_string()[..] {
        "normal" => Ok(FontWeight::Normal),
        "bold" => Ok(FontWeight::Bold),
        _ => Err(rustler::Error::BadArg)
    }
}

fn match_font_family(family: Atom) -> Result<String, rustler::Error> {
    match &family.to_string()[..] {
        "serif" | "sans" | "cursive" | "fantasy" | "monospace" => Ok(family.to_string()),
        _ => Err(rustler::Error::BadArg)
    }
}
