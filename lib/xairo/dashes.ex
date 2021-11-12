defmodule Xairo.Dashes do
  @moduledoc """
  Models a dash configuration for drawing lines.

  The `dashes` field is a list of "on" and "off" lengths that cycles through the length of the line. `offset` defines how much empty space there is before the pattern starts.
  """

  defstruct [:dashes, :offset]

  def new(dashes \\ [], offset \\ 0.0) do
    with [_ | _] = dashes <- normalize(dashes) do
      %__MODULE__{
        dashes: dashes,
        offset: offset * 1.0
      }
    end
  end

  defp normalize([]), do: []

  defp normalize([d | _rest]) when d < 0.0 do
    {:error, :invalid_dash}
  end

  defp normalize([d | rest]) do
    [d * 1.0 | normalize(rest)]
  end
end
