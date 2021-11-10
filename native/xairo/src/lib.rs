#[macro_use]
extern crate rustler_codegen;
use rustler::{Env, Term};

mod xairo_image;
use xairo_image::{ImageArc, XairoImage, XairoResult};
mod point;
use point::Point;

mod rgba;
use rgba::RGBA;

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
fn close_path(image: ImageArc) -> XairoResult {
    image.context.close_path();
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

#[rustler::nif]
fn fill(image: ImageArc) -> XairoResult {
    if let Ok(_) = image.context.fill() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn paint(image: ImageArc) -> XairoResult {
    if let Ok(_) = image.context.paint() {
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn set_color(image: ImageArc, rgba: RGBA) -> XairoResult {
    let (r, g, b, a) = rgba.to_tuple();
    if a == 1.0 {
        image.context.set_source_rgb(r, g, b);
    } else {
        image.context.set_source_rgba(r, g, b, a);
    }
    Ok(image)
}

rustler::init!(
    "Elixir.Xairo.Native",
    [
        xairo_image::new_image,
        xairo_image::save_image,
        xairo_image::scale,

        set_color,
        move_to,
        line_to,
        stroke,
        fill,
        paint,
        close_path,
    ],
    load=on_load
);

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(XairoImage, env);
    true
}
