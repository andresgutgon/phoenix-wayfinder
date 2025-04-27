defmodule Wayfinder.Processor do
  require Logger
  @moduledoc false

  alias Wayfinder.Error
  alias Wayfinder.Processor.{Namer, Route}

  @spec call(module()) :: :ok | :ok | {:error, Error.t()}
  def call(module) do
    try do
      raw_routes = collect(module)
      _actions = group_by_actions(raw_routes)
      routes = group_by_named(raw_routes)


      Logger.info("Named Routes:\n#{inspect(routes, pretty: true, limit: :infinity)}")

      :ok
    rescue
      error ->
        {:error, Wayfinder.Error.new(Exception.message(error), :processor_failure)}
    end
  end

  @spec group_by_actions([Route.t()]) :: %{[String.t()] => [Route.t()]}
  defp group_by_actions(routes) do
    Enum.group_by(routes, fn route ->
      Namer.module_to_parts(route.controller)
    end)
  end

  @spec group_by_named([Route.t()]) :: %{String.t() => [Route.t()]}
  defp group_by_named(routes) do
    routes
    |> Enum.filter(&user_defined_name?/1)
    |> Enum.group_by(&build_full_named/1)
  end

  defp build_full_named(route) do
    "#{route.name}_#{route.action}"
  end

  defp user_defined_name?(%Route{controller: controller, name: name}) do
    inferred_name =
      controller
      |> Module.split()
      |> List.last()
      |> String.trim_trailing("Controller")
      |> Macro.underscore()

    name != inferred_name
  end

  @spec collect(module()) :: [Route.t()]
  defp collect(router) do
    router
    |> Phoenix.Router.routes()
    |> Enum.filter(&valid_wayfinder_route?/1)
    |> Enum.map(&Route.from_phoenix_route/1)
  end

  # Possible to have routes without controller. Skip them.
  defp valid_wayfinder_route?(%{plug: controller}) when is_atom(controller), do: true
  defp valid_wayfinder_route?(_), do: false
end
