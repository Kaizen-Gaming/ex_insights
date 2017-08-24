defmodule ExInsights do
  @moduledoc """
  Exposes methods for POSTing events & metrics to Azure Application Insights
  """

  @doc """
  Tracks a custom event.
  name: name of the event (string)
  properties (optional): a map of string -> string pairs for adding extra properties to this event
  measurements (optional): a map of string -> number values associated with this event that can be aggregated/sumed/etc. on the ui
  """

  alias ExInsights.Data.Envelope
  alias ExInsights.Configuration, as: Conf

  def track_event(name, properties \\ %{}, measurements \\ %{}) do
    create_event_payload(name, properties, measurements)
    |> track()
  end

  defp track(envelope) do

  end

  @doc """
  Create custom event payload. For internal use only
  """
  def create_event_payload(name, properties, measurements) do
    %{
      name: name,
      properties: properties,
      measurements: measurements
    }
    |> create_payload("Event")
  end

  defp create_payload(data, type) do
    data
    |> Envelope.create(type, DateTime.utc_now(), Conf.get_value(:instrumentation_key), Envelope.get_tags())
  end




end
