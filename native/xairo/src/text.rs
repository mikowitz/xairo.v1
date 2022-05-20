use crate::error::Error;
use crate::xairo_image::ImageArc;

#[derive(Copy, Clone, Debug, NifUnitEnum)]
pub enum FontFamily {
    Serif,
    Sans,
    Cursive,
    Fantasy,
    Monospace,
}

#[derive(Copy, Clone, Debug, NifUnitEnum)]
pub enum FontSlant {
    Normal,
    Italic,
    Oblique,
}

#[derive(Copy, Clone, Debug, NifUnitEnum)]
pub enum FontWeight {
    Normal,
    Bold,
}

#[derive(Copy, Clone, Debug, NifStruct)]
#[module = "Xairo.Text.Font"]
pub struct Font {
    pub family: FontFamily,
    pub slant: FontSlant,
    pub weight: FontWeight,
}

#[derive(Debug, NifStruct)]
#[module = "Xairo.Text.Extents"]
pub struct Extents {
    pub text: String,
    pub font_size: f64,
    pub x_bearing: f64,
    pub y_bearing: f64,
    pub width: f64,
    pub height: f64,
    pub x_advance: f64,
    pub y_advance: f64,
}

#[rustler::nif]
fn set_font_size(image: ImageArc, font_size: f64) -> ImageArc {
    image.context.set_font_size(font_size);
    image
}

#[rustler::nif]
fn show_text(image: ImageArc, text: &str) -> ImageArc {
    image.context.show_text(text).unwrap();
    image
}

#[rustler::nif]
fn text_path(image: ImageArc, text: &str) -> ImageArc {
    image.context.text_path(text);
    image
}

#[rustler::nif]
fn text_extents(image: ImageArc, text: &str) -> Result<Extents, Error> {
    if let Ok(extents) = image.context.text_extents(text) {
        Ok(Extents {
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
        Err(Error::TextExtents)
    }
}

#[rustler::nif]
fn set_font_face(image: ImageArc, font: Font) -> ImageArc {
    let family = match_font_family(font.family);
    let slant = match_font_slant(font.slant);
    let weight = match_font_weight(font.weight);

    let font_face = cairo::FontFace::toy_create(family, slant, weight).unwrap();

    image.context.set_font_face(&font_face);
    image
}

fn match_font_slant(slant: FontSlant) -> cairo::FontSlant {
    match slant {
        FontSlant::Normal => cairo::FontSlant::Normal,
        FontSlant::Italic => cairo::FontSlant::Italic,
        FontSlant::Oblique => cairo::FontSlant::Oblique,
    }
}

fn match_font_weight(weight: FontWeight) -> cairo::FontWeight {
    match weight {
        FontWeight::Normal => cairo::FontWeight::Normal,
        FontWeight::Bold => cairo::FontWeight::Bold,
    }
}

fn match_font_family(family: FontFamily) -> &'static str {
    match family {
        FontFamily::Serif => "serif",
        FontFamily::Sans => "sans",
        FontFamily::Cursive => "cursive",
        FontFamily::Fantasy => "fantasy",
        FontFamily::Monospace => "monospace",
    }
}
