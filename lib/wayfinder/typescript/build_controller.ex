defmodule Wayfinder.Typescript.BuildController do
  @moduledoc """
  Generates a Typescript controller for a given route.
  The controller includes all actions found in the Phoenix router.
  """

  alias Wayfinder.Processor.Route
  alias Wayfinder.Typescript.BuildActions
  alias Wayfinder.Typescript.Helpers, as: Typescript

  @type group :: %{controller: module(), action: atom(), routes: [Route.t()]}

  @spec call(group(), String.t()) :: String.t()
  def call(group, imports) do
    Enum.join(
      [
        imports,
        Typescript.clean_typescript(BuildActions.call(group) |> String.trim()),
        build_exports(group.controller, group.routes)
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
