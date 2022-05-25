use rustler::{Env, Term};
use thiserror::Error as ThisErrorError;

#[derive(Debug, ThisErrorError)]
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
    #[error("Mismatched file type")]
    FileTypeMismatch,
    #[error("Uninvertible matrix")]
    UninvertibleMatrix,
    #[error("Could not copy path")]
    CopyPath,
    #[error("Could not set surface as source")]
    SurfaceSource,
    #[error("Could not apply pattern as mask")]
    MaskError,
    #[error("No control point set for corner {0} of patch {1}")]
    ControlPointError(usize, usize),
    #[error("No color set for corner {0} of patch {1}")]
    CornerColorError(usize, usize),
    #[error("Unable to retrieve patch count for mesh")]
    PatchCount,
    #[error("No patch found at index {0}")]
    MeshPath(usize),
    #[error("Unable to retrieve color stop count for gradient")]
    ColorStopCount,
    #[error("No color stop found at index {0}")]
    ColorStop(isize),
    #[error("Error retrieving linear points for gradient")]
    LinearPoints,
    #[error("Error retrieving radial circles for gradient")]
    RadialCircles,
    #[error("Error retrieving color for solid pattern")]
    SolidPatternColor,
}

impl rustler::Encoder for Error {
    fn encode<'a>(&self, env: Env<'a>) -> Term<'a> {
        format!("{}", self).encode(env)
    }
}
