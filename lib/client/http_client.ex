defmodule ExInsights.Client.HttpClient do
  @moduledoc """
  Responsible for actually sending track requests (HTTP POSTs) to azure app insights. Intended for internal use only.
  """

  @behaviour ExInsights.Client.ClientBehaviour
  
  #@service_url "https://dc.services.visualstudio.com/v2/track"
  
  @doc """
  POSTs track requests to azure app insights. Internal use only.
  """
  @impl true
  @spec track([map]) :: {:error, map} | {:ok, map}
  def track(items) when is_list(items) do
    payload = Poison.encode_to_iodata!(items)
    [service_url: service_url] = :ets.lookup(:ex_insights, :service_url)
    HTTPoison.post(service_url, payload, %{"Content-Type" => "application/json"})
  end
end