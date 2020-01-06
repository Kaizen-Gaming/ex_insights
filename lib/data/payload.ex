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
  def create_event_payload(name, properties, measurements, instrumentation_key \\ nil) do
    %{
      name: name,
      properties: properties,
      measurements: measurements
    }
    |> create_payload("Event", instrumentation_key)
  end

  @doc """
  Create custom trace payload.
  """
  def create_trace_payload(message, severity_level, properties, instrumentation_key \\ nil) do
    %{
      message: message,
      properties: properties,
      severityLevel: Utils.convert(severity_level)
    }
    |> create_payload("Message", instrumentation_key)
  end

  @doc """
  Create custom exception payload.
  """
  def create_exception_payload(exception, stack_trace, handle_at, properties, measurements, instrumentation_key \\ nil)

  def create_exception_payload(
        %{__exception__: true, __struct__: type_name, message: message},
        stack_trace,
        handle_at,
        properties,
        measurements,
        instrumentation_key
      ) do
    do_create_exception_payload(
      inspect(type_name),
      message,
      stack_trace,
      handle_at,
      properties,
      measurements,
      instrumentation_key
    )
  end

  def create_exception_payload(exception, stack_trace, handle_at, properties, measurements, instrumentation_key)
      when is_binary(exception) do
    do_create_exception_payload(
      "Thrown",
      exception,
      stack_trace,
      handle_at,
      properties,
      measurements,
      instrumentation_key
    )
  end

  defp do_create_exception_payload(
         type_name,
         message,
         stack_trace,
         handle_at,
         properties,
         measurements,
         instrumentation_key
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
    |> create_payload("Exception", instrumentation_key)
  end

  @doc """
  Create custom metric payload.
  """
  def create_metric_payload(name, value, properties, instrumentation_key \\ nil) do
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
    |> create_payload("Metric", instrumentation_key)
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
        instrumentation_key \\ nil
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
    |> create_payload("RemoteDependency", instrumentation_key)
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
        instrumentation_key \\ nil,
        id \\ nil
      ) do
     id = if (id == nil), do: Base.encode16(<<:rand.uniform(438_964_124)::size(32)>>), else: id
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
    |> create_payload("Request", instrumentation_key)
  end

  defp create_payload(data, type, instrumentation_key) do
    instrumentation_key = if (instrumentation_key == nil), do: Conf.get_value(:instrumentation_key), else: instrumentation_key
    data
    |> Envelope.create(
      type,
      DateTime.utc_now(),
      instrumentation_key,
      Envelope.get_tags()
    )
  end
end
