defmodule Wayfinder.Typescript.BuildAction do
  @moduledoc false

  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: String.t()
  def build(opts) do
    action = opts.safe_name

    """
    #{opts.doc_block}
    export const #{action} = #{build_method(opts)}

    #{action}.definition = {
      methods: #{inspect(opts.route.methods)},
      url: '#{opts.path}'
    }
    """
  end

  @spec build_method(BuildActions.opts()) :: String.t()
  defp build_method(opts) do
    Helpers.build_http_function(%{
      action: opts.safe_name,
      optional_args: opts.route.optional_args,
      url_arguments: opts.url_arguments,
      args: opts.url_arguments,
      method: opts.main_method
    })
  end
end
