defmodule Xairo.Native do
  @moduledoc false

  use Rustler, otp_app: :xairo, crate: "xairo"

  def new_png_image(_w, _h), do: error()
  def new_pdf_image(_w, _h, _f), do: error()
  def new_ps_image(_w, _h, _f), do: error()
  def new_svg_image(_f, _w, _h), do: error()

  def set_document_unit(_i, _u), do: error()

  def save_image(_i, _f), do: error()

  def set_radial_gradient_mask(_i, _g), do: error()
  def set_linear_gradient_mask(_i, _g), do: error()
  def set_mesh_mask(_i, _m), do: error()
  def mask_surface(_i, _m, _p), do: error()

  def move_to(_i, _p), do: error()
  def line_to(_i, _p), do: error()
  def stroke(_i), do: error()
  def set_color(_i, _c), do: error()
  def paint(_i), do: error()
  def fill(_i), do: error()
  def close_path(_i), do: error()

  def new_path(_i), do: error()
  def new_sub_path(_i), do: error()

  def current_point(_i), do: error()

  def set_line_width(_i, _w), do: error()
  def set_line_cap(_i, _lc), do: error()
  def set_line_join(_i, _lj), do: error()
  def set_dash(_i, _d), do: error()

  def rel_line_to(_i, _v), do: error()
  def rel_move_to(_i, _v), do: error()

  def arc(_i, _a), do: error()
  def arc_negative(_, _a), do: error()

  def curve_to(_i, _c), do: error()
  def rel_curve_to(_i, _c), do: error()

  def rectangle(_i, _r), do: error()

  def set_linear_gradient_source(_i, _lg), do: error()
  def set_radial_gradient_source(_i, _rg), do: error()
  def set_mesh_source(_i, _m), do: error()

  def set_font_size(_i, _s), do: error()
  def show_text(_i, _str), do: error()
  def text_path(_i, _str), do: error()

  def text_extents(_i, _str), do: error()
  def extents(_i), do: error()

  def set_font_face(_i, _f), do: error()
  def set_font_matrix(_i, _m), do: error()

  def scale(_i, _sx, _sy), do: error()
  def translate(_i, _dx, _dy), do: error()
  def rotate(_i, _r), do: error()
  def transform(_i, _m), do: error()
  def identity_matrix(_i), do: error()

  def set_matrix(_i, _m), do: error()
  def get_matrix(_i), do: error()
  def user_to_device(_i, _p), do: error()
  def user_to_device_distance(_i, _v), do: error()
  def device_to_user(_i, _p), do: error()
  def device_to_user_distance(_i, _v), do: error()

  def matrix_translate(_m, _xt, _yt), do: error()
  def matrix_scale(_m, _xx, _yy), do: error()
  def matrix_rotate(_m, _r), do: error()
  def matrix_invert(_m), do: error()
  def matrix_multiply(_m1, _m2), do: error()

  def matrix_transform_point(_m, _p), do: error()
  def matrix_transform_distance(_m, _v), do: error()

  def copy_path(_i), do: error()
  def copy_path_flat(_i), do: error()
  def append_path(_i, _p), do: error()
  def get_tolerance(_i), do: error()
  def set_tolerance(_i, _t), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
