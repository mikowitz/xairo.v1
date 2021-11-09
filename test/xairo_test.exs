defmodule XairoTest do
  use ExUnit.Case
  doctest Xairo

  test "greets the world" do
    assert Xairo.hello() == :world
  end
end
