defmodule ExInsightsTest do
  use ExUnit.Case, async: true
  doctest ExInsights

  import ExInsights

  test "event envelope properly created" do
    envelope = create_event_payload("button clicked", %{}, %{})
    assert envelope.data.baseType == "EventData"
    assert envelope.name |> String.ends_with?("Event")
    assert_envelope_basics(envelope)
  end

  defp assert_envelope_basics(envelope) do
    assert envelope.data.baseData.ver == 2
    assert envelope.time != nil
    assert envelope.iKey ==  ExInsights.TestHelper.get_test_key
  end
end
