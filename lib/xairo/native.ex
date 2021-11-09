defmodule Xairo.Native do
  use Rustler, otp_app: :xairo, crate: "xairo"

  def new_image(_w, _h), do: error()
  def save_image(_i, _f), do: error()

  defp error, do: :erlang.nif_error(:nif_not_loaded)
end
