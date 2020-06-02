defmodule ExInsightsTest do
  use ExUnit.Case, async: true
  doctest ExInsights

  alias ExInsights.Data.{Envelope, Payload}
  alias ExInsights.TestHelper

  describe "envelope properly created" do
    test "event" do
      envelope = Payload.create_event_payload("button clicked", %{}, %{}, %{"ai.operation.id": "foo_id"})
      assert %{
        "ai.operation.id": "foo_id",
        "ai.internal.sdkVersion": _,
      } = envelope.tags
      assert_envelope_basics("Event", envelope)
    end

    test "trace" do
      envelope = Payload.create_trace_payload("traced", :info, %{}, %{"ai.operation.id": "foo_id"})
      assert %{
        "ai.operation.id": "foo_id",
        "ai.internal.sdkVersion": _,
      } = envelope.tags
      assert envelope.data.baseData.message == "traced"
      assert envelope.data.baseData.properties == %{}
      assert envelope.data.baseData.severityLevel == 1
      assert_envelope_basics("Message", envelope)
    end

    test "metric" do
      envelope = Payload.create_metric_payload("zombies killed", 4, %{}, %{"ai.operation.id": "foo_id"})
      assert %{
        "ai.operation.id": "foo_id",
        "ai.internal.sdkVersion": _,
      } = envelope.tags
      assert [%{name: "zombies killed", value: 4, kind: 0}] = envelope.data.baseData.metrics
      assert_envelope_basics("Metric", envelope)
    end

    test "dependency" do
      envelope =
        Payload.create_dependency_payload(
          "get_user_balance",
          "http://my.api/get_balance/rfostini",
          DateTime.utc_now(),
          1500,
          true,
          "user",
          "my.api",
          %{},
          %{"ai.operation.id": "foo_id"},
          "random_id"
        )

      assert %{
               name: "get_user_balance",
               data: "http://my.api/get_balance/rfostini",
               duration: "00:00:01.500",
               success: true,
               type: "user",
               target: "my.api",
               id: "random_id"
             } = envelope.data.baseData
        assert %{
        "ai.operation.id": "foo_id",
        "ai.internal.sdkVersion": _,
      } = envelope.tags
      assert_envelope_basics("RemoteDependency", envelope)
    end

    test "request" do
      envelope =
        Payload.create_request_payload(
          "homepage",
          "http://my.site/",
          "homeModule",
          DateTime.utc_now(),
          140,
          200,
          true,
          %{},
          %{foo: 2},
          %{"ai.operation.id": "foo_id"},
          "random_id"
        )

      assert %{
               name: "homepage",
               url: "http://my.site/",
               duration: "00:00:00.140",
               success: true,
               responseCode: 200,
               id: "random_id"
             } = envelope.data.baseData

      assert %{
        "ai.operation.id": "foo_id",
        "ai.internal.sdkVersion": _,
      } = envelope.tags

      assert_envelope_basics("Request", envelope)
      assert %{foo: 2} = envelope.data.baseData.measurements
    end
  end

  describe "json test with js sdk" do
    test "trace" do
      json = File.read!("test/assets/track_trace.json") |> Poison.decode!()
      envelope = Payload.create_trace_payload("this is a test", :critical, %{"foo" => "bar"}, %{})
      assert envelope.data.baseData.message == json["data"]["baseData"]["message"]
      assert envelope.data.baseData.properties == json["data"]["baseData"]["properties"]
      assert envelope.data.baseData.severityLevel == json["data"]["baseData"]["severityLevel"]
    end

    test "exception" do
      json = File.read!("test/assets/track_exception.json") |> Poison.decode!()
      exception = %{__exception__: true, __struct__: Error, message: "error"}

      stack_trace = [
        {:erl_internal, :op_type, [:get_stacktrace, 0], [file: "erl_internal.erl", line: 201]},
        {:elixir_utils, :guard_op, 2, [file: "src/elixir_utils.erl", line: 29]}
      ]

      envelope =
        Payload.create_exception_payload(exception, stack_trace, "handle", %{"foo" => "bar"}, %{
          "world" => 1
        }, %{
          "ai.operation.id": "foo_id",
        })

      assert %{
        "ai.operation.id": "foo_id",
        "ai.internal.sdkVersion": _,
      } = envelope.tags
      assert envelope.data.baseData.handledAt == json["data"]["baseData"]["handledAt"]
      [%{parsedStack: parsed_stack}] = envelope.data.baseData.exceptions
      assert [level_0 = %{level: 0}, %{level: 1}] = parsed_stack
      assert level_0.method == ":erl_internal.op_type(:get_stacktrace, 0)"
      assert level_0.assembly == "stdlib"
      assert level_0.fileName == "erl_internal.erl"
      assert envelope.data.baseData.properties == json["data"]["baseData"]["properties"]
      assert envelope.data.baseData.measurements == json["data"]["baseData"]["measurements"]
    end
  end

  defp assert_envelope_basics(kind, envelope) do
    envelope = normalize_envelope(envelope)
    assert envelope.data.baseType == "#{kind}Data"
    assert envelope.name |> String.ends_with?(kind)
    assert envelope.data.baseData.ver == 2
    assert envelope.time != nil
    assert envelope.iKey == ExInsights.TestHelper.get_test_key()
  end

  def normalize_envelope(envelope) do
    envelope
    |> Envelope.set_instrumentation_key(TestHelper.get_test_key())
  end
end
