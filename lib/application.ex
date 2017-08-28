defmodule ExInsights.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias ExInsights.Configuration

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      ExInsights.Aggregation.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExInsights.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
