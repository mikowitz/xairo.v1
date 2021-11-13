defmodule Xairo.Dashes do
  @moduledoc """
  Models a dash configuration for drawing lines.

  The `dashes` field is a list of "on" and "off" lengths that cycles through
  the length of the line. `offset` defines how many pixels into the pattern the
  rendered line begins.

  If an empty list of lengths is passed as the first argument to `new/2`, a
  solid line will be the result.

  If a single number is passed in the list of lengths, the pattern will be an
  alternating on/off pattern of that number.

  ## Examples

  The following `Dashes` struct

      iex> Dashes.new([1,2,3], 0)

  would result in a pattern of 1 on, 2 off, 3 on, 1 off, 2 on, 3 off, repeating.

  Using `-` and on and `.` as off, this would result in the following repeating
  pattern:

  `-..---.--...`

  The same struct with an offset of 1

      iex> Dashes.new([1,2,3], 2)

  would result in the same pattern as above, but steps two pixels into the
  pattern, skipping the "1 on" and the first pixel of the "2 off", resulting
  in the dash pattern starting in this way.

  `.---.--...-..---.--...`

  At this point, the pattern repeats normally.
  """

  defstruct [:dashes, :offset]

  @type t :: %__MODULE__{
          dashes: [number()],
          offset: number()
        }

  @doc """
  Creates a new dash pattern from a list of dash lengths and an optional offset.

  ### Dash Pattern

  An empty list of dash lengths results in a solid line.

  A list of dash lengths with a single element creates a repeating pattern of
  alternating on/off segments all of the single given length.

  A longer list will create a dash pattern cycling through that list while
  alternating on/off. This means that for patterns of an even length the pattern
  will repeat exactly every time, while a pattern of an odd length will repeat
  exactly in cycles of 2, with the on/off values reversed the second time through.

  ### Offset

  If not provided, the default value for `offset` is 0. If a non-zero value
  is provided, the point in which the pattern starts rendering the line is
  shifted by that number of pixels.
  """
  @spec new([number()], number()) :: __MODULE__.t()
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
