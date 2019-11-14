defmodule ExInsights.Decoration.AttributesTest do
  # no async here!
  use ExUnit.Case
  require ExInsights.TestHelper

  ExInsights.TestHelper.setup_test_client()

  test "event is captured" do
    defmodule EventTest do
      use ExInsights.Decoration.Attributes

      @decorate track_event()
      def hello(arg) do
        arg
      end
    end

    EventTest.hello(4)
    ExInsights.Aggregation.Worker.flush()
    assert_receive {:items_sent, [_]}, 1000
  end

  describe "dependency tracking" do
    test "happy path" do
      defmodule Hello do
        use ExInsights.Decoration.Attributes
        @decorate track_dependency("greetings")
        def hello(who), do: {:hey, who}
      end

      Hello.hello("John")
      ExInsights.Aggregation.Worker.flush()
      assert_receive {:items_sent, [item]}, 1000

      assert %{
               data: %{
                 baseData: %{
                   name: "ExInsights.Decoration.AttributesTest.Hello.hello",
                   success: true
                 }
               }
             } = item
    end

    test "happy path with error" do
      defmodule Exam do
        use ExInsights.Decoration.Attributes
        @decorate track_dependency("botches")
        def pass(), do: {:error, :not_even_close}
      end

      Exam.pass()
      ExInsights.Aggregation.Worker.flush()
      assert_receive {:items_sent, [item]}, 1000
      assert %{data: %{baseData: %{success: false}}} = item
    end

    test "raise & rescue" do
      defmodule Raisor do
        use ExInsights.Decoration.Attributes
        @decorate track_dependency("raises")
        def raise(), do: raise("raise and shine")
      end

      assert_raise RuntimeError, &Raisor.raise/0
      ExInsights.Aggregation.Worker.flush()
      assert_receive {:items_sent, [item]}, 1000

      assert %{
               data: %{
                 baseData: %{
                   name: "ExInsights.Decoration.AttributesTest.Raisor.raise",
                   success: false
                 }
               }
             } = item
    end

    test "exit" do
      Process.flag(:trap_exit, true)

      defmodule Quitter do
        use ExInsights.Decoration.Attributes
        @decorate track_dependency("quits")
        def quit() do
          ExInsights.TestHelper.create_raising_genserver()
          {:ok, pid} = TestServer.start()
          TestServer.raise_me(pid)
        end
      end

      Quitter.quit()
      assert_receive {:EXIT, _from, _reason}, 1000
      Process.flag(:trap_exit, false)

      ExInsights.Aggregation.Worker.flush()
      assert_receive {:items_sent, [item]}, 1000

      assert %{
               data: %{
                 baseData: %{
                   name: "ExInsights.Decoration.AttributesTest.Quitter.quit",
                   success: false
                 }
               }
             } = item
    end
  end

  describe "track exception" do
    test "raising mfa" do
      defmodule Honey do
        use ExInsights.Decoration.Attributes
        @decorate track_exception()
        def anyone_home?(), do: raise("git gone")
      end

      assert_raise RuntimeError, &Honey.anyone_home?/0
      ExInsights.Aggregation.Worker.flush()
      assert_receive {:items_sent, [item]}, 10000

      assert %{data: %{baseData: %{exceptions: [%{message: "git gone", parsedStack: _stack}]}}} =
               item
    end

    test "process exit" do
      defmodule Splitter do
        use ExInsights.Decoration.Attributes
        @decorate track_exception()
        def split() do
          ExInsights.TestHelper.create_raising_genserver()
          {:ok, pid} = TestServer.start()
          TestServer.raise_me(pid)
        end
      end

      Process.flag(:trap_exit, true)
      Splitter.split()
      assert_receive {:EXIT, _from, _reason}, 1000
      Process.flag(:trap_exit, false)

      ExInsights.Aggregation.Worker.flush()
      assert_receive {:items_sent, [item]}, 1000
      assert %{data: %{baseData: %{exceptions: [%{message: msg, parsedStack: _stack}]}}} = item
      assert msg =~ "error babe @ GenServer.call"
    end
  end
end
