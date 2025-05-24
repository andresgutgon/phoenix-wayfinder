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
    args = Map.get(opts.method_arguments, method, nil)
    Helpers.build_http_function(%{
      action: opts.safe_name,
      optional_args: opts.route.optional_args,
      url_arguments: opts.url_arguments,
      args: args,
      method: method
    })
  end
end
