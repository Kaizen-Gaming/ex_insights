ExUnit.start(exclude: [:skip])

alias ExInsights.TestHelper
Application.put_env(TestHelper.get_app_name, :instrumentation_key, TestHelper.get_test_key)