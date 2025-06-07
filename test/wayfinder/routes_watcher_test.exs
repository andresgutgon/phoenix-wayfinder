defmodule Wayfinder.RoutesWatcherTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  alias Wayfinder.RoutesWatcher

  @router_module TestRouter

  setup do
    # Configure the router for tests
    Application.put_env(:wayfinder, :router, @router_module)

    on_exit(fn ->
      Application.delete_env(:wayfinder, :router)

      if Process.whereis(RoutesWatcher) do
        GenServer.stop(RoutesWatcher, :normal, 1000)
      end
    end)

    :ok
  end

  describe "child_spec/1" do
    test "returns correct child specification" do
      opts = [some: :option]
      spec = RoutesWatcher.child_spec(opts)

      assert spec.id == RoutesWatcher
      assert spec.start == {RoutesWatcher, :start_link, [opts]}
      assert spec.type == :worker
      assert spec.restart == :permanent
      assert spec.shutdown == 500
    end
  end

  describe "start_link/1" do
    test "starts the GenServer successfully" do
      assert {:ok, pid} = RoutesWatcher.start_link()
      assert Process.alive?(pid)
      assert Process.whereis(RoutesWatcher) == pid

      GenServer.stop(pid)
    end

    test "accepts GenServer options" do
      opts = [debug: [:trace]]
      assert {:ok, pid} = RoutesWatcher.start_link(opts)
      assert Process.alive?(pid)

      GenServer.stop(pid)
    end
  end

  describe "file event handling" do
    setup do
      # Start the watcher for these tests
      {:ok, pid} = RoutesWatcher.start_link()
      %{watcher_pid: pid}
    end

    test "ignores non-router file modifications", %{watcher_pid: watcher_pid} do
      non_router_path = "/path/to/controller.ex"
      events = [:modified]

      log =
        capture_log(fn ->
          send(watcher_pid, {:file_event, :mock_watcher, {non_router_path, events}})
          # Ensure the GenServer has processed the message by calling it
          # This will block until all queued messages are processed
          GenServer.call(watcher_pid, :ping, 1000)
        end)

      refute log =~ "Router file changed"
    end

    test "ignores router file events that are not modifications", %{watcher_pid: watcher_pid} do
      router_path = "/path/to/router.ex"
      events = [:created, :deleted]

      log =
        capture_log(fn ->
          send(watcher_pid, {:file_event, :mock_watcher, {router_path, events}})
          GenServer.call(watcher_pid, :ping, 1000)
        end)

      refute log =~ "Router file changed"
    end

    test "handles stop events gracefully", %{watcher_pid: watcher_pid} do
      # This should not crash the process
      send(watcher_pid, {:file_event, :mock_watcher, :stop})
      GenServer.call(watcher_pid, :ping, 1000)
      assert Process.alive?(watcher_pid)
    end

    test "handles unknown events gracefully", %{watcher_pid: watcher_pid} do
      # This should not crash the process
      send(watcher_pid, {:unknown_event, :some_data})
      GenServer.call(watcher_pid, :ping, 1000)
      assert Process.alive?(watcher_pid)
    end
  end

  describe "router module configuration" do
    test "handles missing router configuration gracefully" do
      Application.delete_env(:wayfinder, :router)

      # We can't easily test the exact error since it crashes the GenServer process
      # but we can test that the watcher starts without the config being set
      router_path = "/path/to/router.ex"
      events = [:modified]

      {:ok, pid} = RoutesWatcher.start_link()

      # The error will be logged but not crash the test
      log =
        capture_log(fn ->
          send(pid, {:file_event, :mock_watcher, {router_path, events}})
          GenServer.call(pid, :ping, 1000)
        end)

      assert log =~ "Router file changed: #{router_path}"

      GenServer.stop(pid)
    end
  end

  describe "file path detection" do
    setup do
      {:ok, pid} = RoutesWatcher.start_link()
      %{watcher_pid: pid}
    end

    test "correctly identifies router.ex files", %{watcher_pid: watcher_pid} do
      # Test with various router file paths - only files named exactly "router.ex"
      router_paths = [
        "/app/lib/app_web/router.ex",
        "/some/deep/path/router.ex",
        "router.ex"
      ]

      for router_path <- router_paths do
        log =
          capture_log(fn ->
            send(watcher_pid, {:file_event, :mock_watcher, {router_path, [:modified]}})
            GenServer.call(watcher_pid, :ping, 1000)
          end)

        assert log =~ "Router file changed: #{router_path}"
      end
    end

    test "ignores files that don't match router.ex pattern", %{watcher_pid: watcher_pid} do
      non_router_paths = [
        "/app/lib/app_web/router_helper.ex",
        "/app/lib/app_web/my_router.ex",
        "/app/lib/app_web/admin_router.ex",
        "/app/lib/app_web/controller.ex",
        "/app/lib/app_web/view.ex"
      ]

      for path <- non_router_paths do
        log =
          capture_log(fn ->
            send(watcher_pid, {:file_event, :mock_watcher, {path, [:modified]}})
            GenServer.call(watcher_pid, :ping, 1000)
          end)

        refute log =~ "Router file changed"
      end
    end
  end
end
