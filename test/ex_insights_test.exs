defmodule ExInsightsTest do
  use ExUnit.Case, async: true
  doctest ExInsights

  alias ExInsights.Data.Payload

  test "event envelope properly created" do
    envelope = Payload.create_event_payload("button clicked", %{}, %{})
    assert_envelope_basics("Event", envelope)
  end

  test "metric envelope properly created" do
    envelope = Payload.create_metric_payload("zombies killed", 4, %{})
    assert [%{name: "zombies killed", value: 4, kind: 0}] = envelope.data.baseData.metrics
    assert_envelope_basics("Metric", envelope)
  end

  defp assert_envelope_basics(kind, envelope) do
    assert envelope.data.baseType == "#{kind}Data"
    assert envelope.name |> String.ends_with?(kind)
    assert envelope.data.baseData.ver == 2
    assert envelope.time != nil
    assert envelope.iKey ==  ExInsights.TestHelper.get_test_key
  end
end
