defmodule Xairo.MixProject do
  use Mix.Project

  def project do
    [
      app: :xairo,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: compiler_paths(Mix.env()),
      dialyzer: dialyzer(),
      docs: [
        main: Xairo,
        groups_for_modules: [
          "Image Types": [
            Xairo.Image.Pdf,
            Xairo.Image.Png,
            Xairo.Image.Ps,
            Xairo.Image.Svg
          ],
          Shapes: [
            Xairo.Arc,
            Xairo.Curve,
            Xairo.Dashes,
            Xairo.Path,
            Xairo.Point,
            Xairo.Rectangle,
            Xairo.Vector
          ],
          Color: [
            Xairo.RGBA,
            Xairo.Pattern,
            Xairo.Pattern.LinearGradient,
            Xairo.Pattern.RadialGradient,
            Xairo.Pattern.Mesh
          ],
          Text: [
            Xairo.Text,
            Xairo.Text.Extents,
            Xairo.Text.Font
          ],
          Transformation: [
            Xairo.Matrix
          ]
        ]
      ]
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
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.24", only: [:dev, :test], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:rustler, "~> 0.22.2"}
    ]
  end

  defp compiler_paths(:test), do: ["test/helpers"] ++ compiler_paths(:prod)
  defp compiler_paths(_), do: ["lib"]

  defp dialyzer do
    [
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      plt_add_apps: [:ex_unit]
    ]
  end
end
