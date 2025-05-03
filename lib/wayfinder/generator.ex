defmodule Wayfinder.Generator do
  @moduledoc false
  require Logger

  alias Wayfinder.{Routes, Options, Error}
  alias Wayfinder.Processor.Route
  alias Wayfinder.Typescript.{BuildController, FileWriter}

  @spec call(Routes.t(), Options.t()) :: :ok | {:error, Error.t()}
  def call(routes, _opts) do
    grouped = group_by_controller(routes)

    Enum.reduce_while(grouped, :ok, fn {controller, routes}, :ok ->
      ts_code = BuildController.generate(controller, routes)
      relative_path = FileWriter.controller_path(controller)

      case FileWriter.write(relative_path, ts_code) do
        :ok -> {:cont, :ok}
        {:error, error} -> {:halt, {:error, error}}
      end
    end)
  end

  @spec group_by_controller(Routes.t()) :: %{module() => [Route.t()]}
  defp group_by_controller(%Routes{actions: actions}) do
    Enum.group_by(actions, & &1.controller)
  end
end
