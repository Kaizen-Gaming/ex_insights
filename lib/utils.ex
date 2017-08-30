defmodule ExInsights.Utils do
  @moduledoc false

  #Convert ms to c# time span format. Ported from https://github.com/Microsoft/ApplicationInsights-node.js/blob/68e217e6c6646114d8df0952437590724070204f/Library/Util.ts#L122
  def ms_to_timespan(number) when not is_number(number), do: ms_to_timespan(0)

  def ms_to_timespan(number) when number < 0, do: ms_to_timespan(0)

  def ms_to_timespan(number) do
    sec =
      (number / 1000)
      |> mod(60)
      |> to_fixed(7)
      |> String.replace(~r/0{0,4}$/, "")
    sec = if index_of(sec, ".") < 2 do
      "0" <> sec
    else
      sec
    end

    min =
      (number /(1000 * 60))
      |> Float.floor()
      |> round
      |> mod(60)
      |> to_string()
    min = if String.length(min) < 2 do
      "0" <> min
    else
      min
    end

    hour =
      (number /(1000 * 60 * 60))
      |> Float.floor()
      |> round
      |> mod(24)
      |> to_string()
    hour = if String.length(hour) < 2 do
      "0" <> hour
    else
      hour
    end
    
    days =
      (number /(1000 * 60 * 60 * 24))
      |> Float.floor()
      |> round
      |> case do
        x when x > 0 -> to_string(x) <> "."
        _ -> ""
      end

      "#{days}#{hour}:#{min}:#{sec}"
  end

  defp to_fixed(number, decimals) when is_integer(number), do: to_fixed(number / 1, decimals)

  defp to_fixed(number, decimals), do: :erlang.float_to_binary(number, decimals: decimals)

  defp index_of(str, pattern), do: :binary.match(str, pattern) |> elem(0)

  defp mod(a, b) when is_integer(a), do: rem(a, b)

  defp mod(a, b) do
    a_floor = a |> Float.floor() |> round()
    rem(a_floor, b) + (a - a_floor)
  end
end
