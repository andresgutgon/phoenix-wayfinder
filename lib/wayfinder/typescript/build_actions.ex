require Logger
defmodule Wayfinder.Typescript.BuildActions do
  @moduledoc """
  Generates a Typescript group for a given route.
  When user define this kind of routes

  ```elixir
  get "/users", UserController, :my_action
  post "/users", UserController, :my_action
  ```
  It should generate only one myAction.url specification with
  all the methods that this action can handle according to the router.

  """

  alias Wayfinder.Processor.Route
  alias Wayfinder.Typescript.BuildController, as: Controller
  alias Wayfinder.Typescript.GroupRoutes

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

  @spec call(Controller.group()) :: String.t()
  def call(group) do
    routes = GroupRoutes.call(group.routes)
    Logger.debug("Route Groups: #{inspect(routes, pretty: true)}")

    # opts = build_opts(group.routes)
    #
    # Enum.join(
    #   [
    #     build_export(opts),
    #     BuildUrlFunction.build(opts),
    #     BuildHttpMethods.build(opts),
    #     BuildFormObject.build(opts)
    #   ],
    #   "\n\n"
    # )
    ""
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

  @spec build_opts([Route.t()]) :: opts()
  defp build_opts(routes) do
    route = Enum.at(routes, 0)

    %{
      route: route,
      doc_block: DocBlock.build(route),
      safe_name: Route.js_method(route),
      path: route.path,
      main_method: String.downcase(Enum.at(route.methods, 0)),
      path_params: extract_path_params(route.path),
      param_types: generate_args_type(route.path)
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
