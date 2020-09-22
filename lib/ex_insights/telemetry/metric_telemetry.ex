defmodule ExInsights.Telemetry.MetricTelemetry do
  @moduledoc """
  Report a custom metric
  """

  alias ExInsights.Telemetry.{Types, CommonTelemetry}
  alias __MODULE__.Metric

  @type t() :: %__MODULE__{
          metrics: [Metric.t()],
          common: CommonTelemetry.t()
        }

  @type option :: CommonTelemetry.option()

  @enforce_keys [:metrics]
  defstruct [
    :metrics,
    :common
  ]

  @spec new(Types.name(), number()) :: t()
  def new(name, value, options \\ []) when is_binary(name) do
    [Metric.new(name, value)]
    |> new_batch(options)
  end

  @spec new_batch([Metric.t()], [option()]) :: t()
  def new_batch(metrics, options \\ []) when is_list(metrics) do
    %__MODULE__{
      metrics: metrics,
      common: CommonTelemetry.new("Metric", options)
    }
  end
end
