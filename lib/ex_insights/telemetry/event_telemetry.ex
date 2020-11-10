defmodule ExInsights.Telemetry.EventTelemetry do
  @moduledoc """
  Report a custom event
  """

  alias ExInsights.Telemetry.{Types, CommonTelemetry}

  @type t() :: %__MODULE__{
          name: Types.name(),
          measurements: Types.measurements(),
          common: CommonTelemetry.t()
        }

  @type option :: {:measurements, Types.measurements()} | CommonTelemetry.option()

  @derive Jason.Encoder
  @enforce_keys [:name]
  defstruct [
    :name,
    :measurements,
    :common
  ]

  @spec new(name :: Types.name(), options :: [option]) :: t()
  def new(name, options \\ []) do
    %__MODULE__{
      name: name,
      measurements: Keyword.get(options, :measurements, %{}),
      common: CommonTelemetry.new("Event", options)
    }
  end
end
