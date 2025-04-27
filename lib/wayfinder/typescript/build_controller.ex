defmodule Wayfinder.Typescript.BuildController do
  @moduledoc """
  Generates a Typescript controller for a given route.
  The controller includes all actions found in the Phoenix router.
  """

  alias Wayfinder.Processor
  alias Wayfinder.Processor.Route
  alias Wayfinder.Typescript.BuildActions
  alias Wayfinder.Typescript.Helpers, as: Typescript

  @spec call(Processor.controller(), String.t()) :: String.t()
  def call(controller, imports) do
    ts_code = BuildActions.call(controller) |> String.trim()
    Enum.join(
      [
        imports,
        Typescript.clean_typescript(ts_code),
        build_exports(controller.module, controller.routes)
      ],
      "\n\n"
    )
  end

  @spec build_exports(module(), [Route.t()]) :: String.t()
  defp build_exports(controller, routes) do
    controller_name =
      controller
      |> Module.split()
      |> List.last()

    export_names =
      Enum.map(routes, &Route.js_method/1)
      |> Enum.uniq()
      |> Enum.join(", ")

    """

    const #{controller_name} = { #{export_names} }

    export default #{controller_name}
    """
  end
end
