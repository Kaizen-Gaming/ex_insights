ExUnit.start(exclude: [:skip], colors: [enabled: true])

alias ExInsights.TestHelper
Application.put_env(:ex_insights, :instrumentation_key, TestHelper.get_test_key())
