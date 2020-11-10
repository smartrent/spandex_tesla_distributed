defmodule SpandexTeslaDistributed.MixProject do
  use Mix.Project

  def project do
    [
      app: :spandex_tesla_distributed,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_deps: :app_tree,
        plt_add_apps: [:ex_unit, :mix]
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
      {:credo, "~> 1.5", only: [:dev, :test]},
      {:dialyxir, "~> 1.0.0", only: [:test, :dev], runtime: false},
      {:tesla, "~> 1.3"}
    ]
  end

  defp aliases do
    [
      lint: ["credo --strict"]
    ]
  end
end
