#[macro_use]
extern crate rustler_codegen;
use rustler::{Atom, Env, Term};

mod xairo_image;
use xairo_image::{ImageArc, XairoImage, XairoResult};
mod point;
use point::Point;

mod rgba;
use rgba::RGBA;

mod dashes;
use dashes::Dashes;

mod shapes;
use shapes::{Arc, Curve, Rectangle};

mod atoms;
mod line_caps;
mod line_joins;

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

#[rustler::nif]
fn set_line_width(image: ImageArc, line_width: f64) -> XairoResult {
    image.context.set_line_width(line_width);
    Ok(image)
}

#[rustler::nif]
fn set_line_cap(image: ImageArc, line_cap: Atom) -> XairoResult {
    if let Ok(line_cap) = line_caps::match_line_cap(line_cap) {
        image.context.set_line_cap(line_cap);
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn set_line_join(image: ImageArc, line_join: Atom) -> XairoResult {
    if let Ok(line_join) = line_joins::match_line_join(line_join) {
        image.context.set_line_join(line_join);
        Ok(image)
    } else {
        Err(atoms::system::badarg())
    }
}

#[rustler::nif]
fn set_dash(image: ImageArc, dashes: Dashes) -> XairoResult {
    image.context.set_dash(&dashes.dashes, dashes.offset);
    Ok(image)
}

#[rustler::nif]
fn rel_move_to(image: ImageArc, dx: f64, dy: f64) -> XairoResult {
    image.context.rel_move_to(dx, dy);
    Ok(image)
}

#[rustler::nif]
fn rel_line_to(image: ImageArc, dx: f64, dy: f64) -> XairoResult {
    image.context.rel_line_to(dx, dy);
    Ok(image)
}

#[rustler::nif]
fn arc(image: ImageArc, shape: Arc) -> XairoResult {
    image.context.arc(shape.center.x, shape.center.y, shape.radius, shape.start_angle, shape.stop_angle);
    Ok(image)
}

#[rustler::nif]
fn arc_negative(image: ImageArc, shape: Arc) -> XairoResult {
    image.context.arc_negative(shape.center.x, shape.center.y, shape.radius, shape.start_angle, shape.stop_angle);
    Ok(image)
}

#[rustler::nif]
fn curve_to(image: ImageArc, curve: Curve) -> XairoResult {
    image.context.curve_to(
        curve.first_control_point.x, curve.first_control_point.y,
        curve.second_control_point.x, curve.second_control_point.y,
        curve.curve_end.x, curve.curve_end.y
    );

    Ok(image)
}

#[rustler::nif]
fn rel_curve_to(image: ImageArc, x1: f64, y1: f64, x2: f64, y2: f64, x3: f64, y3: f64) -> XairoResult {
    image.context.rel_curve_to(x1, y1, x2, y2, x3, y3);
    Ok(image)
}

#[rustler::nif]
fn rectangle(image: ImageArc, rect: Rectangle) -> XairoResult {
    image.context.rectangle(rect.corner.x, rect.corner.y, rect.width, rect.height);
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
        set_line_width,
        set_line_cap,
        set_line_join,
        set_dash,
        rel_move_to,
        rel_line_to,
        arc,
        arc_negative,
        rectangle,

        curve_to,
        rel_curve_to,
    ],
    load=on_load
);

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(XairoImage, env);
    true
}
