defmodule Xairo.Utilities do
  @moduledoc false

  def stride_for_width(format, width) do
    case Xairo.Native.stride_for_width(format, width) do
      {:ok, stride} -> stride
      {:error, _} = error -> error
      error -> {:error, error}
    end
  end
end
