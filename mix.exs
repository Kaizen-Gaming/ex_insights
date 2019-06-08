defmodule ExInsights.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_insights,
      version: "0.3.1",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "ExInsights",
      description: description(),
      source_url: "https://github.com/StoiximanServices/ex_insights",
      docs: [main: "ExInsights", extras: ["README.md"]],
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def elixirc_paths(:test) do
    ["lib", "test/test_helper"]
  end

  def elixirc_paths(_) do
    ["lib"]
  end

  def application do
    [
      mod: {ExInsights.Application, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.5"},
      {:decorator, "~> 1.3.0"},
      {:ex_doc, "~> 0.20.2", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false}
    ]
  end

  defp description do
    "Elixir client library to log telemetry data on Azure Application Insights."
  end

  defp package do
    [
      maintainers: ["bottlenecked"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/StoiximanServices/ex_insights"}
    ]
  end
end
