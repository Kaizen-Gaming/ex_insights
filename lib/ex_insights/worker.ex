defmodule ExInsights.Worker do
  @moduledoc """
  A named genserver responsible for batching telemetry requests. Fires up a separate process every 30secs (configurable) to
  upload the data to azure
  """
  use GenServer
  alias ExInsights.Envelope

  @type option ::
          {:instrumentation_key, ExInsights.Telemetry.Types.instrumentation_key()}
          | {:flush_interval_secs, non_neg_integer()}
          | {:client_module, atom()}

  defstruct [
    :timer,
    :instrumentation_key,
    :flush_interval_secs,
    :client_module,
    items: []
  ]

  @spec start_link([option()]) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def init(options) do
    flush_interval_secs = Keyword.get(options, :flush_interval_secs, 30)

    state = %__MODULE__{
      # used for mocking as suggested by The Man himself @ http://blog.plataformatec.com.br/2015/10/mocks-and-explicit-contracts/
      client_module: Keyword.get(options, :client_module, ExInsights.Client.HttpClient),
      flush_interval_secs: flush_interval_secs,
      timer: schedule_next_flush(flush_interval_secs),
      instrumentation_key: Keyword.get(options, :instrumentation_key)
    }

    {:ok, state}
  end

  @doc false
  def track(%Envelope{} = request) do
    GenServer.cast(__MODULE__, {:add, request})
  end

  @doc """
  Sends any pending messages to azure.

  Required for Elixir.Logger hookup
  """
  def flush do
    GenServer.call(__MODULE__, :force_flush)
  end

  def handle_call(:force_flush, _from, %{timer: timer} = state) do
    Process.cancel_timer(timer)
    send(self(), :flush)
    {:reply, :ok, state}
  end

  def handle_cast({:add, request}, %{items: items} = state) do
    request = ensure_proper_envelope(request, state)
    {:noreply, %{state | items: [request | items]}}
  end

  def handle_info(:flush, %{items: items, client_module: client} = state) do
    spawn(fn ->
      # IO.puts "uploading..."
      send_to_azure(items, client)
    end)

    timer = schedule_next_flush(state.flush_interval_secs)
    {:noreply, %{state | timer: timer, items: []}}
  end

  def terminate(_reason, %{items: items, client_module: client}) do
    # synchronously send remaining data to azure
    send_to_azure(items, client)
    :ok
  end

  defp schedule_next_flush(secs) do
    Process.send_after(self(), :flush, secs * 1000)
  end

  defp send_to_azure([], _), do: :ok

  defp send_to_azure(requests, client) do
    client.track(requests)
  end

  defp ensure_proper_envelope(envelope, state) do
    # ensure_proper_envelope does the minimal work required to check for instrumentation_key
    # because otherwise we run the risk of overloading this gen_server if doing too much work
    # inside the server's process loop

    with {:missing?, true} <- {:missing?, !Envelope.instrumentation_key_set?(envelope)},
         {:default_exists?, true} <- {:default_exists?, is_binary(state.instrumentation_key)} do
      Envelope.set_instrumentation_key(envelope, state.instrumentation_key)
    else
      {:misssing?, false} -> envelope
      {:default_exists?, false} -> raise_error(state.instrumentation_key)
    end
  end

  defp raise_error(key) do
    raise("""
    Azure app insights instrumentation key not set (value was: #{key})!
    1) First get your key as described in the docs https://docs.microsoft.com/en-us/azure/azure-monitor/app/cloudservices#create-an-application-insights-resource-for-each-role
    2) Then set it either
      a) during initialization of the `ExInsights.Supervisor` (see README.MD) OR
      b) as a paremeter along with each request, ie: ExInsights.track_event(..., instrumentation_key)
    """)
  end
end
