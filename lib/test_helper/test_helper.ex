defmodule ExInsights.TestHelper do
  def get_test_key, do: "0000-1111-22222-3333"

  defmacro setup_test_client do
    quote do
      @client ExInsights.Client.TestClient
      setup_all do
        import ExInsights.TestHelper
        #substitute real http client for mock
        Application.put_env(:ex_insights, :client_module, @client)
        Application.put_env(:ex_insights, :flush_interval_secs, 1)
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