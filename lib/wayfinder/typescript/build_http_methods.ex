defmodule Wayfinder.Typescript.BuildHttpMethods do
  @moduledoc false
  alias Wayfinder.Typescript.BuildGroup

  @spec build(BuildGroup.opts()) :: String.t()
  def build(opts) do
    opts.route.methods
    |> Enum.map(&build_function(opts, &1))
    |> Enum.join("\n\n")
  end

  @spec build_function(BuildAction.opts(), String.t()) :: String.t()
  defp build_function(opts, method) do
    """
    #{opts.doc_block}
    #{opts.safe_name}.#{method} = (args: #{opts.param_types}, options?: { query?: QueryParams, mergeQuery?: QueryParams }): {
      url: string,
      method: '#{method}',
    } => ({
      url: #{opts.safe_name}.url(args, options),
      method: '#{method}',
    })
    """
  end
end
