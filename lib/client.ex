defmodule ExInsights.Client do
  @moduledoc """
  Responsible for actually sending track requests (HTTP POSTs) to azure app insights. Intended for internal use only.
  """

  @service_url "https://dc.services.visualstudio.com/v2/track"

  @doc """
  POSTs track requests to azure app insights. Internal use only.
  """
  @spec track([map]) :: {:error, any} | {:ok, any}
  def track([]), do: {:error, :no_items}
  def track(items) when is_list(items) do
    payload = Poison.encode_to_iodata!(items)
    HTTPoison.post(@service_url, payload, [content_type: "application/json"])
  end
end
