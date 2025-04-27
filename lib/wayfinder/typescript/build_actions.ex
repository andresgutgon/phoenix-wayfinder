require Logger

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
    BuildHttpMethods,
    BuildUrlFunction,
    BuildFormObject
  }

  @type opts :: %{
          safe_name: String.t(),
          path: String.t(),
          main_method: String.t(),
          path_params: [String.t()],
          param_types: String.t(),
          doc_block: String.t(),
          route: Route.t(),
          methods: [String.t()]
        }

  @spec call(Processor.controller()) :: String.t()
  def call(controller) do
    Enum.join(
      Enum.map(controller.routes, fn route ->
        opts = build_opts(route)

        [
          build_export(opts),
          BuildUrlFunction.build(opts),
          BuildHttpMethods.build(opts),
          BuildFormObject.build(opts)
        ]
      end),
      "\n\n"
    )
  end

  @spec build_export(opts()) :: String.t()
  defp build_export(opts) do
    main_method = opts.main_method
    safe_name = opts.safe_name

    """
    #{opts.doc_block}
    export const #{safe_name} = (args: #{opts.param_types}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
      url: string,
      method: '#{main_method}',
    } => ({
      url: #{safe_name}.url(args, options),
      method: '#{main_method}',
    })

    #{safe_name}.definition = {
      methods: #{inspect(opts.route.methods)},
      url: '#{opts.path}'
    }
    """
  end

  @spec build_opts(Route.t()) :: opts()
  defp build_opts(route) do
    %{
      route: route,
      path: route.path,
      safe_name: Route.js_method(route),
      main_method: String.downcase(Enum.at(route.methods, 0)),
      doc_block: DocBlock.build(route),
      path_params: extract_path_params(route.path),
      param_types: generate_args_type(route.path),
      methods: route.methods
    }
  end

  defp extract_path_params(path) do
    Regex.scan(~r/:([a-zA-Z_]+)/, path)
    |> Enum.map(fn [_, param] -> param end)
  end

  defp generate_args_type(path) do
    params = extract_path_params(path)

    case params do
      [] ->
        "void"

      [param] ->
        "{ #{param}: string | number } | [#{param}: string | number] | string | number"

      _ ->
        flat = Enum.map_join(params, ", ", &"#{&1}: string | number")
        list = Enum.map_join(params, ", ", &"#{&1}")
        "{ #{flat} } | [#{list}]"
    end
  end
end
