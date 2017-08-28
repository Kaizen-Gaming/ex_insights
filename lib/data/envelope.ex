defmodule ExInsights.Data.Envelope do
  @moduledoc """
  Envelope data looks like this

  {
		"time": "2017-08-24T08:55:56.968Z",
		"iKey": "some-guid-value-key",
		"name": "Microsoft.ApplicationInsights.someguidvaluekey.Event",
		"tags": {
			"ai.session.id": "SLzGH",
			"ai.device.id": "browser",
			"ai.device.type": "Browser",
			"ai.internal.sdkVersion": "javascript:1.0.11",
			"ai.user.id": "V2Yph",
			"ai.operation.id": "VKgP+",
			"ai.operation.name": "/"
		},
		"data": {
			"baseType": "EventData",
			"baseData": {
				"ver": 2,
				"name": "button clicked",
				"properties": {
					"click type": "double click"
				},
				"measurements": {
					"clicks": 2
				}
			}
		}
	}

  """

  @data_version 2
  @app_version Mix.Project.config[:version]

  @doc """
  Creates a new envelope for sending a single tracked item to app insights. Intended for internal use only.
  """

  def create(_, _, _, key, _) when key in [nil, ""], do: raise("""
  Azure app insights instrumentation key not set!
  1) First get your key as described in the docs https://docs.microsoft.com/en-us/azure/application-insights/app-insights-cloudservices
  2) Then set it either
    a) during application execution using Application.put_env(:ex_insights, :instrumentation_key, "0000-1111-2222-3333"), OR
    b) in your config.exs file using either the vanilla or {:system, "key"} syntax. Examples:

      config :ex_insights,
        instrumentation_key: "00000-11111-2222-33333"

      OR

      config :ex_insights,
        instrumentation_key: {:system, "INSTRUMENTATION_KEY"}

      When using the {system, key} syntax make sure that the env variable is defined on system startup, ie to start your app you should do
      INSTRUMENTATION_KEY=0000-1111-2222-333 iex -S mix
  """)

  def create(%{} = data, type, %DateTime{} = time, instrumentation_key, %{} = tags)
  when is_binary(instrumentation_key) and is_binary(type)
  do
    %{
      time: DateTime.to_iso8601(time),
      iKey: instrumentation_key,
      name: "Microsoft.ApplicationInsights.#{String.replace(instrumentation_key, "-", "")}.#{type}",
      tags: tags,
      data: %{
        baseType: "#{type}Data",
        baseData: Map.put(data, :ver, @data_version)
      }
    }
  end

  @doc """
  Provides common tags for all track requests. Intended for internal use only.
  """
  def get_tags() do
    %{
      "ai.internal.sdkVersion": "elixir:#{@app_version}"
    }
  end

end
