ExUnit.start()

defmodule ExInsights.TestHelper do
  def get_test_key, do: "0000-1111-22222-3333"
end

app_name = Mix.Project.config[:app]
Application.put_env(app_name, :instrumentation_key, ExInsights.TestHelper.get_test_key)
