defmodule ExInsights.Configuration do
  @moduledoc """
  Internal module for reading configuration values
  """

  @doc """
  Reads configuration related to the ex_insights app.
  
  Provides support for `{:system, "VAR_NAME"}` configuration.
  Intended for internal use.
  """
  @spec get_value(atom, default :: term) :: any
  def get_value(key, default \\ nil) do
     Application.get_env(:ex_insights, key, default)
     |> return_value()
  end

  defp return_value({:system, key}) when is_binary(key) do
    System.get_env(key)
  end

  defp return_value(val), do: val

end
