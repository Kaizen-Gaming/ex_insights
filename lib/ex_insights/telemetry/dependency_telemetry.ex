defmodule ExInsights.Telemetry.DependencyTelemetry do
  @moduledoc """
  Telemetry for tracking remote calls (eg HTTP or SQL)
  """

  # definition: https://github.com/microsoft/ApplicationInsights-node.js/blob/2855952b7348b407f370bef4a10af006425f6508/Declarations/Contracts/TelemetryTypes/DependencyTelemetry.ts
  # usage: https://github.com/microsoft/ApplicationInsights-node.js/blob/2855952b7348b407f370bef4a10af006425f6508/Library/EnvelopeFactory.ts#L119

  alias ExInsights.Utils
  alias ExInsights.Telemetry.{Types, CommonTelemetry}

  @typedoc """
  Telemetry about the call to remote component

  * `:id`: request unique id (string)
  * `:name`: Remote call name, e.g. "CustomerList" (string)
  * `:dependencyTypeName`: Type name of the telemetry, such as HTTP or SQL (string)
  * `:target`: Remote component general target information. If left empty, this will be prepopulated with an extracted hostname from the data field, if it is a url. This prepopulation happens when calling `trackDependency`. Use `track` directly to avoid this behavior. (string)
  * `:data`: Remote call data. This is the most detailed information about the call, such as full URL or SQL statement (string)
  * `:duration`: Remote call duration in ms (non-neg integer)
  * `:resultCode`: Result code returned form the remote component. This is domain specific and can be HTTP status code or SQL result code (string or number)
  * `:success`: True if remote call was successful, false otherwise (boolean)
  """
  @type t() :: %__MODULE__{
          id: binary(),
          name: Types.name(),
          dependencyTypeName: Types.name(),
          target: String.t(),
          data: String.t(),
          duration: Types.millisecond(),
          resultCode: String.t() | number(),
          success: boolean(),
          common: CommonTelemetry.t()
        }

  @type option ::
          {:target, String.t()}
          | {:dependency_type_name, String.t()}
          | {:data, String.t()}
          | {:result_code, String.t() | number()}
          | CommonTelemetry.option()

  @enforce_keys [:name, :id, :dependencyTypeName, :success]
  defstruct [
    :dependencyTypeName,
    :target,
    :id,
    :name,
    :data,
    :duration,
    :resultCode,
    :success,
    :common
  ]

  @spec new(
          name :: Types.name(),
          id :: binary(),
          duration :: Types.millisecond(),
          success? :: boolean(),
          options :: [option]
        ) :: t()
  def new(name, id, duration, success?, options \\ []) do
    data = Keyword.get(options, :data, "")

    target =
      case Keyword.get(options, :target) do
        nil ->
          case Utils.try_extract_hostname_and_port(data) do
            {:error, _} -> ""
            {:ok, hostport} -> "#{hostport}|#{id}"
          end

        other ->
          other
      end

    %__MODULE__{
      id: id,
      name: name,
      data: data,
      success: success?,
      target: target,
      duration: Utils.ms_to_timespan(duration),
      dependencyTypeName: Keyword.get(options, :dependency_type_name, "Http"),
      resultCode: Keyword.get(options, :result_code, ""),
      common: CommonTelemetry.new("RemoteDependency", options)
    }
  end
end
