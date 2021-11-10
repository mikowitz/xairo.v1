#[macro_use]
extern crate rustler_codegen;
use rustler::{Env, Term};

mod xairo_image;
use xairo_image::{ImageArc, XairoImage, XairoResult};
mod point;
use point::Point;

mod atoms;

#[rustler::nif]
fn move_to(image: ImageArc, point: Point) -> XairoResult {
    image.context.move_to(point.x, point.y);
    Ok(image)
}

#[rustler::nif]
fn line_to(image: ImageArc, point: Point) -> XairoResult {
    image.context.line_to(point.x, point.y);
    Ok(image)
}

#[rustler::nif]
fn stroke(image: ImageArc) -> XairoResult {
    if let Ok(_) = image.context.stroke() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

rustler::init!(
    "Elixir.Xairo.Native",
    [
        xairo_image::new_image,
        xairo_image::save_image,
        xairo_image::scale,

        move_to,
        line_to,
        stroke,
    ],
    load=on_load
);

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(XairoImage, env);
    true
}
