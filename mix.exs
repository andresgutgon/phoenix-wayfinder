defmodule Wayfinder.MixProject do
  use Mix.Project

  def project do
    [
      app: :wayfinder,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, "~> 1.7", optional: true}
    ]
  end
end
