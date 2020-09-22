defmodule ExInsights.Telemetry.ExceptionTelemetry do
  @moduledoc """
  Telemetry about the exception thrown by the application
  """

  # see the following resources for details
  # https://github.com/microsoft/ApplicationInsights-node.js/blob/2855952b7348b407f370bef4a10af006425f6508/Library/EnvelopeFactory.ts#L157
  # https://github.com/microsoft/ApplicationInsights-node.js/blob/50dec0941d5e73de6b7ffe081f66ab739bd62876/Declarations/Contracts/Generated/ExceptionDetails.ts

  alias ExInsights.Telemetry.{Types, CommonTelemetry}
  alias ExInsights.Utils

  @type inner_stack_entry() :: %{
          level: integer(),
          method: String.t(),
          assembly: String.t(),
          fileName: charlist(),
          line: integer()
        }

  @type inner_exception() :: %{
          typeName: Types.name(),
          message: String.t(),
          hasFullStack: boolean(),
          parsedStack: [inner_stack_entry()]
        }

  @type t() :: %__MODULE__{
          handledAt: String.t(),
          exceptions: [inner_exception()],
          severityLevel: Types.severity_level(),
          measurements: Types.measurements(),
          common: CommonTelemetry.t()
        }

  @type option ::
          {:stack_trace, Exception.stacktrace()}
          | {:handled_at, String.t()}
          | {:measurements, Types.measurements()}
          | CommonTelemetry.option()

  @enforce_keys [:exceptions, :handledAt, :severityLevel]
  defstruct [
    :handledAt,
    :exceptions,
    :severityLevel,
    :measurements,
    :common
  ]

  @spec new(Exception.t() | String.t(), [option()]) :: t()
  def new(exception, options \\ [])

  def new(%{__exception__: true, __struct__: type_name, message: message}, options) do
    type_name
    |> to_string()
    |> new(message, options)
  end

  def new(message, options) when is_binary(message) do
    new("Thrown", message, options)
  end

  defp new(type_name, message, options) do
    stack_trace = Keyword.get(options, :stack_trace)
    proper_stack_trace? = Utils.stacktrace?(stack_trace)
    stack_trace_to_use = if proper_stack_trace?, do: stack_trace, else: []

    %__MODULE__{
      handledAt: Keyword.get(options, :handled_at, "unhandled"),
      exceptions: [
        %{
          typeName: type_name,
          message: message,
          hasFullStack: proper_stack_trace?,
          parsedStack: Utils.parse_stack_trace(stack_trace_to_use)
        }
      ],
      severityLevel: Utils.convert(:error),
      measurements: Keyword.get(options, :measurements, %{}),
      common: CommonTelemetry.new("Exception", options)
    }
  end
end
