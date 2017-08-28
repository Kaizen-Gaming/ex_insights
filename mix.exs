defmodule ExInsights.Mixfile do
  use Mix.Project

  def project do
    [
      app: :ex_insights,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
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
      {:httpoison, "~> 0.13"}
    ]
  end

  defp description do
    "Elixir client library to log telemetry data on Azure Application Insights."
  end

  defp package do
    [
      maintainers: ["bottlenecked"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/StoiximanServices/ex_insights"},
      source_url: "https://github.com/StoiximanServices/ex_insights"
    ]
  end

end
