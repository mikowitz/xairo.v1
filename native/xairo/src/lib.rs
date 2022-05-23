#[macro_use]
extern crate rustler_codegen;
use rustler::{Env, Term};

mod color;
mod drawing;
mod error;
mod extents;
mod line_cap;
mod line_join;
mod linear_gradient;
mod matrix;
mod mesh;
mod path;
use path::XairoPath;

mod radial_gradient;
mod shapes;
mod text;
mod transformations;
mod xairo_image;
use xairo_image::XairoImage;

rustler::init!(
    "Elixir.Xairo.Native",
    [
        xairo_image::new_png_image,
        xairo_image::new_svg_image,
        xairo_image::new_pdf_image,
        xairo_image::new_ps_image,
        xairo_image::save_image,
        xairo_image::set_document_unit,
        xairo_image::mask_surface,
        extents::extents,
        drawing::move_to,
        drawing::rel_move_to,
        drawing::line_to,
        drawing::rel_line_to,
        drawing::close_path,
        drawing::arc,
        drawing::arc_negative,
        drawing::rectangle,
        drawing::curve_to,
        drawing::rel_curve_to,
        drawing::new_path,
        drawing::new_sub_path,
        drawing::current_point,
        color::set_color,
        color::stroke,
        color::fill,
        color::paint,
        shapes::set_dash,
        shapes::set_line_width,
        line_cap::set_line_cap,
        line_join::set_line_join,
        linear_gradient::set_linear_gradient_source,
        linear_gradient::set_linear_gradient_mask,
        radial_gradient::set_radial_gradient_source,
        radial_gradient::set_radial_gradient_mask,
        mesh::set_mesh_source,
        mesh::set_mesh_mask,
        text::set_font_size,
        text::show_text,
        text::text_extents,
        text::set_font_face,
        text::text_path,
        matrix::set_font_matrix,
        matrix::set_matrix,
        matrix::get_matrix,
        matrix::user_to_device,
        matrix::user_to_device_distance,
        matrix::device_to_user,
        matrix::device_to_user_distance,
        matrix::matrix_translate,
        matrix::matrix_scale,
        matrix::matrix_rotate,
        matrix::matrix_invert,
        matrix::matrix_multiply,
        matrix::matrix_transform_point,
        matrix::matrix_transform_distance,
        transformations::translate,
        transformations::rotate,
        transformations::transform,
        transformations::identity_matrix,
        transformations::scale,
        path::copy_path,
        path::copy_path_flat,
        path::append_path,
        path::get_tolerance,
        path::set_tolerance
    ],
    load = on_load
);

fn on_load(env: Env, _info: Term) -> bool {
    rustler::resource!(XairoImage, env);
    rustler::resource!(XairoPath, env);
    true
}
