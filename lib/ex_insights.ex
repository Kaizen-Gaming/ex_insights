defmodule ExInsights do
  @moduledoc """
  Exposes methods for POSTing events & metrics to Azure Application Insights
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
  @spec track_event(name, properties, measurements) :: :ok
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
  @spec track_metric(name, number, properties) :: :ok
  def track_metric(name, value, properties \\ %{}) do
    Payload.create_metric_payload(name, value, properties)
    |> track()
  end

  defp track(payload) do
    ExInsights.Aggregation.Worker.track(payload)
    :ok
  end

end
