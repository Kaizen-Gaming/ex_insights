defmodule ExInsights.Client.ClientBehaviour do
  @moduledoc """
  Defines mathods to be implemented by app insights clients.

  Used as a common interface for actual and test clients
  """

  @doc """
  Invoked to send telemetry data to azure
  """
  @callback track(list(map)) :: {:error, any} | {:ok, any}
end
