defmodule ExInsights.Decoration.Attributes do
  @moduledoc """
  Injects decorator functions into parent module to streamline telemetry logging in aspect-oriented style
  """

  use Decorator.Define,
    track_event: 0,
    track_dependency: 1,
    track_exception: 0

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

      start = DateTime.utc_now()

      try do
        result = unquote(body)
        finish = DateTime.utc_now()
        # success = true
        success = ExInsights.Decoration.Attributes.success?(result)

        ExInsights.Decoration.Attributes.do_track_dependency(
          start,
          finish,
          module,
          name,
          args,
          type,
          success
        )

        result
      rescue
        e ->
          finish = DateTime.utc_now()
          trace = System.stacktrace()

          ExInsights.Decoration.Attributes.do_track_dependency(
            start,
            finish,
            module,
            name,
            args,
            type,
            false
          )

          reraise(e, trace)
      catch
        :exit, reason ->
          finish = DateTime.utc_now()

          ExInsights.Decoration.Attributes.do_track_dependency(
            start,
            finish,
            module,
            name,
            args,
            type,
            false
          )

          :erlang.exit(self(), reason)
      end
    end
  end

  def success?({:error, _}), do: false
  def success?(_), do: true

  def do_track_dependency(start, finish, module, name, args, type, success) do
    diff_ms = DateTime.diff(finish, start, :millisecond)

    "#{inspect(module)}.#{name}"
    |> ExInsights.track_dependency(inspect(args), start, diff_ms, success, type)
  end

  def track_exception(body, _context) do
    quote do
      try do
        unquote(body)
      rescue
        e ->
          trace = System.stacktrace()
          ExInsights.track_exception(e, trace)
          reraise(e, trace)
      catch
        # see format_exit https://github.com/elixir-lang/elixir/blob/master/lib/elixir/lib/exception.ex#L364

        :exit, {{%{} = exception, maybe_stacktrace}, {m, f, a}} = reason ->
          msg = "#{Exception.message(exception)} @ #{Exception.format_mfa(m, f, a)}}"

          trace =
            case ExInsights.Utils.stacktrace?(maybe_stacktrace) do
              true -> maybe_stacktrace
              false -> []
            end

          ExInsights.track_exception(msg, trace)
          :erlang.exit(self(), reason)

        :exit, reason ->
          msg = inspect(reason)
          ExInsights.track_exception(msg, [])
          :erlang.exit(self(), reason)
      end
    end
  end
end
