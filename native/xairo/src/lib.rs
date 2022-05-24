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
use linear_gradient::XairoLinearGradient;
mod matrix;
mod mesh;
use mesh::XairoMesh;
mod path;
use path::XairoPath;
mod radial_gradient;
use radial_gradient::XairoRadialGradient;
mod shapes;
mod text;
mod transformations;
mod xairo_image;
use xairo_image::XairoImage;

rustler::init!(
    "Elixir.Xairo.Native",
    [
        // xairo image
        xairo_image::new_png_image,
        xairo_image::new_svg_image,
        xairo_image::new_pdf_image,
        xairo_image::new_ps_image,
        xairo_image::save_image,
        xairo_image::set_document_unit,
        xairo_image::mask_surface,
        // extents
        extents::extents,
        // drawing
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
        // color
        color::set_color,
        color::stroke,
        color::fill,
        color::paint,
        // shapes
        shapes::set_dash,
        shapes::set_line_width,
        // line cap
        line_cap::set_line_cap,
        // line join
        line_join::set_line_join,
        // linear gradient
        linear_gradient::set_linear_gradient_source,
        linear_gradient::set_linear_gradient_mask,
        linear_gradient::linear_gradient_new,
        linear_gradient::linear_gradient_add_color_stop,
        linear_gradient::linear_gradient_color_stop_count,
        linear_gradient::linear_gradient_color_stop,
        linear_gradient::linear_gradient_linear_points,
        // radial gradient
        radial_gradient::set_radial_gradient_source,
        radial_gradient::set_radial_gradient_mask,
        radial_gradient::radial_gradient_new,
        radial_gradient::radial_gradient_add_color_stop,
        radial_gradient::radial_gradient_color_stop_count,
        radial_gradient::radial_gradient_color_stop,
        radial_gradient::radial_gradient_radial_circles,
        // mesh
        mesh::set_mesh_source,
        mesh::set_mesh_mask,
        mesh::mesh_new,
        mesh::mesh_begin_patch,
        mesh::mesh_end_patch,
        mesh::mesh_move_to,
        mesh::mesh_line_to,
        mesh::mesh_curve_to,
        mesh::mesh_set_control_point,
        mesh::mesh_set_corner_color,
        mesh::mesh_control_point,
        mesh::mesh_corner_color,
        mesh::mesh_patch_count,
        mesh::mesh_path,
        // text
        text::set_font_size,
        text::show_text,
        text::text_extents,
        text::set_font_face,
        text::text_path,
        // matrix
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
        // transformations
        transformations::translate,
        transformations::rotate,
        transformations::transform,
        transformations::identity_matrix,
        transformations::scale,
        // path
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
    rustler::resource!(XairoMesh, env);
    rustler::resource!(XairoLinearGradient, env);
    rustler::resource!(XairoRadialGradient, env);
    true
}
