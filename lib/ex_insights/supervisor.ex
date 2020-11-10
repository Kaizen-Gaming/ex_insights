defmodule ExInsights.Supervisor do
  @moduledoc """
  Starts the `ExInsights.Worker` for uploading telemetry to Azure
  """

  use Supervisor
  alias ExInsights.Worker

  @name __MODULE__

  @spec start_link([Worker.option()]) :: Supervisor.on_start()
  def start_link(options) do
    Supervisor.start_link(@name, options, name: @name)
  end

  def init(options) do
    Supervisor.init(
      [
        {Worker, options}
      ],
      strategy: :one_for_one
    )
  end
end
