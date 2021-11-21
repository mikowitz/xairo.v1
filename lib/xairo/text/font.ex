defmodule Xairo.Text.Font do
  @moduledoc """
  Models a simple "toy" font with font family, slant, and weight.

  In cairo's internals, these fonts are referred to as "toy fonts" because they are not feature
  complete and can be used only for very simple left-to-right text. Complex scripts such as
  Hebrew or Arabic, or scripts that make extensive use of diacritical marks, are not supported by
  this interface. In Cairo, advanced font rendering should be done with an external library that
  focuses on text rendering, such as [Pango](https://www.pango.org)
  """
  defstruct [
    :family,
    :slant,
    :weight
  ]

  @type family :: :serif | :sans | :cursive | :fantasy | :monospace
  @type slant :: :normal | :italic | :oblique
  @type weight :: :normal | :bold

  @type t :: %__MODULE__{
          family: family(),
          slant: slant(),
          weight: weight()
        }

  @type error :: {:error, atom(), atom()}

  @doc """
  Creates a new font.

  This function expects a keyword list with values for `:family`, `:slant,` and `:weight`.

  For keys that are not given, Cairo's font defaults are selected

  - `family: :sans`
  - `slant: :normal`
  - `weight: normal`

  ## Examples

      iex> Font.new()
      #Font<sans, normal, normal>

      iex> Font.new(family: :cursive)
      #Font<cursive, normal, normal>

      iex> Font.new(slant: :italic, weight: :bold)
      #Font<sans, italic, bold>

  Any unexpected values will return an error tuple. If multiple invalid values are given, only an error for the
  first invalid value detected will be returned

      iex> Font.new(family: :serfi, slant: :very, weight: :invisible)
      {:error, :invalid_font_family, :serfi}
  """
  @spec new(keyword(atom())) :: __MODULE__.t() | error()
  def new(opts \\ []) do
    with {:ok, family} <- get_value(opts, :family),
         {:ok, slant} <- get_value(opts, :slant),
         {:ok, weight} <- get_value(opts, :weight) do
      %__MODULE__{
        family: family,
        slant: slant,
        weight: weight
      }
    end
  end

  defp get_value(opts, key) do
    case opts[key] do
      nil ->
        {:ok, default(key)}

      value ->
        if allowed?(key, value), do: {:ok, value}, else: {:error, :"invalid_font_#{key}", value}
    end
  end

  defp default(:family), do: :sans
  defp default(:slant), do: :normal
  defp default(:weight), do: :normal

  defp allowed?(:family, value), do: value in ~w(serif sans cursive fantasy monospace)a
  defp allowed?(:slant, value), do: value in ~w(normal italic oblique)a
  defp allowed?(:weight, value), do: value in ~w(normal bold)a

  defimpl Inspect do
    import Inspect.Algebra

    def inspect(font, _opts) do
      concat([
        "#Font<",
        [
          font.family,
          font.slant,
          font.weight
        ]
        |> Enum.join(", "),
        ">"
      ])
    end
  end
end
