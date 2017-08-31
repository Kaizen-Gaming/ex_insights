defmodule ExInsights.Data.Payload do
  @moduledoc """
  Central point for creating data objects. Intended for internal use.
  """

  alias ExInsights.Data.Envelope
  alias ExInsights.Configuration, as: Conf
  alias ExInsights.Utils

  @doc """
  Create custom event payload.
  """
  def create_event_payload(name, properties, measurements) do
    %{
      name: name,
      properties: properties,
      measurements: measurements
    }
    |> create_payload("Event")
  end

  @doc """
  Create custom trace payload.
  """
  def create_trace_payload(message, severity_level, properties) do
    %{
      message: message,
      properties: properties,
      severity_level: Utils.convert(severity_level)
    }
    |> create_payload("Message")
  end

  @doc """
  Create custom metric payload.
  """
  def create_metric_payload(name, value, properties) do
    %{
      metrics: [
        %{
          name: name,
          value: value,
          kind: 0 # Measurement = 0, Aggregation = 1
        }
      ],
      properties: properties
    }
    |> create_payload("Metric")
  end

  @doc """
  Create custom dependency payload.
  """
  def create_dependency_payload(name, command_name, elapsed_time_ms, success, dependency_type_name, target, properties) do
    %{
      name: name,
      data: command_name,
      target: target,
      duration: Utils.ms_to_timespan(elapsed_time_ms),
      success: success,
      type: dependency_type_name,
      properties: properties
    }
    |> create_payload("RemoteDependency")
  end

  defp create_payload(data, type) do
    data
    |> Envelope.create(type, DateTime.utc_now(), Conf.get_value(:instrumentation_key), Envelope.get_tags())
  end
end
