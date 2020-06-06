defmodule ExInsights do
  @moduledoc """
  Exposes methods for POST events & metrics to Azure Application Insights.
  For more information on initialization and usage consult the [README.md](readme.html)
  """

  alias ExInsights.Configuration, as: Conf
  alias ExInsights.Data.{Envelope, Payload}

  @typedoc """
  Measurement name. Will be used extensively in the app insights UI
  """
  @type name :: String.t() | atom

  @typedoc ~S"""
  A map of `[name -> string]` to add metadata to a tracking request
  """
  @type properties :: %{optional(name) => String.t()}

  @typedoc ~S"""
  A map of `[name -> number]` to add measurement data to a tracking request
  """
  @type measurements :: %{optional(name) => number}

  @typedoc ~S"""
  A map of `[name -> string]` to add tags metadata to a tracking request
  """
  @type tags :: %{optional(name) => String.t()}

  @typedoc ~S"""
  Defines the level of severity for the event.
  """
  @type severity_level :: :verbose | :info | :warning | :error | :critical

  @typedoc ~S"""
  Represents the exception's stack trace.
  """
  @type stack_trace :: [stack_trace_entry]
  @type stack_trace_entry ::
          {module, atom, arity_or_args, location}
          | {(... -> any), arity_or_args, location}
  @type instrumentation_key :: String.t() | nil

  @typep arity_or_args :: non_neg_integer | list
  @typep location :: keyword

  @doc ~S"""
  Log a user action or other occurrence.

  ### Parameters:

  ```
  name: name of the event (string)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  measurements (optional): a map of [string -> number] values associated with this event that can be aggregated/sumed/etc. on the UI
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will be read from the configuration (see README.md)
  ```
  """
  @spec track_event(
          name :: name,
          properties :: properties,
          measurements :: measurements,
          tags :: tags,
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_event(
        name,
        properties \\ %{},
        measurements \\ %{},
        tags \\ %{},
        instrumentation_key \\ nil
      )
      when is_binary(name) do
    Payload.create_event_payload(name, properties, measurements, tags)
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
  instrumentation_key (optional): Azure application insights API key. If not set it will be read from the configuration (see README.md)
  ```
  """
  @spec track_trace(
          String.t(),
          severity_level :: severity_level,
          properties :: properties,
          tags :: tags,
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_trace(
        message,
        severity_level \\ :info,
        properties \\ %{},
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    Payload.create_trace_payload(message, severity_level, properties, tags)
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
  instrumentation_key (optional): Azure application insights API key. If not set it will be read from the configuration (see README.md)
  ```
  """
  @spec track_exception(
          String.t(),
          stack_trace :: stack_trace,
          String.t() | nil,
          properties :: properties,
          measurements :: measurements,
          tags :: tags,
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_exception(
        exception,
        stack_trace,
        handle_at \\ nil,
        properties \\ %{},
        measurements \\ %{},
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    Payload.create_exception_payload(
      exception,
      stack_trace,
      handle_at,
      properties,
      measurements,
      tags
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
  instrumentation_key (optional): Azure application insights API key. If not set it will be read from the configuration (see README.md)
  ```
  """
  @spec track_metric(
          name :: name,
          number,
          properties :: properties,
          tags :: tags,
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_metric(name, value, properties \\ %{}, tags \\ %{}, instrumentation_key \\ nil)
      when is_binary(name) do
    Payload.create_metric_payload(name, value, properties, tags)
    |> track(instrumentation_key)
  end

  @doc ~S"""
  Log a dependency, for example requests to an external service or SQL calls.

  ### Parameters:

  ```
  name: String that identifies the dependency.
  command_name: String of the name of the command made against the dependency (eg. full URL with querystring or SQL command text).
  start_time: The datetime when the dependency call was initiated.
  elapsed_time_ms: Number for elapsed time in milliseconds of the command made against the dependency.
  success: Boolean which indicates success.
  dependency_type_name: String which denotes dependency type. Defaults to nil.
  target: String of the target host of the dependency.
  properties (optional): map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  id (optional): a unique identifier representing the dependency call.
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will be read from the configuration (see README.md)
  ```
  """

  @spec track_dependency(
          name :: name,
          String.t(),
          DateTime.t(),
          number,
          boolean,
          String.t(),
          String.t() | nil,
          properties :: properties,
          id :: String.t() | nil,
          tags :: tags,
          instrumentation_key :: instrumentation_key
        ) :: :ok
  def track_dependency(
        name,
        command_name,
        start_time,
        elapsed_time_ms,
        success,
        dependency_type_name \\ "",
        target \\ nil,
        properties \\ %{},
        id \\ nil,
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    id = if id == nil, do: Base.encode16(<<:rand.uniform(438_964_124)::size(32)>>), else: id

    Payload.create_dependency_payload(
      name,
      command_name,
      start_time,
      elapsed_time_ms,
      success,
      dependency_type_name,
      target,
      properties,
      tags,
      id
    )
    |> track(instrumentation_key)
  end

  @doc ~S"""
  Log a request, for example incoming HTTP requests

  ### Parameters:

  ```
  name: String that identifies the request
  url: Request URL
  source: Request Source. Encapsulates info about the component that initiated the request (can be nil)
  start_time: The datetime when the request was initiated.
  elapsed_time_ms: Number for elapsed time in milliseconds
  result_code: Result code reported by the application
  success: whether the request was successfull
  properties (optional): map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  measurements (optional): a map of [string -> number] values associated with this event that can be aggregated/sumed/etc. on the UI
  id (optional): a unique identifier representing the request.
  tags (optional): map[string, string] - additional application insights tag metadata.
  instrumentation_key (optional): Azure application insights API key. If not set it will be read from the configuration (see README.md)
  ```
  """
  @spec track_request(
          name :: name,
          url :: String.t(),
          source :: String.t() | nil,
          start_time :: DateTime.t(),
          elapsed_time_ms :: number,
          result_code :: String.t() | number,
          success :: boolean,
          properties :: properties,
          measurements :: measurements,
          id :: String.t() | nil,
          tags :: tags,
          instrumentation_key :: instrumentation_key
        ) ::
          :ok
  def track_request(
        name,
        url,
        source,
        start_time,
        elapsed_time_ms,
        result_code,
        success,
        properties \\ %{},
        measurements \\ %{},
        id \\ nil,
        tags \\ %{},
        instrumentation_key \\ nil
      ) do
    id = if id == nil, do: Base.encode16(<<:rand.uniform(438_964_124)::size(32)>>), else: id

    Payload.create_request_payload(
      name,
      url,
      source,
      start_time,
      elapsed_time_ms,
      result_code,
      success,
      properties,
      measurements,
      tags,
      id
    )
    |> track(instrumentation_key)
  end

  @spec track(map, instrumentation_key()) :: :ok
  defp track(%Envelope{} = payload, instrumentation_key) do
    key = read_instrumentation_key(instrumentation_key)

    payload
    |> Envelope.set_instrumentation_key(key)
    |> Envelope.ensure_instrumentation_key_present()
    |> ExInsights.Aggregation.Worker.track()

    :ok
  end

  def read_instrumentation_key(key) when is_binary(key) and byte_size(key) > 0, do: key
  def read_instrumentation_key(_), do: Conf.get_value(:instrumentation_key)
end
