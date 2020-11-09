defmodule ExInsights do
  @moduledoc """
  Exposes methods for POST events & metrics to Azure Application Insights.
  For more information on initialization and usage consult the [README.md](readme.html)
  """

  alias ExInsights.{Envelope, Utils}

  alias ExInsights.Telemetry.{
    Types,
    EventTelemetry,
    TraceTelemetry,
    ExceptionTelemetry,
    MetricTelemetry,
    DependencyTelemetry,
    RequestTelemetry
  }

  @type instrumentation_key :: Types.instrumentation_key() | nil

  @doc ~S"""
  Log a user action or other occurrence.

  ### Parameters:

  ```
  name: name of the event (string or atom)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  measurements (optional): a map of [string -> number] values associated with this event that can be aggregated/sumed/etc. on the UI
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will the default one provided to the `ExInsights.Aggregation.Worker` will be used (see README.md)
  ```
  """
  @spec track_event(
          name :: Types.name(),
          properties :: Types.properties(),
          measurements :: Types.measurements(),
          tags :: Types.tags(),
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_event(
        name,
        properties \\ %{},
        measurements \\ %{},
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    name
    |> EventTelemetry.new(properties: properties, measurements: measurements, tags: tags)
    |> track(instrumentation_key)
  end

  @doc ~S"""
  Log a trace message.

  ### Parameters:

  ```
  message: A string to identify this event in the portal.
  severity_level: The level of severity for the event.
  properties: map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will the default one provided to the `ExInsights.Aggregation.Worker` will be used (see README.md)
  ```
  """
  @spec track_trace(
          String.t(),
          severity_level :: Types.severity_level(),
          properties :: Types.properties(),
          tags :: Types.tags(),
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_trace(
        message,
        severity_level \\ :info,
        properties \\ %{},
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    message
    |> TraceTelemetry.new(severity_level: severity_level, properties: properties, tags: tags)
    |> track(instrumentation_key)
  end

  @doc ~S"""
  Log an exception you have caught.

  ### Parameters:

  ```
  exception: An Error from a catch clause, or the string error message.
  stack_trace: An erlang stacktrace.
  properties: map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  measurements: map[string, number] - metrics associated with this event, displayed in Metrics Explorer on the portal. Defaults to empty.
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will the default one provided to the `ExInsights.Aggregation.Worker` will be used (see README.md)
  ```
  """
  @spec track_exception(
          Exception.t() | String.t(),
          stack_trace :: Exception.stacktrace(),
          String.t() | nil,
          properties :: Types.properties(),
          measurements :: Types.measurements(),
          tags :: Types.tags(),
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_exception(
        exception,
        stack_trace,
        handled_at \\ nil,
        properties \\ %{},
        measurements \\ %{},
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    exception
    |> ExceptionTelemetry.new(
      stack_trace: stack_trace,
      handled_at: handled_at,
      properties: properties,
      measurements: measurements,
      tags: tags
    )
    |> track(instrumentation_key)
  end

  @doc ~S"""
  Log a numeric value that is not associated with a specific event.

  Typically used to send regular reports of performance indicators.

  ### Parameters:

  ```
  name: name of the metric
  value: the value of the metric (number)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will the default one provided to the `ExInsights.Aggregation.Worker` will be used (see README.md)
  ```
  """
  @spec track_metric(
          name :: Types.name(),
          value :: number(),
          properties :: Types.properties(),
          tags :: Types.tags(),
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_metric(name, value, properties \\ %{}, tags \\ %{}, instrumentation_key \\ nil) do
    name
    |> MetricTelemetry.new(value, properties: properties, tags: tags)
    |> track(instrumentation_key)
  end

  @doc ~S"""
  Log a dependency, for example requests to an external service or SQL calls.

  ### Parameters:

  ```
  name: String that identifies the dependency.
  data: String of the name of the command made against the dependency (eg. full URL with querystring or SQL command text).
  start_time: The datetime when the dependency call was initiated.
  duration: Remote call duration in ms (non-neg integer)
  success?: True if remote call was successful, false otherwise (boolean).
  dependency_type_name: Type name of the telemetry, such as HTTP or SQL (string).
  target: String of the target host of the dependency.
  properties (optional): map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  id (optional): a unique identifier representing the dependency call.
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will the default one provided to the `ExInsights.Aggregation.Worker` will be used (see README.md)
  ```
  """

  @spec track_dependency(
          name :: Types.name(),
          data :: String.t(),
          start_time :: DateTime.t(),
          Types.millisecond(),
          boolean(),
          String.t(),
          String.t() | nil,
          properties :: Types.properties(),
          id :: binary() | nil,
          tags :: Types.tags(),
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_dependency(
        name,
        data,
        start_time,
        duration,
        success?,
        dependency_type_name \\ "",
        target \\ nil,
        properties \\ %{},
        id \\ nil,
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    id = if id == nil, do: Utils.generate_id(), else: id

    name
    |> DependencyTelemetry.new(id, duration, success?,
      dependency_type_name: dependency_type_name,
      data: data,
      time: start_time,
      target: target,
      properties: properties,
      tags: tags
    )
    |> track(instrumentation_key)
  end

  @doc ~S"""
  Log an _incoming_ request, for example incoming HTTP requests

  ### Parameters:

  ```
  name: String that identifies the request
  url: Request URL
  source: Request Source. Encapsulates info about the component that initiated the request (can be nil)
  start_time: The datetime when the request was initiated.
  elapsed_time_ms: Number for elapsed time in milliseconds
  response_code: Result code reported by the application
  success?: whether the request was successfull
  properties (optional): map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  measurements (optional): a map of [string -> number] values associated with this event that can be aggregated/sumed/etc. on the UI
  id (optional): a unique identifier representing the request.
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will the default one provided to the `ExInsights.Aggregation.Worker` will be used (see README.md)
  ```
  """
  @spec track_request(
          name :: Types.name(),
          url :: String.t(),
          source :: String.t() | nil,
          start_time :: DateTime.t(),
          elapsed_time_ms :: Types.millisecond(),
          response_code :: String.t() | number(),
          success? :: boolean(),
          properties :: Types.properties(),
          measurements :: Types.measurements(),
          id :: binary() | nil,
          tags :: Types.tags(),
          instrumentation_key :: instrumentation_key()
        ) ::
          :ok
  def track_request(
        name,
        url,
        source,
        start_time,
        elapsed_time_ms,
        response_code,
        success?,
        properties \\ %{},
        measurements \\ %{},
        id \\ nil,
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    (id || Utils.generate_id())
    |> RequestTelemetry.new(name, url, source, elapsed_time_ms, success?,
      time: start_time,
      response_code: response_code,
      measurements: measurements,
      properties: properties,
      tags: tags
    )
    |> track(instrumentation_key)
  end

  # when instrumentation_key is not explicitly set by the caller (default is nil)
  # the wrapping into an envelope will happen here but the instrumentation key
  # will be later set inside the `ExInsights.Aggregation.Worker` using the startup args

  @spec track(Envelope.telemetry(), instrumentation_key()) :: :ok
  defp track(telemetry, instrumentation_key)

  defp track(telemetry, instrumentation_key) do
    telemetry
    |> Envelope.wrap(instrumentation_key)
    |> ExInsights.Aggregation.Worker.track()
  end
end
