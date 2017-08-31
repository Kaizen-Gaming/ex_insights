defmodule ExInsightsTest do
  use ExUnit.Case, async: true
  doctest ExInsights

  alias ExInsights.Data.Payload

  describe "envelope properly created" do
    test "event" do
      envelope = Payload.create_event_payload("button clicked", %{}, %{})
      assert_envelope_basics("Event", envelope)
    end

    test "trace" do
      envelope = Payload.create_trace_payload("traced", :info, %{})
      assert %{data: %{baseData: %{message: "traced", properties: %{}, severity_level: 1}}} = envelope
      assert_envelope_basics("Message", envelope)
    end

    test "metric" do
      envelope = Payload.create_metric_payload("zombies killed", 4, %{})
      assert [%{name: "zombies killed", value: 4, kind: 0}] = envelope.data.baseData.metrics
      assert_envelope_basics("Metric", envelope)
    end

    test "dependency" do
      envelope = Payload.create_dependency_payload("get_user_balance", "http://my.api/get_balance/rfostini", 1500, true, "user", "my.api", %{})
      assert %{name: "get_user_balance", data: "http://my.api/get_balance/rfostini", duration: "00:00:01.500", success: true, type: "user", target: "my.api"} = envelope.data.baseData
      assert_envelope_basics("RemoteDependency", envelope)
    end
  end

  defp assert_envelope_basics(kind, envelope) do
    assert envelope.data.baseType == "#{kind}Data"
    assert envelope.name |> String.ends_with?(kind)
    assert envelope.data.baseData.ver == 2
    assert envelope.time != nil
    assert envelope.iKey ==  ExInsights.TestHelper.get_test_key
  end
end
