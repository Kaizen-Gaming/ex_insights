defmodule ExInsights.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    children = [
      ExInsights.Aggregation.Supervisor
    ]

    opts = [strategy: :one_for_one, name: ExInsights.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
