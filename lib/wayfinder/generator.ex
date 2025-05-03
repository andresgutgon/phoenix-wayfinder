defmodule Wayfinder.Generator do
  @moduledoc false
  require Logger

  @dialyzer {:nowarn_function, call: 2}

  alias Wayfinder.{Collections, Options, Error}
  alias Wayfinder.Processor.Route
  alias Wayfinder.Typescript.BuildController

  @spec call(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  def call(collections, opts) do
    with :ok <- generate_actions(collections, opts) do
      :ok
    else
      {:error, error} -> {:error, error}
    end
  end

  @spec generate_actions(Collections.t(), Options.t()) :: :ok | {:error, Error.t()}
  defp generate_actions(collection, _opts) do
    grouped = group_by_controller(collection)

    Enum.each(grouped, fn {controller, routes} ->
      ts_code = BuildController.generate(controller, routes)

      Logger.info("Generated TS: #{ts_code}")
    end)
    :ok
  end

  @spec group_by_controller(Collections.t()) :: %{module() => [Route.t()]}
  defp group_by_controller(%Collections{actions: actions}) do
    Enum.group_by(actions, & &1.controller)
  end
end
