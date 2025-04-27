defmodule Wayfinder.MixProject do
  use Mix.Project

  def project do
    [
      app: :wayfinder,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_paths: ["test"],
      test_pattern: "*_test.exs",
      test_coverage: [tool: ExCoveralls],
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7", optional: true},
      {:file_system, "~> 1.1.0"},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
