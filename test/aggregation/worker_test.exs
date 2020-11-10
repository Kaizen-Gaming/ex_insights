defmodule ExInsights.WorkerTest do
  # no async here!
  use ExUnit.Case
  require ExInsights.TestHelper

  ExInsights.TestHelper.setup_test_client()

  test "flushing when no messages does not send data to azure" do
    ExInsights.Worker.flush()
    refute_receive {:items_sent, []}, 1000
  end

  test "flushing with messages sends data properly" do
    ExInsights.track_event("hello")
    ExInsights.Worker.flush()
    assert_receive {:items_sent, [_]}, 1000
  end

  test "flushing at regular intervals works" do
    ExInsights.track_event("hello1")
    assert_receive {:items_sent, [_]}, 5000
    ExInsights.track_event("hello2")
    assert_receive {:items_sent, [_]}, 5000
  end
end
