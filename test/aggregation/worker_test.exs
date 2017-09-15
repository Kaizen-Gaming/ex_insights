defmodule ExInsights.Aggregation.WorkerTest do
  
  use ExUnit.Case #no async here!
  require ExInsights.TestHelper

  ExInsights.TestHelper.setup_test_client()

  test "flushing when no messages does not send data to azure" do
    ExInsights.Aggregation.Worker.flush()
    refute_receive {:items_sent, []}, 1000
  end

  test "flushing with messages sends data properly" do
    ExInsights.track_event("hello")
    ExInsights.Aggregation.Worker.flush()
    assert_receive {:items_sent, [_]}, 1000
  end

  test "flushing at regular intervals works" do
    ExInsights.track_event("hello1")
    assert_receive {:items_sent, [_]}, 5000
    ExInsights.track_event("hello2")
    assert_receive {:items_sent, [_]}, 5000
  end

end