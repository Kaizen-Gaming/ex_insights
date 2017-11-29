defmodule ExInsights.Application do
  @moduledoc false
  use Application

  alias ExInsights.Configuration

  @service_url "https://dc.services.visualstudio.com/v2/track"

  def start(_type, _args) do
    service_url = Configuration.get_value(:service_url, @service_url)
    :ets.new(:ex_insights, [:set, :public, :named_table, 
      {:write_concurrency, true}, {:read_concurrency, true}])
    :ets.insert(:ex_insights, {:service_url, service_url})
    children = [
      ExInsights.Aggregation.Supervisor
    ]
    opts = [strategy: :one_for_one, name: ExInsights.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
