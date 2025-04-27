defmodule Wayfinder.Generator do
  @moduledoc false

  alias Wayfinder.{Error, FileWriter, Options, Processor}
  alias Wayfinder.Typescript.BuildController

  @spec call([Processor.controller()], Options.t()) :: :ok | {:error, Error.t()}
  def call(controllers, opts) do
    case FileWriter.prepare(opts) do
      :ok ->
        Enum.reduce_while(controllers, :ok, fn controller, :ok ->
          paths = FileWriter.build_paths(controller, opts)
          ts_code = BuildController.call(controller, paths.imports_line)

          case FileWriter.write(paths.controller_path, ts_code) do
            :ok -> {:cont, :ok}
            {:error, error} -> {:halt, {:error, error}}
          end
        end)

      {:error, error} ->
        {:error, error}
    end
  end
end
