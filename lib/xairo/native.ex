defmodule Xairo.Native do
  @moduledoc false

  use Rustler, otp_app: :xairo, crate: "xairo"

  def new_image(_w, _h), do: error()
  def save_image(_i, _f), do: error()
  def scale(_i, _sx, _sy), do: error()

  def move_to(_i, _p), do: error()
  def line_to(_i, _p), do: error()
  def stroke(_i), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
