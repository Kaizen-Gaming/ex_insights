defmodule ExInsights do
  @moduledoc """
  Exposes methods for POSTing events & metrics to Azure Application Insights.
  For more information on initialization and usage consult the [README.md](/readme.html)
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

  @doc ~S"""
  Log a user action or other occurrence.

  ### Parameters:

  ```
  name: name of the event (string)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  measurements (optional): a map of [string -> number] values associated with this event that can be aggregated/sumed/etc. on the UI
  ```
  """
  @spec track_event(String.t, properties, measurements) :: :ok
  def track_event(name, properties \\ %{}, measurements \\ %{})
  when is_binary(name)
  do
    Payload.create_event_payload(name, properties, measurements)
    |> track()
  end

  @doc ~S"""
  Log a numeric value that is not associated with a specific event.

  Typically used to send regular reports of performance indicators.

  ### Parameters

  ```
  name: name of the metric
  value: the value of the metric (number)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  ```
  """
  @spec track_metric(String.t, number, properties) :: :ok
  def track_metric(name, value, properties \\ %{})
  when is_binary(name)
  do
    Payload.create_metric_payload(name, value, properties)
    |> track()
  end

  @doc ~S"""
  Log a dependency, for example requests to an external service or SQL calls.

  ### Parameters

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

  @spec track_dependency(String.t, String.t, number, boolean, String.t, String.t, properties) :: :ok
  def track_dependency(name, command_name, elapsed_time_ms, success, dependency_type_name \\ "", target \\ nil, properties \\ %{}) do
    Payload.create_dependency_payload(name, command_name, elapsed_time_ms, success, dependency_type_name, target, properties)
    |> track()
  end

  defp track(payload) do
    ExInsights.Aggregation.Worker.track(payload)
    :ok
  end

end
