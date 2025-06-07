defmodule Wayfinder.Typescript.BuildHttpMethods do
  @moduledoc false
  alias Wayfinder.Typescript.{BuildActions, Helpers}

  @spec build(BuildActions.opts()) :: [String.t()]
  def build(opts) do
    opts.route.methods
    |> Enum.map(&build_function(opts, &1))
  end

  @spec build_function(BuildActions.opts(), String.t()) :: String.t()
  defp build_function(opts, method) do
    """
    #{opts.safe_name}.#{method} = #{build_method(opts, method)}
    """
  end

  @spec build_method(BuildActions.opts(), String.t()) :: String.t()
  defp build_method(opts, method) do
    ts_type = Map.get(opts.method_arguments, method)
    args = opts.route.params_by_method[method] || []

    Helpers.build_http_function(%{
      action: opts.safe_name,
      ts_type: ts_type,
      args: args,
      all_args: opts.all_arguments,
      method: method
    })
  end
end
