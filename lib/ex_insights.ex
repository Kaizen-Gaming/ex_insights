defmodule ExInsights do
  @moduledoc """
  Exposes methods for POSTing events & metrics to Azure Application Insights
  """

  alias ExInsights.Data.Payload

  @doc """
  Tracks a custom event.
  name: name of the event (string)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  measurements (optional): a map of [string -> number] values associated with this event that can be aggregated/sumed/etc. on the ui
  """
  def track_event(name, properties \\ %{}, measurements \\ %{}) do
    Payload.create_event_payload(name, properties, measurements)
    |> track()
  end

  @doc """
  Log a numeric value that is not associated with a specific event. Typically used to send regular reports of performance indicators.
  name: name of the metric (string)
  value: the value of the metric (number)
  properties (optional): a map of [string -> string] pairs for adding extra properties to this event
  """
  def track_metric(name, value, properties \\ %{}) do
    Payload.create_metric_payload(name, value, properties)
    |> track()
  end

  defp track(payload) do
    ExInsights.Aggregation.Worker.track(payload)
  end

end
