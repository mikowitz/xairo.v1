use crate::error::XairoError;
use crate::image_surface::ImageSurface;
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
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_status(context: Context) -> Result<(), XairoError> {
    match context.context.status() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_set_source_rgb(context: Context, r: f64, g: f64, b: f64) {
    context.context.set_source_rgb(r, g, b);
}

#[rustler::nif]
fn context_set_source_rgba(context: Context, r: f64, g: f64, b: f64, a: f64) {
    context.context.set_source_rgba(r, g, b, a);
}

#[rustler::nif]
fn context_paint(context: Context) -> Result<(), XairoError> {
    match context.context.paint() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_paint_with_alpha(context: Context, alpha: f64) -> Result<(), XairoError> {
    match context.context.paint_with_alpha(alpha) {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_fill(context: Context) -> Result<(), XairoError> {
    match context.context.fill() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_fill_preserve(context: Context) -> Result<(), XairoError> {
    match context.context.fill_preserve() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_stroke(context: Context) -> Result<(), XairoError> {
    match context.context.stroke() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_stroke_preserve(context: Context) -> Result<(), XairoError> {
    match context.context.stroke_preserve() {
        Ok(_) => Ok(()),
        Err(err) => Err(err.into()),
    }
}

#[rustler::nif]
fn context_move_to(context: Context, x: f64, y: f64) {
    context.context.move_to(x, y);
}

#[rustler::nif]
fn context_rel_move_to(context: Context, x: f64, y: f64) {
    context.context.rel_move_to(x, y);
}

#[rustler::nif]
fn context_line_to(context: Context, x: f64, y: f64) {
    context.context.line_to(x, y);
}

#[rustler::nif]
fn context_rel_line_to(context: Context, x: f64, y: f64) {
    context.context.rel_line_to(x, y);
}

#[rustler::nif]
fn context_rectangle(context: Context, x: f64, y: f64, w: f64, h: f64) {
    context.context.rectangle(x, y, w, h);
}

#[rustler::nif]
fn context_close_path(context: Context) {
    context.context.close_path();
}

#[rustler::nif]
fn context_curve_to(context: Context, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) {
    context.context.curve_to(x1, y1, x2, y2, x3, y3);
}

#[rustler::nif]
fn context_rel_curve_to(context: Context, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) {
    context.context.rel_curve_to(x1, y1, x2, y2, x3, y3);
}

#[rustler::nif]
fn context_arc(context: Context, cx: f64, cy: f64, r: f64, a1: f64, a2: f64) {
    context.context.arc(cx, cy, r, a1, a2);
}

#[rustler::nif]
fn context_arc_negative(context: Context, cx: f64, cy: f64, r: f64, a1: f64, a2: f64) {
    context.context.arc_negative(cx, cy, r, a1, a2);
}

#[rustler::nif]
fn context_new_path(context: Context) {
    context.context.new_path();
}

#[rustler::nif]
fn context_new_sub_path(context: Context) {
    context.context.new_sub_path();
}
