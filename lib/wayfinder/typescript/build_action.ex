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
      params
      |> Enum.map(fn param ->
        optional_str = if param.optional, do: "true", else: "false"
        required_str = if param.optional, do: "false", else: "true"
        glob_str = if param.glob, do: "true", else: "false"

        "#{param.name}: { name: \"#{param.name}\", optional: #{optional_str}, required: #{required_str}, glob: #{glob_str} }"
      end)
      |> Enum.join(", ")

    "{ #{param_entries} }"
  end
end
