defmodule ExInsights.UtilsTest do
  use ExUnit.Case, async: true
  doctest ExInsights.Utils

  import ExInsights.Utils

  #Ported from https://github.com/Microsoft/ApplicationInsights-node.js/blob/68e217e6c6646114d8df0952437590724070204f/Tests/Library/Util.tests.ts#L141

  describe "msToTimeSpan" do
    test  "zero" do
      assert "00:00:00.000" == ms_to_timespan(0)
    end

    test  "milliseconds digit 1" do
      assert "00:00:00.001" == ms_to_timespan(1)
    end

    test  "milliseconds digit 2" do
      assert "00:00:00.010" == ms_to_timespan(10)
    end

    test  "milliseconds digit 3" do
      assert "00:00:00.100" == ms_to_timespan(100)
    end

    test  "seconds digit 1" do
      assert "00:00:01.000" == ms_to_timespan(1 * 1000)
    end

    test  "seconds digit 2" do
      assert "00:00:10.000" == ms_to_timespan(10 * 1000)
    end

    test  "minutes digit 1" do
      assert "00:01:00.000" == ms_to_timespan(1 * 60 * 1000)
    end

    test  "minutes digit 2" do
      assert "00:10:00.000" == ms_to_timespan(10 * 60 * 1000)
    end

    test  "hours digit 1" do
      assert "01:00:00.000" == ms_to_timespan(1 * 60 * 60 * 1000)
    end

    test  "hours digit 2" do
      assert "10:00:00.000" == ms_to_timespan(10 * 60 * 60 * 1000)
    end

    test  "hours overflow" do
      assert "1.00:00:00.000" == ms_to_timespan(24 * 60 * 60 * 1000)
    end

    test  "all digits" do
      assert "11:11:11.111" == ms_to_timespan(11 * 3600000 + 11 * 60000 + 11111)
    end

    test  "all digits with days" do
      assert "5.13:09:08.789" == ms_to_timespan(5 * 86400000 + 13 * 3600000 + 9 * 60000 + 8 * 1000 + 789)
    end

    test  "fractional milliseconds" do
      assert "00:00:01.001505" == ms_to_timespan(1001.505)
    end

    test  "fractional milliseconds - not all precision 1" do
      assert "00:00:01.0015" == ms_to_timespan(1001.5)
    end

    test  "fractional milliseconds - not all precision 2" do
      assert "00:00:01.00155" == ms_to_timespan(1001.55)
    end

    test  "fractional milliseconds - all digits" do
      assert "00:00:01.0015059" == ms_to_timespan(1001.5059)
    end

    test  "fractional milliseconds - too many digits, round up" do
      assert "00:00:01.0015056" == ms_to_timespan(1001.50559)
    end
  end

  describe "convert" do
    test "severity level - verbose" do
      assert 0 == convert(:verbose)
    end

    test "severity level - warning" do
      assert 2 == convert(:warning)
    end

    test "severity level - error" do
      assert 3 == convert(:error)
    end

    test "severity level - critical" do
      assert 4 == convert(:critical)
    end

    test "severity level - default" do
      assert 1 == convert(:wrong)
    end
  end

  describe "stacktrace" do
    test "empty list" do
      assert stacktrace?([]) == true
    end

    test "actual stack_trace" do
      {:current_stacktrace, trace} = Process.info(self(), :current_stacktrace)
      assert stacktrace?(trace) == true
    end

    test "list but not stacktrace" do
      not_a_trace = [{:module, :function, :arity, "location"} | 5]
      assert stacktrace?(not_a_trace) == false
    end

    test "other objects" do
      assert stacktrace?(%{}) == false
      assert stacktrace?("not a trace") == false
    end
  end

end
