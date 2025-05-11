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
    BuildUrlFunction,
    BuildFormObject
  }

  @type opts :: %{
          route: Route.t(),
          safe_name: String.t(),
          path: String.t(),
          main_method: String.t(),
          methods: [String.t()],
          doc_block: String.t(),
          function_arguments: map(),
          params: [String.t()]
        }

  @spec call(Processor.controller()) :: String.t()
  def call(controller) do
    Enum.join(
      Enum.map(controller.routes, fn route ->
        opts = build_opts(route)

        [
          BuildAction.build(opts),
          BuildUrlFunction.build(opts),
          BuildHttpMethods.build(opts),
          BuildFormObject.build(opts)
        ]
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
      main_method: String.downcase(Enum.at(route.methods, 0)),
      methods: route.methods,
      doc_block: DocBlock.build(route),
      function_arguments: params.function_arguments,
      params: params.list
    }
  end
end
