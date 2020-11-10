defmodule ExInsights.Telemetry.RequestTelemetry do
  @moduledoc """
  Report _incoming_ requests processing
  """

  # definition: https://github.com/microsoft/ApplicationInsights-node.js/blob/2855952b7348b407f370bef4a10af006425f6508/Declarations/Contracts/TelemetryTypes/RequestTelemetry.ts
  # usage: https://github.com/microsoft/ApplicationInsights-node.js/blob/2855952b7348b407f370bef4a10af006425f6508/Library/EnvelopeFactory.ts#L182

  # note: the go client https://github.com/microsoft/ApplicationInsights-Go/blob/master/appinsights/contracts/requestdata.go#L45
  # has measurements defined as part of the request type which is missing from the node.js client

  alias ExInsights.Telemetry.{Types, CommonTelemetry}
  alias ExInsights.Utils

  @typedoc """
  Telemetry about the incoming request processsed by the application

  * `:id`: id of incoming request (string)
  * `:name`: Request name (string or atom)
  * `:url`: Request url (string)
  * `:source`: Request source. This encapsulates the information about the component that initiated the request (string)
  * `:duration`: Request processing time in ms (non-neg integer)
  * `:responseCode`: Result code reported by the application (string or number)
  * `:success`: Whether the request was successful (bool)
  * `:measurements`: Collection of custom measurements (map of string -> number)
  * `:common`: Properties shared by all Telemetry types. See `ExInsights.Telemetry.CommonTelemetry` for more info.
  """
  @type t() :: %__MODULE__{
          id: binary(),
          url: String.t(),
          name: Types.name(),
          source: String.t(),
          duration: Types.millisecond(),
          responseCode: String.t() | number(),
          success: boolean(),
          measurements: Types.measurements(),
          common: CommonTelemetry.t()
        }

  @type option ::
          {:response_code, String.t() | number()}
          | {:measurements, Types.measurements()}
          | CommonTelemetry.option()

  @derive Jason.Encoder
  @enforce_keys [:id, :name, :url, :success]
  defstruct [
    :id,
    :name,
    :url,
    :source,
    :duration,
    :responseCode,
    :success,
    :measurements,
    :common
  ]

  @spec new(
          id :: binary(),
          name :: Types.name(),
          url :: String.t(),
          source :: String.t(),
          duration :: Types.millisecond(),
          success? :: boolean(),
          options :: [option()]
        ) :: t()
  def new(id, name, url, source, duration, success?, options \\ []) do
    %__MODULE__{
      id: id,
      name: name,
      url: url,
      source: source,
      duration: Utils.ms_to_timespan(duration),
      success: success?,
      responseCode: Keyword.get(options, :response_code, ""),
      measurements: Keyword.get(options, :measurements, %{}),
      common: CommonTelemetry.new("Request", options)
    }
  end
end
