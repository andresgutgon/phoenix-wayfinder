defmodule Wayfinder.Typescript.BuildAction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    action = opts.safe_name
    methods = opts.route.methods

    """
    #{opts.doc_block}
    export const #{action} = #{build_method(opts)}

    #{action}.definition = {
      methods: #{inspect(methods)},
      url: '#{opts.path}'
    } satisfies #{Helpers.build_route_definition_type(methods)}
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
end
