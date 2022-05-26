use crate::error::XairoError;
use std::convert::From;

#[derive(Copy, Clone, Debug, NifUnitEnum)]
pub enum Format {
    Invalid,
    Argb32,
    Rgb24,
    A8,
    A1,
    Rgb16_565,
    Rgb30,
}

impl Format {
    fn stride_for_width(self, width: u32) -> Result<i32, XairoError> {
        match cairo::Format::from(self).stride_for_width(width) {
            Ok(stride) => Ok(stride),
            Err(err) => Err(err.into()), //Err(Error::Stride),
        }
    }
}

#[rustler::nif]
fn stride_for_width(format: Format, width: u32) -> Result<i32, XairoError> {
    if width <= i32::MAX as u32 {
        format.stride_for_width(width)
    } else {
        Err(XairoError::InvalidStride)
    }
}

impl From<Format> for cairo::Format {
    fn from(format: Format) -> Self {
        match format {
            Format::Invalid => cairo::Format::Invalid,
            Format::Argb32 => cairo::Format::ARgb32,
            Format::Rgb24 => cairo::Format::Rgb24,
            Format::A8 => cairo::Format::A8,
            Format::A1 => cairo::Format::A1,
            Format::Rgb16_565 => cairo::Format::Rgb16_565,
            Format::Rgb30 => cairo::Format::Rgb30,
        }
    }
}

impl From<cairo::Format> for Format {
    fn from(format: cairo::Format) -> Self {
        match format {
            cairo::Format::ARgb32 => Format::Argb32,
            cairo::Format::Rgb24 => Format::Rgb24,
            cairo::Format::A8 => Format::A8,
            cairo::Format::A1 => Format::A1,
            cairo::Format::Rgb16_565 => Format::Rgb16_565,
            cairo::Format::Rgb30 => Format::Rgb30,
            _ => Format::Invalid,
        }
    }
}
