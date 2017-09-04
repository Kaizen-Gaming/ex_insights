defmodule ExInsights.Client.TestClient do
  @moduledoc """
    Test client module that implements the `ExInsights.Client.ClientBehaviour`

    Implemented as a `GenServer` to add reporting for test purposes
  """

  @name __MODULE__

  use GenServer
  @behaviour ExInsights.Client.ClientBehaviour

  def start() do
    GenServer.start(@name, [], name: @name)
  end

  def track(items) do
    GenServer.call(@name, {:track, items})
  end

  def subscribe do
    #poor man's event handler
    GenServer.call(@name, {:add_listener, self()})
  end

  def clear_listeners do
    GenServer.call(@name, :clear_listeners)
  end

  def handle_call({:track, items}, _from, listeners) do
    for listener <- listeners do
      send(listener, {:items_sent, items})
    end
    {:reply, :ok, listeners}
  end

  def handle_call({:add_listener, pid}, _from, listeners) do
    {:reply, :ok, [pid | listeners]}
  end

  def handle_call(:clear_listeners, _from, _) do
    {:reply, :ok, []}
  end

end