defmodule ExInsights.Decoration.Attributes do
  @moduledoc """
  Injects decorator functions into parent module to streamline telemetry logging in aspect-oriented style
  """

  use Decorator.Define,
    track_event: 0,
    track_dependency: 1

  def track_event(body, %{name: name}) do
    quote do
      unquote(name)
        |> to_string()
        |> ExInsights.track_event()
      unquote(body)
    end
  end

  def track_dependency(type, body, %{module: module, name: name, args: args}) do
    quote do
      module = unquote(module)
      name = unquote(name)
      args = unquote(args)
      type = unquote(type)
      start = :os.timestamp
      try do

        result = unquote(body)
        finish = :os.timestamp()
        # success = true
        success = ExInsights.Decoration.Attributes.success?(result)
        ExInsights.Decoration.Attributes.do_track_dependency(start, finish, module, name, args, type, success)
        result

      rescue

        e ->
          finish = :os.timestamp()
          trace = System.stacktrace
          ExInsights.Decoration.Attributes.do_track_dependency(start, finish, module, name, args, type, false)
          reraise(e, trace)

      catch

        :exit, reason -> 
          finish = :os.timestamp()
          ExInsights.Decoration.Attributes.do_track_dependency(start, finish, module, name, args, type, false)
          :erlang.exit(self(), reason)

      end
    end
  end

  def success?({:error, _}), do: false
  def success?(_), do: true

  def do_track_dependency(start, finish, module, name, args, type, success) do
    diff = ExInsights.Utils.diff_timestamp_millis(start, finish)
    "#{inspect(module)}.#{name}"
    |> ExInsights.track_dependency(inspect(args), diff, success, type)
  end

end