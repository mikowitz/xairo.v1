defmodule Xairo.RGBATest do
  use ExUnit.Case, async: true

  alias Xairo.RGBA
  doctest RGBA

  describe ".new/3" do
    test "stores float values" do
      assert RGBA.new(0.5, 0, 1) == %RGBA{
               red: 0.5,
               green: 0.0,
               blue: 1.0,
               alpha: 1.0
             }
    end

    test "rounds numbers greater than 1" do
      assert RGBA.new(0.5, 0, 255) == %RGBA{
               red: 0.5,
               green: 0.0,
               blue: 1.0,
               alpha: 1.0
             }
    end
  end
end
