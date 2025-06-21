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
        build_exports(controller)
      ],
      "\n\n"
    )
  end

  @spec build_exports(Processor.controller()) :: String.t()
  defp build_exports(controller) do
    controller_name = controller.controller_parts |> List.last()

    export_pairs =
      controller.routes
      |> Enum.map(fn route ->
        action = Typescript.camelize_name(route.action)
        implemented_function = Route.js_method(route)

        case action == implemented_function do
          true -> action
          false -> "#{action}: #{implemented_function}"
        end
      end)
      |> Enum.uniq()
      |> Enum.join(", ")

    """

    const #{controller_name} = { #{export_pairs} }

    export default #{controller_name}
    """
  end
end
