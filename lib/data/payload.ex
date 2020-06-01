defmodule ExInsights.Data.Payload do
  @moduledoc """
  Central point for creating data objects. Intended for internal use.
  """

  alias ExInsights.Data.Envelope
  alias ExInsights.Utils

  @doc """
  Create custom event payload.
  """
  def create_event_payload(name, properties, measurements, tags) do
    %{
      name: name,
      properties: properties,
      measurements: measurements
    }
    |> create_payload("Event", tags)
  end

  @doc """
  Create custom trace payload.
  """
  def create_trace_payload(message, severity_level, properties, tags) do
    %{
      message: message,
      properties: properties,
      severityLevel: Utils.convert(severity_level)
    }
    |> create_payload("Message", tags)
  end

  @doc """
  Create custom exception payload.
  """
  def create_exception_payload(
        %{__exception__: true, __struct__: type_name, message: message},
        stack_trace,
        handle_at,
        properties,
        measurements,
        tags
      ) do
    do_create_exception_payload(
      inspect(type_name),
      message,
      stack_trace,
      handle_at,
      properties,
      measurements,
      tags
    )
  end

  def create_exception_payload(exception, stack_trace, handle_at, properties, measurements, tags)
      when is_binary(exception) do
    do_create_exception_payload(
      "Thrown",
      exception,
      stack_trace,
      handle_at,
      properties,
      measurements,
      tags
    )
  end

  defp do_create_exception_payload(
         type_name,
         message,
         stack_trace,
         handle_at,
         properties,
         measurements,
         tags
       ) do
    %{
      handledAt: handle_at || "unhandled",
      exceptions: [
        %{
          typeName: type_name,
          message: message,
          hasFullStack: !is_nil(stack_trace),
          parsedStack: Utils.parse_stack_trace(stack_trace)
        }
      ],
      severityLevel: Utils.convert(:error),
      properties: properties,
      measurements: measurements
    }
    |> create_payload("Exception", tags)
  end

  @doc """
  Create custom metric payload.
  """
  def create_metric_payload(name, value, properties, tags) do
    %{
      metrics: [
        %{
          name: name,
          value: value,
          # Measurement = 0, Aggregation = 1
          kind: 0
        }
      ],
      properties: properties
    }
    |> create_payload("Metric", tags)
  end

  @doc """
  Create custom dependency payload.
  """
  def create_dependency_payload(
        name,
        command_name,
        elapsed_time_ms,
        success,
        dependency_type_name,
        target,
        properties,
        tags
      ) do
    %{
      name: name,
      data: command_name,
      target: target,
      duration: Utils.ms_to_timespan(elapsed_time_ms),
      success: success,
      type: dependency_type_name,
      properties: properties
    }
    |> create_payload("RemoteDependency", tags)
  end

  @doc """
  Create request payload
  """
  def create_request_payload(
        name,
        url,
        source,
        elapsed_time_ms,
        result_code,
        success,
        properties,
        measurements,
        tags,
        id
      ) do
    %{
      name: name,
      url: url,
      id: id,
      source: source,
      duration: Utils.ms_to_timespan(elapsed_time_ms),
      responseCode: result_code,
      success: success,
      properties: properties,
      measurements: measurements
    }
    |> create_payload("Request", tags)
  end

  @spec create_payload(data :: map(), type :: String.t(), tags :: map()) :: Envelope.t()
  defp create_payload(data, type, tags) do
    data
    |> Envelope.create(
      type,
      DateTime.utc_now(),
      Map.merge(Envelope.get_tags(), tags)
    )
  end
end
