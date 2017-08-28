defmodule ExInsights.Aggregation.Worker do
  @moduledoc """
  A named genserver responsible for batching telemetry requests. Fires up a separate process every 30s to
  upload the data to azure
  """
  use GenServer

  @name __MODULE__
  @flush_interval_millis 60_000

  def start_link(_) do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_) do
    schedule_next_flush()
    {:ok, []}
  end

  def track(%{} = request) do
    GenServer.cast(@name, {:add, request})
  end

  def handle_cast({:add, request}, state) do
    {:noreply, [request | state]}
  end

  def handle_info(:flush, []) do
    schedule_next_flush()
    {:noreply, []}
  end

  def handle_info(:flush, state) do
    spawn(fn ->
      IO.puts "uploading..."
      send_to_azure(state)
    end)
    schedule_next_flush()
    {:noreply, []}
  end

  defp schedule_next_flush do
    Process.send_after(@name, :flush, @flush_interval_millis)
  end

  defp send_to_azure(requests) do
    requests
    |> ExInsights.Client.track()
    |> IO.inspect(label: "azure response")
  end

end
