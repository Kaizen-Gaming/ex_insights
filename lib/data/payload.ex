defmodule ExInsights.Data.Payload do
  @moduledoc """
  Central point for creating data objects. Intended for internal use.
  """

  alias ExInsights.Data.Envelope
  alias ExInsights.Utils

  @doc """
  Create custom dependency payload.
  """
  def create_dependency_payload(
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
      ) do
    %{
      name: name,
      id: id,
      data: command_name,
      target: target,
      duration: Utils.ms_to_timespan(elapsed_time_ms),
      success: success,
      type: dependency_type_name,
      properties: properties
    }
    |> create_payload("RemoteDependency", tags, start_time)
  end

  @doc """
  Create request payload
  """
  def create_request_payload(
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
    |> create_payload("Request", tags, start_time)
  end

  @spec(
    create_payload(
      data :: map(),
      type :: String.t(),
      tags :: map()
    ) :: Envelope.t(),
    start_time :: DateTime | nil
  )
  defp create_payload(data, type, tags, start_time \\ nil) do
    data
    |> Envelope.create(
      type,
      start_time || DateTime.utc_now(),
      Map.merge(Envelope.get_tags(), tags)
    )
  end
end
