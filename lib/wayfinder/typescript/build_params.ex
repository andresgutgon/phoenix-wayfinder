defmodule Wayfinder.Typescript.BuildParams do
  @moduledoc false

  alias Wayfinder.Processor.Route

  @ts_type "string | number"

  @type method_argments :: %{String.t() => String.t() | nil}
  @type params :: %{
          required(:method_arguments) => method_argments(),
          required(:list) => [String.t()]
        }
  @spec call(Route.t()) :: params()
  def call(route) do
    %{
      method_arguments: build_method_arguments(route),
      list: extract_path_params(route.path)
    }
  end

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

  @spec extract_path_params(String.t()) :: [String.t()]
  defp extract_path_params(path) do
    Regex.scan(~r/:([a-zA-Z_]+)/, path)
    |> Enum.map(fn [_, param] -> param end)
  end
end
