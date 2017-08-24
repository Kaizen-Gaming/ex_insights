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

  defstruct [
    :time,
    :iKey,
    :name,
    :tags,
    :data
  ]

  @doc """
  Creates a new envelope for sending a single tracked item to app insights. Intended for internal use only.
  """
  def create(%{} = data, type, %DateTime{} = time, instrumentation_key, %{} = tags)
  when is_binary(instrumentation_key) and is_binary(type)
  do
    %__MODULE__{
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
