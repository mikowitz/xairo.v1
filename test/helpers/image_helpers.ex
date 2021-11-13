defmodule Xairo.Helpers.ImageHelpers do
  @moduledoc false

  import ExUnit.Assertions

  def assert_image(image, expected_path) do
    Xairo.save_image(image, "test.png")

    actual = hash("test.png")
    expected = hash("test/images/" <> expected_path)

    assert actual == expected
  end

  defp hash(file) do
    initial_state = :crypto.hash_init(:sha256)

    File.stream!(file, [], 2048)
    |> Enum.reduce(initial_state, &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
  end
end
