defmodule ExInsights.Aggregation.Worker do

  @flush_interval_secs 30

  @moduledoc """
  A named genserver responsible for batching telemetry requests. Fires up a separate process every #{@flush_interval_secs}s to
  upload the data to azure
  """
  use GenServer

  @name __MODULE__

  @doc false
  def start_link(_) do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_) do
    schedule_next_flush()
    {:ok, []}
  end

  @doc false
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
      #IO.puts "uploading..."
      send_to_azure(state)
    end)
    schedule_next_flush()
    {:noreply, []}
  end

  def terminate(_reason, state) do
    #synchronously send remaining data to azure
    send_to_azure(state)
    :ok
  end

  defp schedule_next_flush do
    Process.send_after(self(), :flush, @flush_interval_secs * 1000)
  end

  defp send_to_azure(requests) do
    requests
    |> ExInsights.Client.track()
    #|> IO.inspect(label: "azure response")
  end

end
