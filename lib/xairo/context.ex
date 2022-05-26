defmodule Xairo.Context do
  @moduledoc false

  defstruct [:context]

  def new(%Xairo.ImageSurface{surface: surface}) do
    with {:ok, context} <- Xairo.Native.context_new_from_image_surface(surface) do
      %__MODULE__{
        context: context
      }
    end
  end

  def status(%__MODULE__{context: ctx}) do
    with {:ok, _} <- Xairo.Native.context_status(ctx), do: :ok
  end

  def set_source_rgb(%__MODULE__{context: ctx} = this, r, g, b) do
    Xairo.Native.context_set_source_rgb(ctx, r / 1, g / 1, b / 1)
    this
  end

  def set_source_rgba(%__MODULE__{context: ctx} = this, r, g, b, a) do
    Xairo.Native.context_set_source_rgba(ctx, r / 1, g / 1, b / 1, a / 1)
    this
  end

  def paint(%__MODULE__{context: ctx} = this) do
    with {:ok, _} <- Xairo.Native.context_paint(ctx), do: this
  end

  def paint_with_alpha(%__MODULE__{context: ctx} = this, alpha) do
    with {:ok, _} <- Xairo.Native.context_paint_with_alpha(ctx, alpha / 1), do: this
  end

  def stroke(%__MODULE__{context: ctx} = this) do
    with {:ok, _} <- Xairo.Native.context_stroke(ctx), do: this
  end

  def stroke_preserve(%__MODULE__{context: ctx} = this) do
    with {:ok, _} <- Xairo.Native.context_stroke(ctx), do: this
  end

  def fill(%__MODULE__{context: ctx} = this) do
    with {:ok, _} <- Xairo.Native.context_fill(ctx), do: this
  end

  def fill_preserve(%__MODULE__{context: ctx} = this) do
    with {:ok, _} <- Xairo.Native.context_fill(ctx), do: this
  end

  def move_to(%__MODULE__{context: ctx} = this, x, y) do
    Xairo.Native.context_move_to(ctx, x / 1, y / 1)
    this
  end

  def line_to(%__MODULE__{context: ctx} = this, x, y) do
    Xairo.Native.context_line_to(ctx, x / 1, y / 1)
    this
  end

  def rectangle(%__MODULE__{context: ctx} = this, x, y, w, h) do
    Xairo.Native.context_rectangle(ctx, x / 1, y / 1, w / 1, h / 1)
    this
  end

  def close_path(%__MODULE__{context: ctx} = this) do
    Xairo.Native.context_close_path(ctx)
    this
  end
end
