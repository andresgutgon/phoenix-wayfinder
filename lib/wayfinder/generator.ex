defmodule Wayfinder.Generator do
  @moduledoc false

  alias Wayfinder.{Routes, Options, Error}
  alias Wayfinder.Processor.Route
  alias Wayfinder.Typescript.{BuildController, FileWriter}

  @spec call(Routes.t(), Options.t()) :: :ok | {:error, Error.t()}
  def call(routes, opts) do
    grouped =
      Enum.group_by(routes.actions, fn %Route{controller: controller, action: action} ->
        {controller, action}
      end)

    with :ok <- FileWriter.clean_actions_dir(opts),
         :ok <- FileWriter.copy_typescript_helper(opts) do
      Enum.reduce_while(grouped, :ok, fn group, :ok ->
        paths = FileWriter.build_paths(group.controller, opts)
        ts_code = BuildController.call(group, paths.imports_line)

        case FileWriter.write(paths.controller_path, ts_code) do
          :ok -> {:cont, :ok}
          {:error, error} -> {:halt, {:error, error}}
        end
      end)
    else
      {:error, error} ->
        {:error, error}
    end
  end
end
