defmodule Xairo.MixProject do
  use Mix.Project

  def project do
    [
      app: :xairo,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: compiler_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:rustler, "~> 0.22.2"}
    ]
  end

  defp compiler_paths(:test), do: ["test/helpers"] ++ compiler_paths(:prod)
  defp compiler_paths(_), do: ["lib"]
end
