defmodule ExInsights do
  @moduledoc """
  Exposes methods for POST events & metrics to Azure Application Insights.
  For more information on initialization and usage consult the [README.md](readme.html)
  """

  alias ExInsights.Data.Payload

  @typedoc """
  Measurement name. Will be used extensively in the app insights UI
  """
  @type name :: String.t | atom

  @typedoc ~S"""
  A map of `[name -> string]` to add metadata to a tracking request
  """
  @type properties :: %{optional(name) => String.t}

  @typedoc ~S"""
  A map of `[name -> string]` to add measurement data to a tracking request
  """
  @type measurements ::  %{optional(name) => number}

  @typedoc ~S"""
  Defines the level of severity for the event.
  """
  @type severity_level :: :verbose | :info | :warning | :error | :critical

  @typedoc ~S"""
  Represents the exception's stack trace.
  """
  @type stack_trace :: [stack_trace_entry]
  @type stack_trace_entry ::
        {module, atom, arity_or_args, location} |
        {(... -> any), arity_or_args, location}

  @typep arity_or_args :: non_neg_integer | list
  @typep location :: keyword

  @doc ~S"""
  Log a user action or other occurrence.

  ### Parameters:

  ```
  name: name of the event (string)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  measurements (optional): a map of [string -> number] values associated with this event that can be aggregated/sumed/etc. on the UI
  ```
  """
  @spec track_event(name :: name, properties :: properties, measurements :: measurements) :: :ok
  def track_event(name, properties \\ %{}, measurements \\ %{})
  when is_binary(name)
  do
    Payload.create_event_payload(name, properties, measurements)
    |> track()
  end

  @doc ~S"""
  Log a trace message.

  ### Parameters:

  ```
  message: A string to identify this event in the portal.
  severity_level: The level of severity for the event.
  properties: map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  ```
  """
  @spec track_trace(String.t, severity_level :: severity_level, properties :: properties) :: :ok
  def track_trace(message, severity_level \\ :info, properties \\ %{}) do
    Payload.create_trace_payload(message, severity_level, properties)
    |> track()
  end


  @doc ~S"""
  Log an exception you have caught.

  ### Parameters:

  ```
  exception: An Error from a catch clause, or the string error message.
  stack_trace: An erlang stacktrace.
  properties: map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  measurements: map[string, number] - metrics associated with this event, displayed in Metrics Explorer on the portal. Defaults to empty.
  ```
  """
  @spec track_exception(String.t, stack_trace :: stack_trace, String.t | nil, properties :: properties, measurements :: measurements) :: :ok
  def track_exception(exception, stack_trace, handle_at \\ nil, properties \\ %{}, measurements \\ %{}) do
    Payload.create_exception_payload(exception, stack_trace, handle_at, properties, measurements)
    |> track()
  end

  @doc ~S"""
  Log a numeric value that is not associated with a specific event.

  Typically used to send regular reports of performance indicators.

  ### Parameters:

  ```
  name: name of the metric
  value: the value of the metric (number)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  ```
  """
  @spec track_metric(name :: name, number, properties :: properties) :: :ok
  def track_metric(name, value, properties \\ %{})
  when is_binary(name)
  do
    Payload.create_metric_payload(name, value, properties)
    |> track()
  end

  @doc ~S"""
  Log a dependency, for example requests to an external service or SQL calls.

  ### Parameters:

  ```
  name: String that identifies the dependency.
  command_name: String of the name of the command made against the dependency (eg. full URL with querystring or SQL command text).
  elapsed_time_ms: Number for elapsed time in milliseconds of the command made against the dependency.
  success: Boolean which indicates success.
  dependency_type_name: String which denotes dependency type. Defaults to nil.
  target: String of the target host of the dependency.
  properties (optional): map[string, string] - additional data used to filter events and metrics in the portal. Defaults to empty.
  ```
  """

  @spec track_dependency(name :: name, String.t, number, boolean, String.t, String.t | nil, properties :: properties) :: :ok
  def track_dependency(name, command_name, elapsed_time_ms, success, dependency_type_name \\ "", target \\ nil, properties \\ %{}) do
    Payload.create_dependency_payload(name, command_name, elapsed_time_ms, success, dependency_type_name, target, properties)
    |> track()
  end


  @doc ~S"""
  Log a request, for example incoming HTTP requests

  ### Parameters:

  ```
  name: String that identifies the request
  url: Request URL
  source: Request Source. Encapsultes info about the component that initiated the request
   elapsed_time_ms: Number for elapsed time in milliseconds
   resultCode: Result code reported by the application
   success: whetever the request was successfull. by default check for 2xx result codes
  ```
  """
  @spec track_request(name :: name, String.t, String.t, number, String.t | number, boolean) :: :ok
  def track_request(name, url, source \\ nil, elapsed_time_ms, resultCode, success \\ nil) do
    Payload.create_request_payload(name, url, source, elapsed_time_ms, resultCode, success)
    |> track
  end

  @spec track(map) :: :ok
  defp track(payload) do
    ExInsights.Aggregation.Worker.track(payload)
    :ok
  end

end
