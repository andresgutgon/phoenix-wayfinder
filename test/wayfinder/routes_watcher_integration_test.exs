defmodule Wayfinder.RoutesWatcherIntegrationTest do
  use ExUnit.Case, async: false

  alias Wayfinder.RoutesWatcher

  describe "integration tests" do
    test "can start and stop the watcher" do
      Application.put_env(:wayfinder, :router, TestRouter)

      assert {:ok, pid} = RoutesWatcher.start_link()
      assert Process.alive?(pid)
      assert Process.whereis(RoutesWatcher) == pid

      assert :ok = GenServer.stop(pid)
      refute Process.alive?(pid)

      Application.delete_env(:wayfinder, :router)
    end

    test "child spec is suitable for supervision" do
      spec = RoutesWatcher.child_spec([])

      assert is_map(spec)
      assert spec.id == RoutesWatcher
      assert spec.type == :worker
      assert spec.restart == :permanent
    end
  end
end
