defmodule XairoTest do
  use ExUnit.Case

  test "can create and save an empty image" do
    {:ok, ref} = Xairo.Native.new_image(100, 100)
    assert is_reference(ref)

    {:ok, _ref} = Xairo.Native.save_image(ref, "test.png")

    assert_images_equal("test.png", "test/images/empty.png")

    :ok = File.rm("test.png")
  end

  def assert_images_equal(actual_path, expected_path) do
    {:ok, actual} = ExPng.Image.from_file(actual_path)
    {:ok, expected} = ExPng.Image.from_file(expected_path)

    assert actual == expected
  end
end
