defmodule Xairo.Text.ExtentsTest do
  use ExUnit.Case, async: true

  alias Xairo.Text.Extents

  describe "for/2" do
    test "returns a Text.Extents struct for the given string in the context of the image" do
      image = Xairo.new_image(1000, 1000, 20)

      %Extents{} = extents = Extents.for("hello", image)

      assert extents.text == "hello"
    end
  end
end
