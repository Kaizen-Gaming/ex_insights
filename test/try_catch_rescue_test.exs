defmodule TryCatchRescueTest do
  use ExUnit.Case, async: true

  require ExInsights.TestHelper

  setup do
    Process.flag(:trap_exit, false)
    :ok
  end

  @tag :skip
  test "rescue test" do

    try do
      fun = fn x -> x <> "boom" end
      fun.(1)
    rescue
      e -> IO.inspect e
    catch
      # will not get here unless rescue (above) is commented out
      _a, b -> # a will be = :error
        IO.inspect b, label: "b"
    end

    #IO.puts (System.stacktrace |> Exception.format_stacktrace)
    IO.inspect Process.info(self(), :current_stacktrace)
  end

  @tag :skip
  test "catch call test" do
    ExInsights.TestHelper.create_raising_genserver()
    {:ok, pid} = TestServer.start

    try do
      TestServer.raise_me(pid)
    catch
      e, z -> 
        IO.puts "e is: #{inspect(e)}"
        IO.puts "z is: #{inspect(z)}"
    end

  end

  @tag :skip
  test "process exit" do
    # process.exit/0 cannot be caught
    try do
      exit :blah
    rescue
      e -> IO.inspect(e, label: "process rescue")
    catch
      :exit, e -> IO.inspect(e, label: "process exit")
    end

  end

  @tag :skip
  test "reraising an exit works as expected" do
    Process.flag(:trap_exit, true)
    ExInsights.TestHelper.create_raising_genserver()
    try do
      {:ok, pid} = TestServer.start
      TestServer.raise_me(pid)
    catch
      :exit, reason ->
        :erlang.exit(self(), reason)
    end
    assert_receive {:EXIT, _from, _reason}, 1000
  end
end