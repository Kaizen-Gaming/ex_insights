defmodule ExInsights.Test.Client.TestClient do
  @moduledoc """
    Test client module that implements the `ExInsights.Client.ClientBehaviour`

    Implemented as a `GenServer` to add reporting for test purposes
  """

  @name __MODULE__

  use GenServer
  alias ExInsights.Client.ClientBehaviour
  @behaviour ClientBehaviour

  def start() do
    GenServer.start(@name, [], name: @name)
  end

  @impl GenServer
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl ClientBehaviour
  def track(items) do
    GenServer.call(@name, {:track, items})
  end

  def subscribe do
    # poor man's event handler
    GenServer.call(@name, {:add_listener, self()})
  end

  def clear_listeners do
    GenServer.call(@name, :clear_listeners)
  end

  @impl GenServer
  def handle_call({:track, items}, _from, listeners) do
    for listener <- listeners do
      send(listener, {:items_sent, items})
    end

    {:reply, :ok, listeners}
  end

  @impl GenServer
  def handle_call({:add_listener, pid}, _from, listeners) do
    {:reply, :ok, [pid | listeners]}
  end

  @impl GenServer
  def handle_call(:clear_listeners, _from, _) do
    {:reply, :ok, []}
  end
end
