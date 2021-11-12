defmodule Xairo.NativeFn do
  defmacro native_fn(func_name, args \\ []) do
    signature_args =
      Enum.map(args, fn
        {arg, _} -> arg
        arg -> arg
      end)

    applied_args =
      Enum.map(args, fn
        {arg, {_, _, [:Float]}} -> {:*, [], [arg, 1.0]}
        arg -> arg
      end)

    quote do
      def unquote(func_name)(image, unquote_splicing(signature_args)) do
        with {:ok, _} <-
               apply(Xairo.Native, unquote(func_name), [
                 image.resource,
                 unquote_splicing(applied_args)
               ]) do
          image
        end
      end
    end
  end
end
