defmodule ExInsights.TestHelper do
  def get_test_key, do: "0000-1111-22222-3333"

  def to_envelope(telemetry), do: ExInsights.Envelope.wrap(telemetry, get_test_key())

  defmacro setup_test_client do
    quote do
      @client ExInsights.Test.Client.TestClient
      setup_all do
        import ExInsights.TestHelper

        {:ok, pid} =
          ExInsights.Aggregation.Worker.start_link(
            flush_interval_secs: 1,
            client_module: @client,
            instrumentation_key: get_test_key()
          )

        @client.start()
        :ok
      end

      setup do
        @client.clear_listeners()
        @client.subscribe()
        :ok
      end

      @client
    end
  end

  defmacro create_raising_genserver do
    quote do
      defmodule TestServer do
        use GenServer

        def init(init_arg) do
          {:ok, init_arg}
        end

        def start do
          GenServer.start(__MODULE__, [])
        end

        def raise_me(pid) do
          GenServer.call(pid, :raise)
        end

        def handle_call(:raise, _, _) do
          raise "error babe"
        end
      end
    end
  end
end
