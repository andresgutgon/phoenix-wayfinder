defmodule Wayfinder.Typescript.BuildParams do
  @moduledoc false

  alias Wayfinder.Processor.Route

  @ts_type "string | number"

  @type argument :: String.t() | nil
  @type method_argments :: %{String.t() => argument()}
  @type params :: %{
          required(:url_arguments) => argument(),
          required(:method_arguments) => method_argments(),
        }
  @spec call(Route.t()) :: params()
  def call(route) do
    %{
      url_arguments: build_url_arguments(route.all_arguments),
      method_arguments: build_method_arguments(route),
    }
  end

  defp build_url_arguments([]), do: nil
  defp build_url_arguments(params), do: gen_args(params)

  @spec build_method_arguments(Route.t()) :: method_argments()
  defp build_method_arguments(route) do
    Enum.into(route.param_spec_by_method, %{}, fn {method, params} ->
      {String.downcase(method), gen_args(params)}
    end)
  end

  defp gen_args([]), do: nil

  defp gen_args([param]) do
    "{ #{param}: #{@ts_type} } | [#{param}: #{@ts_type}] | #{@ts_type}"
  end

  defp gen_args(params) do
    flat = Enum.map_join(params, ", ", &"#{&1}: #{@ts_type}")
    tuple = Enum.map_join(params, ", ", fn _ -> "#{@ts_type}" end)
    "{ #{flat} } | [#{tuple}]"
  end
end
