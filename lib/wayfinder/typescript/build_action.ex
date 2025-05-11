defmodule Wayfinder.Typescript.BuildAction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    action = opts.safe_name
    action_method = build_action_method(opts)

    """
    #{opts.doc_block}
    export const #{action} = #{action_method}

    #{action}.definition = {
      methods: #{inspect(opts.route.methods)},
      url: '#{opts.path}'
    }
    """
  end

  @spec build_action_method(opts()) :: String.t()
  defp build_action_method(opts) do
    Helpers.build_http_function(%{
      action: opts.safe_name,
      optional_args: opts.route.optional_args,
      args: opts.function_arguments,
      method: opts.main_method
    })
  end
end
