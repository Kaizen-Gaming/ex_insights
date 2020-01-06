ExUnit.start(exclude: [:skip])

alias ExInsights.TestHelper
Application.put_env(:ex_insights, :instrumentation_key, TestHelper.get_test_key())
