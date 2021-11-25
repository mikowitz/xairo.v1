use rustler::{Term, Env};
use thiserror::Error as ThisErrorError;

#[derive(Debug,ThisErrorError)]
pub enum Error {
    #[error("Error creating image context")]
    ContextCreate,
    #[error("Error creating image surface")]
    SurfaceCreate,
    #[error("Error creating file at {0}")]
    FileCreate(String),
    #[error("Error writing file at {0}")]
    FileWrite(String),
    #[error("Error rendering path with {0}")]
    PathRender(&'static str),
    #[error("Error setting {0} as source")]
    SetSource(&'static str),
    #[error("Error fetching text extents")]
    TextExtents,
    #[error("Error fetching translated distance vector")]
    TranslatedVector,
    #[error("Error fetching translated point")]
    TranslatedPoint,
}

impl rustler::Encoder for Error {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        format!("{}", self).encode(env)
    }
}
