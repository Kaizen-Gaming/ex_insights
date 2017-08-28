defmodule ExInsights.Aggregation.Supervisor do
  @moduledoc false

  use Supervisor

  @name __MODULE__
  @worker ExInsights.Aggregation.Worker

  def start_link(_) do
    Supervisor.start_link(@name, [], name: @name)
  end

  def init(_) do
    Supervisor.init([
      @worker
    ], strategy: :one_for_one)
  end

end
