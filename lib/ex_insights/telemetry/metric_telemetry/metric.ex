defmodule ExInsights.Telemetry.MetricTelemetry.Metric do
  alias ExInsights.Telemetry.Types

  # Metric definition: https://github.com/microsoft/ApplicationInsights-node.js/blob/2855952b7348b407f370bef4a10af006425f6508/Declarations/Contracts/TelemetryTypes/MetricTelemetry.ts
  # Usage: https://github.com/microsoft/ApplicationInsights-node.js/blob/2855952b7348b407f370bef4a10af006425f6508/Library/EnvelopeFactory.ts#L204
  # Kinds: https://github.com/microsoft/ApplicationInsights-node.js/blob/50dec0941d5e73de6b7ffe081f66ab739bd62876/Declarations/Contracts/Generated/DataPointType.ts

  @type measurement() :: 0
  @type aggregation() :: 1
  @type kind :: aggregation() | measurement()

  @type t() :: %__MODULE__{
          name: Types.name(),
          value: number(),
          kind: kind()
        }

  @derive Jason.Encoder
  @enforce_keys [:name, :value, :kind]
  defstruct [
    :name,
    :value,
    :kind
  ]

  @spec new(Types.name(), number()) :: t()
  def new(name, value) do
    %__MODULE__{
      name: name,
      value: value,
      kind: 0
    }
  end
end
