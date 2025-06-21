defmodule Wayfinder.Typescript.BuildParams do
  @moduledoc false

  alias Wayfinder.Processor.Route

  @ts_type "string | number"

  @type argument :: String.t() | nil
  @type method_argments :: %{String.t() => argument()}
  @type params :: %{
          required(:url_arguments) => argument(),
          required(:method_arguments) => method_argments()
        }
  @spec call(Route.t()) :: params()
  def call(route) do
    %{
      url_arguments: gen_args(route.all_params),
      method_arguments: build_method_arguments(route)
    }
  end

  @spec build_method_arguments(Route.t()) :: method_argments()
  defp build_method_arguments(route) do
    Enum.into(route.params_by_method, %{}, fn {method, params} ->
      {method, gen_args(params)}
    end)
  end

  defp gen_args([]), do: nil

  defp gen_args([%{name: name, optional: true}]) do
    "{ #{name}?: #{@ts_type} } | [#{@ts_type}]"
  end

  defp gen_args([%{name: name, optional: false}]) do
    "{ #{name}: #{@ts_type} } | [#{@ts_type}] | #{@ts_type}"
  end

  @spec gen_args([Route.param_spec()]) :: String.t()
  defp gen_args(params) do
    glob_param = Enum.find(params, & &1.glob)
    ts_type = @ts_type

    cond do
      params == [] ->
        nil

      glob_param && length(params) == 1 ->
        "{ #{glob_param.name}: (#{ts_type})[] } | (#{ts_type})[]"

      glob_param ->
        object =
          Enum.map_join(params, ", ", fn
            %{glob: true, name: n} -> "#{n}: (#{ts_type})[]"
            %{optional: true, name: n} -> "#{n}?: #{ts_type}"
            %{name: n} -> "#{n}: #{ts_type}"
          end)
          |> then(&"{ #{&1} }")

        object

      true ->
        required = Enum.filter(params, &(!&1.optional))
        optional = Enum.filter(params, & &1.optional)

        object =
          required
          |> Enum.map(&"#{&1.name}: #{ts_type}")
          |> Kernel.++(Enum.map(optional, &"#{&1.name}?: #{ts_type}"))
          |> Enum.join(", ")
          |> then(&"{ #{&1} }")

        tuple = Enum.map_join(params, ", ", fn _ -> ts_type end)
        "#{object} | [#{tuple}]"
    end
  end
end
