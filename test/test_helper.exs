ExUnit.start(exclude: [:skip])

defmodule ExInsights.TestHelper do
  use ExUnit.Case

  @app_name  Mix.Project.config[:app]

  def get_test_key, do: "0000-1111-22222-3333"

  def get_app_name, do: @app_name

  defmacro setup_test_client do
    quote do
      @client ExInsights.Client.TestClient
      setup_all do
        import ExInsights.TestHelper
        #substitute real http client for mock
        Application.put_env(get_app_name(), :client_module, @client)
        Application.put_env((get_app_name()), :flush_interval_secs, 1)
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

alias ExInsights.TestHelper
Application.put_env(TestHelper.get_app_name, :instrumentation_key, TestHelper.get_test_key)