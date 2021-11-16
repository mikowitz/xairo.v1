defmodule Xairo.Helpers.ImageHelpers do
  @moduledoc false

  import ExUnit.Assertions

  def assert_image(image, path) do
    Xairo.save_image(image, path)

    actual = hash(path)
    expected = hash("test/images/" <> path)

    assert actual == expected

    :ok = File.rm(path)
  end

  defp hash(file) do
    File.stream!(file)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn line, acc ->
      :crypto.hash_update(acc, line)
    end)
    |> :crypto.hash_final()
  end
end
