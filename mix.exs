defmodule ExInsights.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_insights,
      version: "0.8.0",
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
    ["lib", "test/test_helper", "test/client"]
  end

  def elixirc_paths(_) do
    ["lib"]
  end

  def application do
    []
  end

  defp deps do
    [
      {:decorator, "~> 1.3"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.2"}
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
