defmodule ExInsights.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_insights,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {ExInsights.Application, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.13"},
      {:benchee, "~> 0.9.0", only: :dev}
    ]
  end
end
