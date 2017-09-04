defmodule ExInsights.Aggregation.WorkerTest do
  
  use ExUnit.Case #no async here!

  @client ExInsights.Client.TestClient

  setup_all do
    app_name = Mix.Project.config[:app]
    #substitute real http client for mock
    Application.put_env(app_name, :client_module, ExInsights.Client.TestClient)
    Application.put_env(app_name, :flush_interval_secs, 2)
    @client.start()
    :ok
  end

  setup do
    @client.clear_listeners()
    @client.subscribe()
    :ok
  end

  test "flushing when no messages does not send data to azure" do
    ExInsights.Aggregation.Worker.flush()
    refute_receive {:items_sent, []}
  end

  test "flushing with messages sends data properly" do
    ExInsights.track_event("hello")
    ExInsights.Aggregation.Worker.flush()
    assert_receive {:items_sent, [_]}
  end

  test "flushing at regular intervals works" do
    ExInsights.track_event("hello1")
    assert_receive {:items_sent, [_]}, 2100
    ExInsights.track_event("hello2")
    assert_receive {:items_sent, [_]}, 2100
  end

end