defmodule Wayfinder.RoutesWatcher do
  use GenServer
  require Logger

  @moduledoc """
  A GenServer that watches for changes to router files and regenerates routes.

  Credit to:
  https://github.com/assimelha/routes/blob/master/lib/routes/watcher.ex

  This module provides functionality to:
  - Watch for file system changes in the current working directory
  - Detect modifications to router.ex files
  - Automatically regenerate routes when router files change
  """

  @doc """
  Child spec for supervision tree.
  """
  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: :permanent,
      shutdown: 500
    }
  end

  @doc """
  Starts the watcher process.

  ## Options

  * `:generator_module` - Module to use for route generation (defaults to Wayfinder)
  * `:compiler_fun` - Function to call when compiling router files (optional)

  Accepts GenServer options. The process will be registered under the module name.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Initializes the watcher by starting a FileSystem process and subscribing to events.
  """
  def init(opts) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: [File.cwd!()])
    FileSystem.subscribe(watcher_pid)

    state = %{
      watcher_pid: watcher_pid,
      generator_module: Keyword.get(opts, :generator_module, Wayfinder),
      compiler_fun:
        Keyword.get(opts, :compiler_fun, fn router_path ->
          Code.compile_file(router_path)
        end)
    }

    {:ok, state}
  end

  @doc """
  Handles file system events, specifically looking for router.ex file modifications.
  """
  def handle_info({:file_event, _watcher_pid, {path, events}}, state) when is_list(events) do
    if router_file_modified?(path, events) do
      regenerate_routes(path, state)
    end

    {:noreply, state}
  end

  def handle_info({:file_event, _watcher_pid, :stop}, state), do: {:noreply, state}
  def handle_info(_event, state), do: {:noreply, state}

  @doc """
  Handles synchronous calls. Used for testing to ensure message processing is complete.
  """
  def handle_call(:ping, _from, state), do: {:reply, :pong, state}

  defp regenerate_routes(path, %{compiler_fun: compiler_fun, generator_module: generator_module}) do
    case compile_router(path, compiler_fun) do
      :ok ->
        router = Application.get_env(:wayfinder, :router)
        otp_app = Application.get_env(:wayfinder, :otp_app)

        case generator_module.generate(router, otp_app) do
          :ok -> Logger.info("[wayfinder] routes re-generated")
          {:error, reason} -> Logger.error("[wayfinder-error]: #{inspect(reason)}")
        end

      {:error, error} ->
        Logger.error("Router compilation failed: #{inspect(error)}")
    end
  end

  defp router_file_modified?(path, events) do
    Path.basename(path) == "router.ex" and Enum.any?(events, &(&1 == :modified))
  end

  def compile_router(router_path, compiler_fun) when is_function(compiler_fun, 1) do
    compiler_fun.(router_path)
    :ok
  rescue
    e ->
      {:error, e}
  end
end
