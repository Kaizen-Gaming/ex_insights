defmodule ExInsights.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_insights,
      version: "0.2.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      name: "ExInsights",
      description: description(),
      source_url: "https://github.com/StoiximanServices/ex_insights",
      docs: [main: "ExInsights", extras: ["README.md"]],
      package: package()
    ]
  end

  def application do
    [
      mod: {ExInsights.Application, []}
    ]
  end

  defp deps do
    [
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.13"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
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
