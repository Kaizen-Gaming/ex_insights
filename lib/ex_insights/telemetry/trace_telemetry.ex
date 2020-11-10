defmodule ExInsights.Telemetry.TraceTelemetry do
  @moduledoc """
  Trace telemetry reports technical, usually detailed information about the environment,
  usage of resources, performance, capacity etc.
  """

  alias ExInsights.Telemetry.{Types, CommonTelemetry}
  alias ExInsights.Utils

  @type t :: %__MODULE__{
          message: String.t(),
          severityLevel: non_neg_integer(),
          common: CommonTelemetry.t()
        }

  @type option :: {:severity_level, Types.severity_level()} | CommonTelemetry.option()

  @derive Jason.Encoder
  @enforce_keys [:message]
  defstruct [
    :message,
    :severityLevel,
    :common
  ]

  @doc """
  Create new trace telemetry. `severity_level` will be set to `:info` unless set otherwise in the options.
  """
  @spec new(String.t(), [option()]) :: t()
  def new(message, options \\ []) do
    severity_level = Keyword.get(options, :severity_level, :info)

    %__MODULE__{
      message: message,
      severityLevel: Utils.convert(severity_level),
      common: CommonTelemetry.new("Message", options)
    }
  end
end
