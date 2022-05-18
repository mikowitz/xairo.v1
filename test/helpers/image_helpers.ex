defmodule Xairo.Helpers.ImageHelpers do
  @moduledoc false

  import ExUnit.Assertions

  def assert_image(image, expected_path \\ nil)

  def assert_image(%Xairo.Image.Png{} = image, expected_path) do
    do_assert_image(image, expected_path, fn actual, expected ->
      assert hash(actual) == hash(expected)
    end)
  end

  def assert_image(%Xairo.Image.Svg{} = image, expected_path) do
    do_assert_image(image, expected_path, fn actual, expected ->
      assert read(actual) == read(expected)
    end)
  end

  def assert_image(%Xairo.Image.Ps{} = image, expected_path) do
    do_assert_image(image, expected_path, fn actual, expected ->
      assert read(actual) == read(expected)
    end)
  end

  def assert_image(%Xairo.Image.Pdf{} = image, expected_path) do
    do_assert_image(image, expected_path, fn actual, expected ->
      {_, 0} = System.cmd("diff-pdf", [actual, expected])
    end)
  end

  defp do_assert_image(%{filename: filename} = image, expected_path, func) do
    expected_path = expected_path || filename
    Xairo.save_image(image)

    func.(filename, Path.join("test/images/", expected_path))

    :ok = File.rm(filename)
  end

  defp hash(file) do
    File.stream!(file)
    |> Enum.reduce(:crypto.hash_init(:sha256), fn line, acc ->
      :crypto.hash_update(acc, line)
    end)
    |> :crypto.hash_final()
  end

  defp read(file) do
    {content, 0} = System.cmd("cat", [file])

    content
    ## strip ID from SVG
    |> String.replace(~r/id=\".*\"/, "id=\"\"")
    ## strip timestame from PDF
    |> String.replace(~r/%%CreationDate:[^\n]+/, "")
  end
end
