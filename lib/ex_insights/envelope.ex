defmodule ExInsights.Envelope do
  @moduledoc ~S"""
  Track request envelope

  Envelope data looks like this
  ```json
  {
    "time": "2017-08-24T08:55:56.968Z",
    "iKey": "some-guid-value-key",
    "name": "Microsoft.ApplicationInsights.someguidvaluekey.Event",
    "tags": {
      "ai.session.id": "SLzGH",
      "ai.device.id": "browser",
      "ai.device.type": "Browser",
      "ai.internal.sdkVersion": "javascript:1.0.11",
      "ai.user.id": "V2Yph",
      "ai.operation.id": "VKgP+",
      "ai.operation.name": "/"
    },
    "data": {
      "baseType": "EventData",
      "baseData": {
        "ver": 2,
        "name": "button clicked",
        "properties": {
          "click type": "double click"
        },
        "measurements": {
          "clicks": 2
        }
      }
    }
  }
  ```
  """

  alias ExInsights.Telemetry.{
    Types,
    EventTelemetry,
    TraceTelemetry,
    ExceptionTelemetry,
    RequestTelemetry,
    DependencyTelemetry,
    MetricTelemetry
  }

  @app_version Mix.Project.config()[:version]

  @type telemetry ::
          EventTelemetry.t()
          | TraceTelemetry.t()
          | ExceptionTelemetry.t()
          | RequestTelemetry.t()
          | DependencyTelemetry.t()
          | MetricTelemetry.t()

  @type missing_key :: {:error, :missing_instrumentation_key}

  @type t :: %__MODULE__{
          time: String.t(),
          name: String.t(),
          iKey: String.t() | missing_key(),
          tags: Types.tags(),
          data: map()
        }

  defstruct [
    :time,
    :name,
    :iKey,
    :tags,
    :data
  ]

  @spec wrap(telemetry :: telemetry(), Types.instrumentation_key() | nil) :: t()
  def wrap(%{} = telemetry, instrumentation_key) do
    type = telemetry.common.type

    %__MODULE__{
      time: time(telemetry.common.time),
      tags: merge_tags(telemetry.common.tags),
      iKey: store_instrumentation_key(instrumentation_key),
      name: name(type, instrumentation_key),
      data: %{
        baseType: "#{type}Data",
        baseData: to_base_data(telemetry)
      }
    }
  end

  @spec default_tags() :: %{optional(String.t()) => String.t()}
  def default_tags(),
    do: %{
      "ai.internal.sdkVersion" => "elixir:#{@app_version}"
    }

  @spec instrumentation_key_set?(t()) :: boolean()
  def instrumentation_key_set?(envelope)
  def instrumentation_key_set?(%__MODULE__{iKey: key}) when is_binary(key), do: true
  def instrumentation_key_set?(%__MODULE__{}), do: false

  @spec set_instrumentation_key(t(), Types.instrumentation_key()) :: t()
  def set_instrumentation_key(envelope, key)

  def set_instrumentation_key(
        %__MODULE_{iKey: {:error, :missing_instrumentation_key}} = envelope,
        instrumentation_key
      )
      when is_binary(instrumentation_key) do
    %{envelope | iKey: instrumentation_key, name: name(envelope.name, instrumentation_key)}
  end

  def set_instrumentation_key(%__MODULE__{} = envelope), do: envelope

  @spec time(DateTime.t()) :: String.t()
  defp time(%DateTime{} = time), do: DateTime.to_iso8601(time)

  @spec name(String.t(), nil) :: String.t()
  defp name(type, nil), do: type

  @spec name(String.t(), String.t()) :: String.t()
  defp name(type, instrumentation_key) when is_binary(instrumentation_key),
    do: "Microsoft.ApplicationInsights.#{String.replace(instrumentation_key, "-", "")}.#{type}"

  @spec merge_tags(Types.tags() | nil) :: Types.tags()
  defp merge_tags(tags)
  defp merge_tags(nil), do: default_tags()
  defp merge_tags(%{} = map), do: Map.merge(default_tags(), map)

  @spec to_base_data(telemetry()) :: map()
  defp to_base_data(%{} = telemetry) do
    extra_props = [:ver, :properties]
    extra = Map.take(telemetry.common, extra_props)

    telemetry
    |> Map.from_struct()
    |> Map.delete(:common)
    |> Map.merge(extra)
  end

  @spec store_instrumentation_key(Types.instrumentation_key() | nil) ::
          Types.instrumentation_key() | missing_key()
  defp store_instrumentation_key(key)
  defp store_instrumentation_key(nil), do: {:error, :missing_instrumentation_key}
  defp store_instrumentation_key(key) when is_binary(key), do: key
end
