defmodule Xairo.Native do
  use Rustler, otp_app: :xairo, crate: "xairo"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
