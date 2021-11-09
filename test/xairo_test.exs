defmodule XairoTest do
  use ExUnit.Case

  test "NIF connection" do
    assert Xairo.Native.add(1, 2) == 3
  end
end
