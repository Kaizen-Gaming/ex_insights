defmodule ExInsights.Configuration do
  @moduledoc """
  Internal module for reading configuration values
  """

  @app_name Mix.Project.config[:app]

  @doc """
  Reads configuration related to the ex_insights app.
  
  Provides support for `{:system, "VAR_NAME"}` configuration.
  Intended for internal use.
  """
  @spec get_value(atom) :: any
  def get_value(key) do
     Application.get_env(@app_name, key)
     |> return_value()
  end

  defp return_value({:system, key}) when is_binary(key) do
    System.get_env(key)
  end

  defp return_value(val), do: val

end
