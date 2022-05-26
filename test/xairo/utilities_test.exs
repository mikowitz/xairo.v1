defmodule Xairo.UtilitiesTest do
  use ExUnit.Case, async: true

  alias Xairo.Utilities

  describe "stride_for_width/2" do
    test "returns the stride for the format and width" do
      assert Utilities.stride_for_width(:argb32, 100) == 400
      assert Utilities.stride_for_width(:rgb24, 100) == 400
      assert Utilities.stride_for_width(:a1, 100) == 16
    end

    test "returns an error if the format is invalid" do
      assert Utilities.stride_for_width(:rgb32, 100) == {:error, :invalid_variant}
    end

    test "returns an error if the width is too large" do
      assert Utilities.stride_for_width(:argb32, round(:math.pow(2, 31))) ==
               {:error, :invalid_stride}
    end
  end
end
