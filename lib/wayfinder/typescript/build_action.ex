defmodule Wayfinder.Typescript.BuildAction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    action = opts.safe_name
    methods = opts.route.methods
    parameters = build_parameters_definition(opts.all_arguments)

    """
    #{opts.doc_block}
    export const #{action} = #{build_method(opts)}

    #{action}.definition = {
      methods: #{inspect(methods)},
      url: '#{opts.path}',
      parameters: #{parameters}
    } satisfies #{Helpers.build_route_definition_type(methods, true)}
    """
  end

  @spec build_method(BuildActions.opts()) :: String.t()
  defp build_method(opts) do
    Helpers.build_http_function(%{
      action: opts.safe_name,
      ts_type: opts.url_arguments,
      args: opts.all_arguments,
      all_args: opts.all_arguments,
      method: opts.main_method
    })
  end

  @spec build_parameters_definition([map()]) :: String.t()
  defp build_parameters_definition([]), do: "{}"

  defp build_parameters_definition(params) do
    param_entries =
      Enum.map_join(params, ", ", fn param ->
        "#{param.name}: { name: \"#{param.name}\", optional: #{param.optional || false}, required: #{!param.optional}, glob: #{param.glob || false} }"
      end)

    "{ #{param_entries} }"
  end
end
