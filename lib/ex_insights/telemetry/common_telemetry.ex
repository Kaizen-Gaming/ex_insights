defmodule ExInsights.Telemetry.CommonTelemetry do
  @moduledoc """
  Defines common telemetry fields.
  Ported over from [here](https://github.com/microsoft/ApplicationInsights-node.js/blob/54a37587cb794233a00f44ba629904bcfbd3a659/Declarations/Contracts/TelemetryTypes/Telemetry.ts)
  """

  alias ExInsights.Telemetry.Types

  @type t :: %__MODULE__{
          time: DateTime.t(),
          type: String.t(),
          properties: Types.properties(),
          tags: Types.tags(),
          ver: non_neg_integer()
        }

  @type option ::
          {:time, DateTime.t()} | {:properties, Types.properties()} | {:tags, Types.tags()}

  @enforce_keys [:type]
  defstruct [
    :time,
    :type,
    :properties,
    :tags,
    ver: 2
  ]

  @spec new(String.t(), [option()]) :: t()
  def new(type_name, options \\ []) do
    date_time = Keyword.get(options, :time, DateTime.utc_now())

    %__MODULE__{
      type: type_name,
      time: date_time,
      properties: Keyword.get(options, :properties, %{}),
      tags: Keyword.get(options, :tags, %{})
    }
  end
end
