use crate::image_surface::ImageSurface;
use crate::error::XairoError;
use rustler::ResourceArc;

pub struct ContextRaw {
    pub context: cairo::Context,
}

unsafe impl Send for ContextRaw {}
unsafe impl Sync for ContextRaw {}

pub type Context = ResourceArc<ContextRaw>;

#[rustler::nif]
fn context_new_from_image_surface(surface: ImageSurface) -> Result<Context, XairoError> {
    match cairo::Context::new(&surface.surface) {
        Ok(context) => Ok(ResourceArc::new(ContextRaw { context })),
        Err(err) => Err(err.into())
    }
}

#[rustler::nif]
fn context_status(context: Context) -> Result<(), XairoError> {
    match context.context.status() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into())
    }
}

#[rustler::nif]
fn context_set_source_rgb(context: Context, r: f64, g: f64, b: f64) {
    context.context.set_source_rgb(r, g, b);
}

#[rustler::nif]
fn context_paint(context: Context) -> Result<(), XairoError> {
    match context.context.paint() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into())
    }
}

#[rustler::nif]
fn context_fill(context: Context) -> Result<(), XairoError> {
    match context.context.fill() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into())
    }
}

#[rustler::nif]
fn context_stroke(context: Context) -> Result<(), XairoError> {
    match context.context.stroke() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into())
    }
}

#[rustler::nif]
fn context_move_to(context: Context, x: f64, y: f64) {
    context.context.move_to(x, y);
}

#[rustler::nif]
fn context_line_to(context: Context, x: f64, y: f64) {
    context.context.line_to(x, y);
}

#[rustler::nif]
fn context_close_path(context: Context) {
    context.context.close_path();
}
