defmodule ExInsights.Data.Payload do
  @moduledoc """
  Central point for creating data objects. Intended for internal use.
  """

  alias ExInsights.Data.Envelope
  alias ExInsights.Configuration, as: Conf

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
  Create custom metric payload
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

  defp create_payload(data, type) do
    data
    |> Envelope.create(type, DateTime.utc_now(), Conf.get_value(:instrumentation_key), Envelope.get_tags())
  end
end
