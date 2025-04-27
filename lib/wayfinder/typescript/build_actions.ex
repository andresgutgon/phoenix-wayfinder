defmodule Wayfinder.Typescript.BuildActions do
  @moduledoc """
  Generates a Typescript code for a controller / action
  Each action can have one or more routes, and each route can have one or more HTTP methods.
  When user define this kind of routes

  ```elixir
  get "/users", UserController, :my_action
  post "/users", UserController, :my_action
  ```
  It should generate only one myAction.url specification with
  all the methods that this action can handle according to the router.
  """

  alias Wayfinder.Processor.Route
  alias Wayfinder.Processor

  alias Wayfinder.Typescript.{
    DocBlock,
    BuildParams,
    BuildAction,
    BuildHttpMethods,
    BuildUrlFunction
  }

  @type opts :: %{
          route: Route.t(),
          safe_name: String.t(),
          path: String.t(),
          main_method: String.t(),
          methods: [String.t()],
          doc_block: String.t(),
          all_arguments: [Route.param_spec()],
          url_arguments: BuildParams.argument(),
          method_arguments: BuildParams.method_argments()
        }

  @spec call(Processor.controller()) :: String.t()
  def call(controller) do
    Enum.join(
      Enum.map(controller.routes, fn route ->
        opts = build_opts(route)

        Enum.flat_map(
          [
            [BuildAction.build(opts)],
            [BuildUrlFunction.build(opts)],
            BuildHttpMethods.build(opts)
          ],
          & &1
        )
      end),
      "\n\n"
    )
  end

  @spec build_opts(Route.t()) :: opts()
  defp build_opts(route) do
    params = BuildParams.call(route)

    %{
      route: route,
      path: route.path,
      safe_name: Route.js_method(route),
      main_method: main_method(route),
      methods: route.methods,
      doc_block: DocBlock.build(route),
      all_arguments: route.all_params,
      url_arguments: params.url_arguments,
      method_arguments: params.method_arguments
    }
  end

  @spec main_method(Route.t()) :: String.t()
  def main_method(%Route{methods: methods}) when is_list(methods) do
    case Enum.find(methods, &(&1 == "get")) do
      nil -> List.first(methods) || "get"
      method -> method
    end
  end
end
