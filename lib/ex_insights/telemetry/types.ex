defmodule ExInsights.Telemetry.Types do
  @moduledoc """
  A module for declaring typespecs used throughout the ex_insights lib
  """

  @typedoc """
  Measurement name. Will be used extensively in the app insights UI
  """
  @type name :: String.t() | atom

  @typedoc """
  Additional data used to filter events and metrics in the portal
  """
  @type properties :: %{optional(name) => String.t()}

  @typedoc """
  Additional context tags to use for this telemetry
  """
  @type tags :: %{optional(name) => String.t()}

  @typedoc """
  Metrics associated with this telemetry, displayed in Metrics Explorer on the portal.
  """
  @type measurements :: %{optional(name) => number()}

  @typedoc """
  AppInsights portal resource key. Read more on how to create one [here](https://docs.microsoft.com/en-us/azure/azure-monitor/app/create-new-resource)
  """
  @type instrumentation_key :: String.t()

  @typedoc """
  Defines the level of severity for the trace.
  """
  @type severity_level :: :verbose | :info | :warning | :error | :critical
end
