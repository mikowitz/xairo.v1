defmodule Xairo.NativeFn do
  @moduledoc false

  defmacro native_fn(func_name, args \\ []) do
    signature_args =
      Enum.map(args, fn
        {arg, _} -> arg
        arg -> signature_arg(arg)
      end)

    applied_args =
      Enum.map(args, fn
        {arg, {_, _, [:Float]}} -> {:*, [], [arg, 1.0]}
        arg -> arg
      end)

    quote do
      def unquote(func_name)(%{resource: resource} = image, unquote_splicing(signature_args)) do
        result =
          apply(
            Xairo.Native,
            unquote(func_name),
            [resource, unquote_splicing(applied_args)]
          )

        case result do
          {:ok, _} -> image
          ref when is_reference(ref) -> image
          _ -> result
        end
      end
    end
  end

  defp signature_arg({:point, _, _} = arg), do: signature_arg(arg, :Point)
  defp signature_arg({:vector, _, _} = arg), do: signature_arg(arg, :Vector)
  defp signature_arg({:rgba, _, _} = arg), do: signature_arg(arg, :RGBA)
  defp signature_arg({:arc, _, _} = arg), do: signature_arg(arg, :Arc)
  defp signature_arg({:curve, _, _} = arg), do: signature_arg(arg, :Curve)
  defp signature_arg({:rectangle, _, _} = arg), do: signature_arg(arg, :Rectangle)
  defp signature_arg({:matrix, _, _} = arg), do: signature_arg(arg, :Matrix)

  defp signature_arg({:font, _, _} = arg) do
    {:=, [],
     [
       {:%, [], [{:__aliases__, [alias: false], [:Xairo, :Text, :Font]}, {:%{}, [], []}]},
       arg
     ]}
  end

  defp signature_arg(arg), do: arg

  defp signature_arg(arg, struct_name) do
    {:=, [],
     [
       {:%, [], [{:__aliases__, [alias: false], [:Xairo, struct_name]}, {:%{}, [], []}]},
       arg
     ]}
  end
end
