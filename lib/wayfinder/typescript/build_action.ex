defmodule Wayfinder.Typescript.BuildAction do
  @moduledoc false

  alias Wayfinder.Processor.Route

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
          route: Route.t()
        }

  @spec generate(Route.t()) :: String.t()
  def generate(%Route{} = route) do
    # {generate_form_object(safe_name, route, param_types)}
    opts = build_opts(route)
    Enum.join(
      [
        build_export(opts),
        BuildUrlFunction.build(opts),
        BuildHttpMethods.build(opts),
        BuildFormObject.build(opts)
      ],
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
