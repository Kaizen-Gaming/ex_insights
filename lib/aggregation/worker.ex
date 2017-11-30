defmodule ExInsights.Aggregation.Worker do

  @moduledoc """
  A named genserver responsible for batching telemetry requests. Fires up a separate process every 30secs (configurable) to
  upload the data to azure
  """
  use GenServer

  @name __MODULE__

  alias ExInsights.Configuration

  @doc false
  def start_link(_) do
    GenServer.start_link(@name, [], name: @name)
  end

  def init(_) do
    timer = schedule_next_flush()
    {:ok, {timer, []}}
  end

  @doc false
  def track(%{} = request) do
    GenServer.cast(@name, {:add, request})
  end

  @doc """
  Sends any pending messages to azure.

  Required for Elixir.Logger hookup
  """
  def flush do
    GenServer.call(@name, :force_flush)
  end

  def handle_call(:force_flush, _from, {timer, _} = state) do
    Process.cancel_timer(timer)
    send(self(), :flush)
    {:reply, :ok, state}
  end

  def handle_cast({:add, request}, {timer, items}) do
    {:noreply, {timer, [request | items]}}
  end

  def handle_info(:flush, {_, items}) do
    spawn(fn ->
      #IO.puts "uploading..."
      send_to_azure(items)
    end)
    timer = schedule_next_flush()
    {:noreply, {timer, []}}
  end

  def terminate(_reason, {_, items}) do
    #synchronously send remaining data to azure
    send_to_azure(items)
    :ok
  end

  defp schedule_next_flush do
    flush_interval =
      Configuration.get_value(:flush_interval_secs, 30)
      |> to_integer()
    Process.send_after(self(), :flush, flush_interval * 1000)
  end

  defp send_to_azure([]), do: :ok

  defp send_to_azure(requests) do
    client = get_client_module()
    requests
    |> client.track()
    #|> IO.inspect(label: "azure response")
  end

  defp get_client_module do
    # used for mocking as suggested by The Man himself @ http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/
    Configuration.get_value(:client_module, ExInsights.Client.HttpClient)
  end

  defp to_integer(""), do: 30
  defp to_integer(string) when is_binary(string), do: String.to_integer(string)
  defp to_integer(number) when is_integer(number), do: number

end
